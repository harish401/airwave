import 'dart:isolate';
import '../domain/models/channel.dart';
import '../domain/models/stream_source.dart';
import '../domain/models/taxonomy.dart';

class RawCatalogData {
  final List<dynamic> channelsJson;
  final List<dynamic> streamsJson;
  final List<dynamic> logosJson;
  final List<dynamic> feedsJson;
  final List<dynamic> categoriesJson;
  final List<dynamic> countriesJson;
  final List<dynamic> languagesJson;
  final List<dynamic> blocklistJson;

  const RawCatalogData({
    required this.channelsJson,
    required this.streamsJson,
    required this.logosJson,
    required this.feedsJson,
    required this.categoriesJson,
    required this.countriesJson,
    required this.languagesJson,
    required this.blocklistJson,
  });
}

class ParsedCatalogResult {
  final List<Channel> channels;
  final List<Category> categories;
  final List<Country> countries;
  final List<Language> languages;
  final List<BlockedChannel> blockedChannels;

  const ParsedCatalogResult({
    required this.channels,
    required this.categories,
    required this.countries,
    required this.languages,
    this.blockedChannels = const [],
  });
}

class CatalogParser {
  CatalogParser._();

  static Future<ParsedCatalogResult> parseInBackground(RawCatalogData rawData) {
    return Isolate.run(() => _processJoinAndFilter(rawData));
  }

  static ParsedCatalogResult _processJoinAndFilter(RawCatalogData raw) {
    // 1. Process Blocklist Set
    final blockedChannelIds = <String>{};
    final blockedList = <BlockedChannel>[];
    for (final item in raw.blocklistJson) {
      if (item is Map<String, dynamic>) {
        final b = BlockedChannel.fromJson(item);
        if (b.channel.isNotEmpty) {
          blockedChannelIds.add(b.channel);
          blockedList.add(b);
        }
      }
    }

    // 2. Process Categories
    final categories = <Category>[];
    for (final item in raw.categoriesJson) {
      if (item is Map<String, dynamic>) {
        final cat = Category.fromJson(item);
        if (cat.id.toLowerCase() != 'xxx') {
          categories.add(cat);
        }
      }
    }

    // 3. Process Countries
    final countries = <Country>[];
    final countryMap = <String, Country>{};
    for (final item in raw.countriesJson) {
      if (item is Map<String, dynamic>) {
        final c = Country.fromJson(item);
        countries.add(c);
        countryMap[c.code.toUpperCase()] = c;
      }
    }

    // 4. Process Languages
    final languages = <Language>[];
    for (final item in raw.languagesJson) {
      if (item is Map<String, dynamic>) {
        languages.add(Language.fromJson(item));
      }
    }

    // 5. Group and sort streams by channel
    final streamsByChannel = <String, List<StreamSource>>{};
    for (final item in raw.streamsJson) {
      if (item is Map<String, dynamic>) {
        final stream = StreamSource.fromJson(item);
        if (stream.channel.isNotEmpty && stream.url.isNotEmpty) {
          streamsByChannel.putIfAbsent(stream.channel, () => []).add(stream);
        }
      }
    }

    // Sort streams: non-geo-blocked first, then quality descending
    for (final streamList in streamsByChannel.values) {
      streamList.sort((a, b) {
        if (!a.isGeoBlocked && b.isGeoBlocked) return -1;
        if (a.isGeoBlocked && !b.isGeoBlocked) return 1;
        return b.height.compareTo(a.height);
      });
    }

    // 6. Group logos and select best per channel (prefer in_use, then channel-level over feed-level)
    final bestLogoByChannel = <String, String>{};
    final logoScoreByChannel = <String, int>{};

    for (final item in raw.logosJson) {
      if (item is Map<String, dynamic>) {
        final channelId = item['channel']?.toString();
        final url = item['url']?.toString();
        if (channelId == null || url == null || url.isEmpty) continue;

        final bool inUse = item['in_use'] == true;
        final bool isChannelLevel = item['feed'] == null || item['feed'].toString().isEmpty;

        int score = 0;
        if (inUse) score += 10;
        if (isChannelLevel) score += 5;

        final existingScore = logoScoreByChannel[channelId] ?? -1;
        if (score > existingScore) {
          logoScoreByChannel[channelId] = score;
          bestLogoByChannel[channelId] = url;
        }
      }
    }

    // 7. Group feeds by channel to find main feed languages
    final feedLanguagesByChannel = <String, List<String>>{};
    for (final item in raw.feedsJson) {
      if (item is Map<String, dynamic>) {
        final channelId = item['channel']?.toString();
        if (channelId == null || channelId.isEmpty) continue;

        final isMain = item['is_main'] == true;
        final langs = (item['languages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        if (isMain || !feedLanguagesByChannel.containsKey(channelId)) {
          feedLanguagesByChannel[channelId] = langs;
        }
      }
    }

    // 8. Join Channels and apply exclusion criteria
    final finalChannels = <Channel>[];

    for (final item in raw.channelsJson) {
      if (item is! Map<String, dynamic>) continue;

      final id = item['id']?.toString() ?? '';
      if (id.isEmpty) continue;

      // Rule: Exclude blocklist
      if (blockedChannelIds.contains(id)) continue;

      // Rule: Exclude is_nsfw
      final isNsfw = item['is_nsfw'] == true;
      if (isNsfw) continue;

      // Rule: Exclude closed
      final closed = item['closed']?.toString();
      if (closed != null && closed.isNotEmpty) continue;

      // Rule: Exclude category "xxx"
      final categoriesList = (item['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      if (categoriesList.any((c) => c.toLowerCase() == 'xxx')) continue;

      // Rule: Exclude channels with no stream
      final channelStreams = streamsByChannel[id];
      if (channelStreams == null || channelStreams.isEmpty) continue;

      // Resolve country info
      final countryCode = (item['country']?.toString() ?? '').toUpperCase();
      final countryObj = countryMap[countryCode];
      final countryName = countryObj?.name ?? countryCode;
      final countryFlag = countryObj?.flag ?? '';

      // Resolve languages: main feed -> country languages fallback
      var resolvedLanguages = feedLanguagesByChannel[id] ?? [];
      if (resolvedLanguages.isEmpty && countryObj != null) {
        resolvedLanguages = countryObj.languages;
      }

      final logo = bestLogoByChannel[id];

      final channel = Channel(
        id: id,
        name: item['name']?.toString() ?? '',
        altNames: (item['alt_names'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        network: item['network']?.toString(),
        owners: (item['owners'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        countryCode: countryCode,
        countryName: countryName,
        countryFlag: countryFlag,
        categories: categoriesList,
        logoUrl: logo,
        streams: channelStreams,
        languages: resolvedLanguages,
        website: item['website']?.toString(),
        isNsfw: false,
        launched: item['launched']?.toString(),
        closed: null,
      );

      finalChannels.add(channel);
    }

    return ParsedCatalogResult(
      channels: finalChannels,
      categories: categories,
      countries: countries,
      languages: languages,
      blockedChannels: blockedList,
    );
  }
}
