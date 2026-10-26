import 'dart:async';
import 'package:flutter/foundation.dart' hide Category;
import 'package:airwave/core/constants/api_constants.dart';
import 'package:airwave/core/database/app_database.dart';
import 'package:airwave/core/network/api_client.dart';
import 'package:airwave/features/catalog/domain/models/channel.dart';
import 'package:airwave/features/catalog/domain/models/filter_state.dart';
import 'package:airwave/features/catalog/domain/models/taxonomy.dart';
import 'package:airwave/features/catalog/data/catalog_parser.dart';

class CatalogRepository {
  final ApiClient _apiClient;
  final AppDatabase _db;

  // In-memory cache for fast, responsive UI navigation & 60fps scrolling
  List<Channel> _cachedChannels = [];
  List<Category> _cachedCategories = [];
  List<Country> _cachedCountries = [];
  List<Language> _cachedLanguages = [];
  bool _isRefreshing = false;

  CatalogRepository({
    ApiClient? apiClient,
    AppDatabase? database,
  })  : _apiClient = apiClient ?? ApiClient(),
        _db = database ?? AppDatabase();

  List<Channel> get channels => _cachedChannels;
  List<Category> get categories => _cachedCategories;
  List<Country> get countries => _cachedCountries;
  List<Language> get languages => _cachedLanguages;
  bool get isRefreshing => _isRefreshing;

  // Stale-While-Revalidate initialization
  Future<List<Channel>> getOrFetchCatalog({bool forceRefresh = false}) async {
    // 1. If memory cache already populated and not force refreshing, return immediately
    if (_cachedChannels.isNotEmpty && !forceRefresh) {
      _checkAndRevalidateInBackground();
      return _cachedChannels;
    }

    // 2. Try loading from Drift SQLite cache
    final localChannels = await _db.getAllChannels();
    if (localChannels.isNotEmpty && !forceRefresh) {
      _cachedChannels = localChannels;
      _deriveTaxonomiesFromChannels();
      _checkAndRevalidateInBackground();
      return _cachedChannels;
    }

    // 3. Otherwise fetch from network
    return await refreshCatalog();
  }

  Future<void> _checkAndRevalidateInBackground() async {
    try {
      final lastFetch = await _db.getLastCatalogFetchTime();
      final shouldRefresh = lastFetch == null ||
          DateTime.now().difference(lastFetch) > ApiConstants.catalogTtl;
      if (shouldRefresh && !_isRefreshing) {
        refreshCatalog().ignore();
      }
    } catch (_) {}
  }

  Future<List<Channel>> refreshCatalog() async {
    if (_isRefreshing) return _cachedChannels;
    _isRefreshing = true;

    try {
      // Step 1: Fetch raw JSON from all endpoints
      final rawData = await _apiClient.fetchAllCatalogData();

      // Step 2: Parse and join in background isolate
      final parsed = await CatalogParser.parseInBackground(rawData);

      // Step 3: Save to SQLite database
      if (parsed.channels.isNotEmpty) {
        await _db.insertChannelsBatch(parsed.channels);
        await _db.setLastCatalogFetchTime(DateTime.now());

        _cachedChannels = parsed.channels;
        _cachedCategories = parsed.categories;
        _cachedCountries = parsed.countries;
        _cachedLanguages = parsed.languages;
      }
    } catch (e) {
      debugPrint('Error refreshing catalog: $e');
      // If error but we have local channels, keep existing cache
      if (_cachedChannels.isEmpty) {
        _cachedChannels = await _db.getAllChannels();
        _deriveTaxonomiesFromChannels();
      }
    } finally {
      _isRefreshing = false;
    }

    return _cachedChannels;
  }

