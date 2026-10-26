import 'package:flutter_test/flutter_test.dart';
import 'package:airwave/features/catalog/domain/models/channel.dart';
import 'package:airwave/features/catalog/domain/models/filter_state.dart';
import 'package:airwave/features/catalog/domain/models/stream_source.dart';
import 'package:airwave/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:airwave/features/catalog/data/catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Airwave Catalog & Filter Logic Tests', () {
    final sampleStreams = [
      const StreamSource(
        channel: 'ch-1',
        url: 'https://example.com/stream1.m3u8',
        quality: '720p',
        height: 720,
        isGeoBlocked: false,
        is247: true,
      ),
      const StreamSource(
        channel: 'ch-1',
        url: 'https://example.com/stream2.m3u8',
        quality: '1080p',
        height: 1080,
        isGeoBlocked: true,
        is247: false,
      ),
    ];

    final sampleChannels = [
      Channel(
        id: 'ch-1',
        name: 'BBC News',
        altNames: const ['British Broadcasting'],
        countryCode: 'GB',
        countryName: 'United Kingdom',
        categories: const ['news'],
        streams: sampleStreams,
      ),
      const Channel(
        id: 'ch-2',
        name: 'Sun TV',
        countryCode: 'IN',
        countryName: 'India',
        categories: const ['entertainment'],
        languages: ['tam'],
        streams: [
          StreamSource(
            channel: 'ch-2',
            url: 'https://example.com/suntv.m3u8',
            quality: '1080p',
            height: 1080,
            isGeoBlocked: false,
            is247: true,
          ),
        ],
      ),
    ];

    final repo = CatalogRepository(database: AppDatabase(NativeDatabase.memory()));

    test('Filters channels by category correctly', () {
      final filter = const FilterState(selectedCategories: {'news'});
      final filtered = repo.applyFilters(sampleChannels, filter);

      expect(filtered.length, 1);
      expect(filtered.first.id, 'ch-1');
    });

    test('Filters channels by country correctly', () {
      final filter = const FilterState(selectedCountries: {'IN'});
      final filtered = repo.applyFilters(sampleChannels, filter);

      expect(filtered.length, 1);
      expect(filtered.first.id, 'ch-2');
    });

    test('Filters channels by minimum quality', () {
      final filter = const FilterState(minQuality: MinQualityFilter.p1080);
      final filtered = repo.applyFilters(sampleChannels, filter);

      expect(filtered.length, 2);
    });

    test('Channel initials generator works properly', () {
      expect(sampleChannels[0].initials, 'BN');
      expect(sampleChannels[1].initials, 'ST');
    });
  });
}
