import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../data/catalog_repository.dart';
import '../../domain/models/channel.dart';
import '../../domain/models/filter_state.dart';
import '../../domain/models/taxonomy.dart';

// Database & Network Providers
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(apiClientProvider);
  return CatalogRepository(database: db, apiClient: api);
});

// Catalog State Notifier
class CatalogNotifier extends AsyncNotifier<List<Channel>> {
  @override
  Future<List<Channel>> build() async {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getOrFetchCatalog();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(catalogRepositoryProvider);
      return repo.refreshCatalog();
    });
  }
}

final catalogNotifierProvider =
    AsyncNotifierProvider<CatalogNotifier, List<Channel>>(CatalogNotifier.new);

// Filter Controller Notifier
class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() => const FilterState();

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleCountry(String countryCode) {
    final current = Set<String>.from(state.selectedCountries);
    if (current.contains(countryCode.toUpperCase())) {
      current.remove(countryCode.toUpperCase());
    } else {
      current.add(countryCode.toUpperCase());
    }
    state = state.copyWith(selectedCountries: current);
  }

  void toggleCategory(String categoryId) {
    final current = Set<String>.from(state.selectedCategories);
    final lower = categoryId.toLowerCase();
    if (current.contains(lower)) {
      current.remove(lower);
    } else {
      current.add(lower);
    }
    state = state.copyWith(selectedCategories: current);
  }

  void toggleLanguage(String langCode) {
    final current = Set<String>.from(state.selectedLanguages);
    final lower = langCode.toLowerCase();
    if (current.contains(lower)) {
      current.remove(lower);
    } else {
      current.add(lower);
    }
    state = state.copyWith(selectedLanguages: current);
  }

  void setMinQuality(MinQualityFilter quality) {
    state = state.copyWith(minQuality: quality);
  }

  void toggleHideGeoBlocked() {
    state = state.copyWith(hideGeoBlocked: !state.hideGeoBlocked);
  }

  void toggleOnly247() {
    state = state.copyWith(only247: !state.only247);
  }

  void toggleOnlyWithLogo() {
    state = state.copyWith(onlyWithLogo: !state.onlyWithLogo);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortBy: option);
  }

  void setViewMode(ViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void reset() {
    state = const FilterState();
  }
}

final filterNotifierProvider =
    NotifierProvider<FilterNotifier, FilterState>(FilterNotifier.new);

// Filtered Channels Provider
final filteredChannelsProvider = Provider<List<Channel>>((ref) {
  final catalogAsync = ref.watch(catalogNotifierProvider);
  final filter = ref.watch(filterNotifierProvider);
  final repo = ref.watch(catalogRepositoryProvider);

  return catalogAsync.maybeWhen(
    data: (channels) => repo.applyFilters(channels, filter),
    orElse: () => const [],
  );
});

// Featured Hero Channels (Must have logo, HD stream, high relevance)
final featuredChannelsProvider = Provider<List<Channel>>((ref) {
  final catalogAsync = ref.watch(catalogNotifierProvider);
  return catalogAsync.maybeWhen(
    data: (channels) {
      return channels
          .where((c) =>
              c.logoUrl != null &&
              c.logoUrl!.isNotEmpty &&
              c.streams.any((s) => s.height >= 720 && !s.isGeoBlocked))
          .take(6)
          .toList();
    },
    orElse: () => const [],
  );
});

// Category list provider
final categoriesListProvider = Provider<List<Category>>((ref) {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.categories;
});

// Countries list provider
final countriesListProvider = Provider<List<Country>>((ref) {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.countries;
});

// Languages list provider
final languagesListProvider = Provider<List<Language>>((ref) {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.languages;
});

// Blocked channels list provider
final blockedChannelsProvider = FutureProvider<List<BlockedChannel>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  if (repo.blockedChannels.isNotEmpty) {
    return repo.blockedChannels;
  }
  // Try loading from database or network directly
  final jsonStr = await ref.watch(appDatabaseProvider).getMetaValue('cached_blocklist');
  if (jsonStr != null && jsonStr.isNotEmpty) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => BlockedChannel.fromJson(e))
          .toList();
    } catch (_) {}
  }
  // Fallback direct network fetch
  try {
    final list = await ref.watch(apiClientProvider).fetchBlocklistOnly();
    if (list.isNotEmpty) {
      await ref.watch(appDatabaseProvider).setMetaValue(
            'cached_blocklist',
            jsonEncode(list.map((e) => e.toJson()).toList()),
          );
    }
    return list;
  } catch (_) {
    return repo.blockedChannels;
  }
});

// Favorites Notifier
class FavoritesNotifier extends AsyncNotifier<List<Channel>> {
  @override
  Future<List<Channel>> build() async {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getFavorites();
  }

  Future<void> toggleFavorite(String channelId) async {
    final repo = ref.read(catalogRepositoryProvider);
    await repo.toggleFavorite(channelId);
    state = AsyncValue.data(await repo.getFavorites());
  }

  Future<bool> isFavorite(String channelId) async {
    final repo = ref.read(catalogRepositoryProvider);
    return repo.isFavorite(channelId);
  }
}

final favoritesNotifierProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Channel>>(FavoritesNotifier.new);

// History Notifier
class HistoryNotifier extends AsyncNotifier<List<Channel>> {
  @override
  Future<List<Channel>> build() async {
    final repo = ref.watch(catalogRepositoryProvider);
    return repo.getHistory();
  }

  Future<void> recordPlay(String channelId) async {
    final repo = ref.read(catalogRepositoryProvider);
    await repo.recordHistory(channelId);
    state = AsyncValue.data(await repo.getHistory());
  }

  Future<void> clearAll() async {
    final repo = ref.read(catalogRepositoryProvider);
    await repo.clearHistory();
    state = const AsyncValue.data([]);
  }
}

final historyNotifierProvider =
    AsyncNotifierProvider<HistoryNotifier, List<Channel>>(HistoryNotifier.new);