  void _deriveTaxonomiesFromChannels() {
    final catMap = <String, Category>{};
    final countryMap = <String, Country>{};

    for (final ch in _cachedChannels) {
      for (final c in ch.categories) {
        if (!catMap.containsKey(c)) {
          catMap[c] = Category(id: c, name: _capitalize(c));
        }
      }
      if (ch.countryCode.isNotEmpty && !countryMap.containsKey(ch.countryCode)) {
        countryMap[ch.countryCode] = Country(
          code: ch.countryCode,
          name: ch.countryName.isNotEmpty ? ch.countryName : ch.countryCode,
          flag: ch.countryFlag,
        );
      }
    }

    _cachedCategories = catMap.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    _cachedCountries = countryMap.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // Filter channels according to active FilterState
  List<Channel> applyFilters(List<Channel> input, FilterState filter) {
    return input.where((channel) {
      // 1. Search query filter
      if (filter.searchQuery.trim().isNotEmpty) {
        final q = filter.searchQuery.trim().toLowerCase();
        final matchName = channel.name.toLowerCase().contains(q);
        final matchAlt = channel.altNames.any((alt) => alt.toLowerCase().contains(q));
        final matchNet = channel.network?.toLowerCase().contains(q) ?? false;
        if (!matchName && !matchAlt && !matchNet) return false;
      }

      // 2. Country filter
      if (filter.selectedCountries.isNotEmpty) {
        if (!filter.selectedCountries.contains(channel.countryCode.toUpperCase())) {
          return false;
        }
      }

      // 3. Category filter
      if (filter.selectedCategories.isNotEmpty) {
        final hasCategory = channel.categories.any(
          (c) => filter.selectedCategories.contains(c.toLowerCase()),
        );
        if (!hasCategory) return false;
      }

      // 4. Language filter
      if (filter.selectedLanguages.isNotEmpty) {
        final hasLang = channel.languages.any(
          (l) => filter.selectedLanguages.contains(l.toLowerCase()),
        );
        if (!hasLang) return false;
      }

      // 5. Logo filter
      if (filter.onlyWithLogo && (channel.logoUrl == null || channel.logoUrl!.isEmpty)) {
        return false;
      }

      // 6. Quality & Stream criteria
      if (channel.streams.isEmpty) return false;

      if (filter.hideGeoBlocked) {
        final hasNonGeoStream = channel.streams.any((s) => !s.isGeoBlocked);
        if (!hasNonGeoStream) return false;
      }

      if (filter.only247) {
        final has247Stream = channel.streams.any((s) => s.is247);
        if (!has247Stream) return false;
      }

      if (filter.minQuality != MinQualityFilter.any) {
        final minHeight = filter.minQuality.minHeight;
        final meetsQuality = channel.streams.any((s) => s.height >= minHeight);
        if (!meetsQuality) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => _compareChannels(a, b, filter.sortBy));
  }

  int _compareChannels(Channel a, Channel b, SortOption sortBy) {
    switch (sortBy) {
      case SortOption.az:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case SortOption.za:
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      case SortOption.quality:
        final hA = a.streams.isNotEmpty ? a.streams.first.height : 0;
        final hB = b.streams.isNotEmpty ? b.streams.first.height : 0;
        return hB.compareTo(hA);
      case SortOption.recentlyLaunched:
        final lA = a.launched ?? '';
        final lB = b.launched ?? '';
        return lB.compareTo(lA);
      case SortOption.relevance:
        // Default relevance: streams count & quality
        final qA = (a.logoUrl != null ? 100 : 0) + (a.streams.isNotEmpty ? a.streams.first.height : 0);
        final qB = (b.logoUrl != null ? 100 : 0) + (b.streams.isNotEmpty ? b.streams.first.height : 0);
        return qB.compareTo(qA);
    }
  }

  // Fast Instant Search using SQLite FTS / indexed queries
  Future<List<Channel>> searchInstant(String query) async {
    return _db.searchChannels(query);
  }

  // Channel details by id
  Future<Channel?> getChannelById(String id) async {
    final fromMem = _cachedChannels.where((c) => c.id == id).firstOrNull;
    if (fromMem != null) return fromMem;
    return _db.getChannelById(id);
  }

  // Favorites
  Future<List<Channel>> getFavorites() async {
    final favIds = await _db.getFavoriteChannelIds();
    final favIdSet = favIds.toSet();
    final channels = _cachedChannels.where((c) => favIdSet.contains(c.id)).toList();
    // Maintain favorite order
    channels.sort((a, b) => favIds.indexOf(a.id).compareTo(favIds.indexOf(b.id)));
    return channels;
  }

  Future<void> toggleFavorite(String channelId) async {
    final isFav = await _db.isFavorite(channelId);
    if (isFav) {
      await _db.removeFavorite(channelId);
    } else {
      await _db.addFavorite(channelId);
    }
  }

  Future<bool> isFavorite(String channelId) => _db.isFavorite(channelId);

  // History
  Future<List<Channel>> getHistory() async {
    final histIds = await _db.getHistoryChannelIds();
    final histMap = {for (var c in _cachedChannels) c.id: c};
    return histIds.map((id) => histMap[id]).whereType<Channel>().toList();
  }

  Future<void> recordHistory(String channelId) => _db.recordHistory(channelId);
  Future<void> clearHistory() => _db.clearHistory();
}
