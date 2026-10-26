import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../features/catalog/domain/models/channel.dart';
import '../../features/catalog/domain/models/stream_source.dart';

part 'app_database.g.dart';

class ChannelsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get altNames => text().withDefault(const Constant('[]'))();
  TextColumn get network => text().nullable()();
  TextColumn get countryCode => text().withDefault(const Constant(''))();
  TextColumn get countryName => text().withDefault(const Constant(''))();
  TextColumn get countryFlag => text().withDefault(const Constant(''))();
  TextColumn get categories => text().withDefault(const Constant('[]'))();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get streamsJson => text()();
  TextColumn get languages => text().withDefault(const Constant('[]'))();
  TextColumn get website => text().nullable()();
  TextColumn get launched => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class FavoritesTable extends Table {
  TextColumn get channelId => text()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {channelId};
}

class HistoryTable extends Table {
  TextColumn get channelId => text()();
  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {channelId};
}

class AppMetaTable extends Table {
  TextColumn get metaKey => text()();
  TextColumn get metaValue => text()();

  @override
  Set<Column> get primaryKey => {metaKey};
}

@DriftDatabase(tables: [ChannelsTable, FavoritesTable, HistoryTable, AppMetaTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? driftDatabase(name: 'airwave_db'));

  @override
  int get schemaVersion => 1;

  // Insert or update batch of channels
  Future<void> insertChannelsBatch(List<Channel> channels) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        channelsTable,
        channels.map((ch) {
          return ChannelsTableCompanion.insert(
            id: ch.id,
            name: ch.name,
            altNames: Value(jsonEncode(ch.altNames)),
            network: Value(ch.network),
            countryCode: Value(ch.countryCode),
            countryName: Value(ch.countryName),
            countryFlag: Value(ch.countryFlag),
            categories: Value(jsonEncode(ch.categories)),
            logoUrl: Value(ch.logoUrl),
            streamsJson: jsonEncode(ch.streams.map((s) => s.toJson()).toList()),
            languages: Value(jsonEncode(ch.languages)),
            website: Value(ch.website),
            launched: Value(ch.launched),
            updatedAt: Value(DateTime.now()),
          );
        }).toList(),
      );
    });
  }

  // Get all cached channels
  Future<List<Channel>> getAllChannels() async {
    final rows = await select(channelsTable).get();
    return rows.map(_rowToChannel).toList();
  }

  // Paginated channels
  Future<List<Channel>> getChannelsPage({required int offset, required int limit}) async {
    final query = select(channelsTable)..limit(limit, offset: offset);
    final rows = await query.get();
    return rows.map(_rowToChannel).toList();
  }

  // Search channels with fast prefix and full-text matching across name, alt_names, network
  Future<List<Channel>> searchChannels(String query, {int limit = 50}) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return const [];

    final pattern = '%$clean%';
    final dbQuery = select(channelsTable)
      ..where((tbl) =>
          tbl.name.lower().like(pattern) |
          tbl.altNames.lower().like(pattern) |
          tbl.network.lower().like(pattern))
      ..limit(limit);

    final rows = await dbQuery.get();
    return rows.map(_rowToChannel).toList();
  }

  // Channel by ID
  Future<Channel?> getChannelById(String id) async {
    final query = select(channelsTable)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _rowToChannel(row) : null;
  }

  // Favorites
  Future<List<String>> getFavoriteChannelIds() async {
    final query = select(favoritesTable)
      ..orderBy([(t) => OrderingTerm.asc(t.orderIndex), (t) => OrderingTerm.desc(t.addedAt)]);
    final rows = await query.get();
    return rows.map((r) => r.channelId).toList();
  }

  Future<void> addFavorite(String channelId) async {
    final count = await select(favoritesTable).get();
    await into(favoritesTable).insertOnConflictUpdate(
      FavoritesTableCompanion.insert(
        channelId: channelId,
        orderIndex: Value(count.length),
        addedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> removeFavorite(String channelId) async {
    await (delete(favoritesTable)..where((t) => t.channelId.equals(channelId))).go();
  }

  Future<bool> isFavorite(String channelId) async {
    final q = select(favoritesTable)..where((t) => t.channelId.equals(channelId));
    final r = await q.getSingleOrNull();
    return r != null;
  }

  // History
  Future<List<String>> getHistoryChannelIds({int limit = 30}) async {
    final query = select(historyTable)
      ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
      ..limit(limit);
    final rows = await query.get();
    return rows.map((r) => r.channelId).toList();
  }

  Future<void> recordHistory(String channelId) async {
    await into(historyTable).insertOnConflictUpdate(
      HistoryTableCompanion.insert(
        channelId: channelId,
        playedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clearHistory() async {
    await delete(historyTable).go();
  }

  // Metadata / TTL
  Future<DateTime?> getLastCatalogFetchTime() async {
    final query = select(appMetaTable)..where((t) => t.metaKey.equals('last_catalog_fetch'));
    final row = await query.getSingleOrNull();
    if (row != null) {
      return DateTime.tryParse(row.metaValue);
    }
    return null;
  }

  Future<void> setLastCatalogFetchTime(DateTime time) async {
    await into(appMetaTable).insertOnConflictUpdate(
      AppMetaTableCompanion.insert(
        metaKey: 'last_catalog_fetch',
        metaValue: time.toIso8601String(),
      ),
    );
  }

  Channel _rowToChannel(ChannelsTableData row) {
    List<String> parseStringList(String jsonStr) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return const [];
    }

    List<StreamSource> parseStreams(String jsonStr) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          return decoded
              .map((e) => StreamSource.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
      return const [];
    }

    return Channel(
      id: row.id,
      name: row.name,
      altNames: parseStringList(row.altNames),
      network: row.network,
      countryCode: row.countryCode,
      countryName: row.countryName,
      countryFlag: row.countryFlag,
      categories: parseStringList(row.categories),
      logoUrl: row.logoUrl,
      streams: parseStreams(row.streamsJson),
      languages: parseStringList(row.languages),
      website: row.website,
      launched: row.launched,
    );
  }
}
