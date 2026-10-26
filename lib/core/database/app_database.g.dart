// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChannelsTableTable extends ChannelsTable
    with TableInfo<$ChannelsTableTable, ChannelsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altNamesMeta = const VerificationMeta(
    'altNames',
  );
  @override
  late final GeneratedColumn<String> altNames = GeneratedColumn<String>(
    'alt_names',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _networkMeta = const VerificationMeta(
    'network',
  );
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
    'network',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _countryNameMeta = const VerificationMeta(
    'countryName',
  );
  @override
  late final GeneratedColumn<String> countryName = GeneratedColumn<String>(
    'country_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _countryFlagMeta = const VerificationMeta(
    'countryFlag',
  );
  @override
  late final GeneratedColumn<String> countryFlag = GeneratedColumn<String>(
    'country_flag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoriesMeta = const VerificationMeta(
    'categories',
  );
  @override
  late final GeneratedColumn<String> categories = GeneratedColumn<String>(
    'categories',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streamsJsonMeta = const VerificationMeta(
    'streamsJson',
  );
  @override
  late final GeneratedColumn<String> streamsJson = GeneratedColumn<String>(
    'streams_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languagesMeta = const VerificationMeta(
    'languages',
  );
  @override
  late final GeneratedColumn<String> languages = GeneratedColumn<String>(
    'languages',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _websiteMeta = const VerificationMeta(
    'website',
  );
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
    'website',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _launchedMeta = const VerificationMeta(
    'launched',
  );
  @override
  late final GeneratedColumn<String> launched = GeneratedColumn<String>(
    'launched',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    altNames,
    network,
    countryCode,
    countryName,
    countryFlag,
    categories,
    logoUrl,
    streamsJson,
    languages,
    website,
    launched,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channels_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChannelsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('alt_names')) {
      context.handle(
        _altNamesMeta,
        altNames.isAcceptableOrUnknown(data['alt_names']!, _altNamesMeta),
      );
    }
    if (data.containsKey('network')) {
      context.handle(
        _networkMeta,
        network.isAcceptableOrUnknown(data['network']!, _networkMeta),
      );
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    }
    if (data.containsKey('country_name')) {
      context.handle(
        _countryNameMeta,
        countryName.isAcceptableOrUnknown(
          data['country_name']!,
          _countryNameMeta,
        ),
      );
    }
    if (data.containsKey('country_flag')) {
      context.handle(
        _countryFlagMeta,
        countryFlag.isAcceptableOrUnknown(
          data['country_flag']!,
          _countryFlagMeta,
        ),
      );
    }
    if (data.containsKey('categories')) {
      context.handle(
        _categoriesMeta,
        categories.isAcceptableOrUnknown(data['categories']!, _categoriesMeta),
      );
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('streams_json')) {
      context.handle(
        _streamsJsonMeta,
        streamsJson.isAcceptableOrUnknown(
          data['streams_json']!,
          _streamsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_streamsJsonMeta);
    }
    if (data.containsKey('languages')) {
      context.handle(
        _languagesMeta,
        languages.isAcceptableOrUnknown(data['languages']!, _languagesMeta),
      );
    }
    if (data.containsKey('website')) {
      context.handle(
        _websiteMeta,
        website.isAcceptableOrUnknown(data['website']!, _websiteMeta),
      );
    }
    if (data.containsKey('launched')) {
      context.handle(
        _launchedMeta,
        launched.isAcceptableOrUnknown(data['launched']!, _launchedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChannelsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChannelsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      altNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_names'],
      )!,
      network: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network'],
      ),
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      )!,
      countryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_name'],
      )!,
      countryFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_flag'],
      )!,
      categories: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categories'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      streamsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}streams_json'],
      )!,
      languages: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}languages'],
      )!,
      website: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website'],
      ),
      launched: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}launched'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChannelsTableTable createAlias(String alias) {
    return $ChannelsTableTable(attachedDatabase, alias);
  }
}

class ChannelsTableData extends DataClass
    implements Insertable<ChannelsTableData> {
  final String id;
  final String name;
  final String altNames;
  final String? network;
  final String countryCode;
  final String countryName;
  final String countryFlag;
  final String categories;
  final String? logoUrl;
  final String streamsJson;
  final String languages;
  final String? website;
  final String? launched;
  final DateTime updatedAt;
  const ChannelsTableData({
    required this.id,
    required this.name,
    required this.altNames,
    this.network,
    required this.countryCode,
    required this.countryName,
    required this.countryFlag,
    required this.categories,
    this.logoUrl,
    required this.streamsJson,
    required this.languages,
    this.website,
    this.launched,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['alt_names'] = Variable<String>(altNames);
    if (!nullToAbsent || network != null) {
      map['network'] = Variable<String>(network);
    }
    map['country_code'] = Variable<String>(countryCode);
    map['country_name'] = Variable<String>(countryName);
    map['country_flag'] = Variable<String>(countryFlag);
    map['categories'] = Variable<String>(categories);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    map['streams_json'] = Variable<String>(streamsJson);
    map['languages'] = Variable<String>(languages);
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || launched != null) {
      map['launched'] = Variable<String>(launched);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChannelsTableCompanion toCompanion(bool nullToAbsent) {
    return ChannelsTableCompanion(
      id: Value(id),
      name: Value(name),
      altNames: Value(altNames),
      network: network == null && nullToAbsent
          ? const Value.absent()
          : Value(network),
      countryCode: Value(countryCode),
      countryName: Value(countryName),
      countryFlag: Value(countryFlag),
      categories: Value(categories),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      streamsJson: Value(streamsJson),
      languages: Value(languages),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      launched: launched == null && nullToAbsent
          ? const Value.absent()
          : Value(launched),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChannelsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChannelsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      altNames: serializer.fromJson<String>(json['altNames']),
      network: serializer.fromJson<String?>(json['network']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      countryName: serializer.fromJson<String>(json['countryName']),
      countryFlag: serializer.fromJson<String>(json['countryFlag']),
      categories: serializer.fromJson<String>(json['categories']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      streamsJson: serializer.fromJson<String>(json['streamsJson']),
      languages: serializer.fromJson<String>(json['languages']),
      website: serializer.fromJson<String?>(json['website']),
      launched: serializer.fromJson<String?>(json['launched']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'altNames': serializer.toJson<String>(altNames),
      'network': serializer.toJson<String?>(network),
      'countryCode': serializer.toJson<String>(countryCode),
      'countryName': serializer.toJson<String>(countryName),
      'countryFlag': serializer.toJson<String>(countryFlag),
      'categories': serializer.toJson<String>(categories),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'streamsJson': serializer.toJson<String>(streamsJson),
      'languages': serializer.toJson<String>(languages),
      'website': serializer.toJson<String?>(website),
      'launched': serializer.toJson<String?>(launched),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChannelsTableData copyWith({
    String? id,
    String? name,
    String? altNames,
    Value<String?> network = const Value.absent(),
    String? countryCode,
    String? countryName,
    String? countryFlag,
    String? categories,
    Value<String?> logoUrl = const Value.absent(),
    String? streamsJson,
    String? languages,
    Value<String?> website = const Value.absent(),
    Value<String?> launched = const Value.absent(),
    DateTime? updatedAt,
  }) => ChannelsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    altNames: altNames ?? this.altNames,
    network: network.present ? network.value : this.network,
    countryCode: countryCode ?? this.countryCode,
    countryName: countryName ?? this.countryName,
    countryFlag: countryFlag ?? this.countryFlag,
    categories: categories ?? this.categories,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    streamsJson: streamsJson ?? this.streamsJson,
    languages: languages ?? this.languages,
    website: website.present ? website.value : this.website,
    launched: launched.present ? launched.value : this.launched,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChannelsTableData copyWithCompanion(ChannelsTableCompanion data) {
    return ChannelsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      altNames: data.altNames.present ? data.altNames.value : this.altNames,
      network: data.network.present ? data.network.value : this.network,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      countryName: data.countryName.present
          ? data.countryName.value
          : this.countryName,
      countryFlag: data.countryFlag.present
          ? data.countryFlag.value
          : this.countryFlag,
      categories: data.categories.present
          ? data.categories.value
          : this.categories,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      streamsJson: data.streamsJson.present
          ? data.streamsJson.value
          : this.streamsJson,
      languages: data.languages.present ? data.languages.value : this.languages,
      website: data.website.present ? data.website.value : this.website,
      launched: data.launched.present ? data.launched.value : this.launched,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('altNames: $altNames, ')
          ..write('network: $network, ')
          ..write('countryCode: $countryCode, ')
          ..write('countryName: $countryName, ')
          ..write('countryFlag: $countryFlag, ')
          ..write('categories: $categories, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('streamsJson: $streamsJson, ')
          ..write('languages: $languages, ')
          ..write('website: $website, ')
          ..write('launched: $launched, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    altNames,
    network,
    countryCode,
    countryName,
    countryFlag,
    categories,
    logoUrl,
    streamsJson,
    languages,
    website,
    launched,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChannelsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.altNames == this.altNames &&
          other.network == this.network &&
          other.countryCode == this.countryCode &&
          other.countryName == this.countryName &&
          other.countryFlag == this.countryFlag &&
          other.categories == this.categories &&
          other.logoUrl == this.logoUrl &&
          other.streamsJson == this.streamsJson &&
          other.languages == this.languages &&
          other.website == this.website &&
          other.launched == this.launched &&
          other.updatedAt == this.updatedAt);
}

class ChannelsTableCompanion extends UpdateCompanion<ChannelsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> altNames;
  final Value<String?> network;
  final Value<String> countryCode;
  final Value<String> countryName;
  final Value<String> countryFlag;
  final Value<String> categories;
  final Value<String?> logoUrl;
  final Value<String> streamsJson;
  final Value<String> languages;
  final Value<String?> website;
  final Value<String?> launched;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChannelsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.altNames = const Value.absent(),
    this.network = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.countryName = const Value.absent(),
    this.countryFlag = const Value.absent(),
    this.categories = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.streamsJson = const Value.absent(),
    this.languages = const Value.absent(),
    this.website = const Value.absent(),
    this.launched = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChannelsTableCompanion.insert({
    required String id,
    required String name,
    this.altNames = const Value.absent(),
    this.network = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.countryName = const Value.absent(),
    this.countryFlag = const Value.absent(),
    this.categories = const Value.absent(),
    this.logoUrl = const Value.absent(),
    required String streamsJson,
    this.languages = const Value.absent(),
    this.website = const Value.absent(),
    this.launched = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       streamsJson = Value(streamsJson);
  static Insertable<ChannelsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? altNames,
    Expression<String>? network,
    Expression<String>? countryCode,
    Expression<String>? countryName,
    Expression<String>? countryFlag,
    Expression<String>? categories,
    Expression<String>? logoUrl,
    Expression<String>? streamsJson,
    Expression<String>? languages,
    Expression<String>? website,
    Expression<String>? launched,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (altNames != null) 'alt_names': altNames,
      if (network != null) 'network': network,
      if (countryCode != null) 'country_code': countryCode,
      if (countryName != null) 'country_name': countryName,
      if (countryFlag != null) 'country_flag': countryFlag,
      if (categories != null) 'categories': categories,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (streamsJson != null) 'streams_json': streamsJson,
      if (languages != null) 'languages': languages,
      if (website != null) 'website': website,
      if (launched != null) 'launched': launched,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChannelsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? altNames,
    Value<String?>? network,
    Value<String>? countryCode,
    Value<String>? countryName,
    Value<String>? countryFlag,
    Value<String>? categories,
    Value<String?>? logoUrl,
    Value<String>? streamsJson,
    Value<String>? languages,
    Value<String?>? website,
    Value<String?>? launched,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChannelsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      altNames: altNames ?? this.altNames,
      network: network ?? this.network,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      countryFlag: countryFlag ?? this.countryFlag,
      categories: categories ?? this.categories,
      logoUrl: logoUrl ?? this.logoUrl,
      streamsJson: streamsJson ?? this.streamsJson,
      languages: languages ?? this.languages,
      website: website ?? this.website,
      launched: launched ?? this.launched,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (altNames.present) {
      map['alt_names'] = Variable<String>(altNames.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (countryName.present) {
      map['country_name'] = Variable<String>(countryName.value);
    }
    if (countryFlag.present) {
      map['country_flag'] = Variable<String>(countryFlag.value);
    }
    if (categories.present) {
      map['categories'] = Variable<String>(categories.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (streamsJson.present) {
      map['streams_json'] = Variable<String>(streamsJson.value);
    }
    if (languages.present) {
      map['languages'] = Variable<String>(languages.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (launched.present) {
      map['launched'] = Variable<String>(launched.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('altNames: $altNames, ')
          ..write('network: $network, ')
          ..write('countryCode: $countryCode, ')
          ..write('countryName: $countryName, ')
          ..write('countryFlag: $countryFlag, ')
          ..write('categories: $categories, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('streamsJson: $streamsJson, ')
          ..write('languages: $languages, ')
          ..write('website: $website, ')
          ..write('launched: $launched, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTableTable extends FavoritesTable
    with TableInfo<$FavoritesTableTable, FavoritesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [channelId, addedAt, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoritesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {channelId};
  @override
  FavoritesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoritesTableData(
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $FavoritesTableTable createAlias(String alias) {
    return $FavoritesTableTable(attachedDatabase, alias);
  }
}

class FavoritesTableData extends DataClass
    implements Insertable<FavoritesTableData> {
  final String channelId;
  final DateTime addedAt;
  final int orderIndex;
  const FavoritesTableData({
    required this.channelId,
    required this.addedAt,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['channel_id'] = Variable<String>(channelId);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  FavoritesTableCompanion toCompanion(bool nullToAbsent) {
    return FavoritesTableCompanion(
      channelId: Value(channelId),
      addedAt: Value(addedAt),
      orderIndex: Value(orderIndex),
    );
  }

  factory FavoritesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoritesTableData(
      channelId: serializer.fromJson<String>(json['channelId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'channelId': serializer.toJson<String>(channelId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  FavoritesTableData copyWith({
    String? channelId,
    DateTime? addedAt,
    int? orderIndex,
  }) => FavoritesTableData(
    channelId: channelId ?? this.channelId,
    addedAt: addedAt ?? this.addedAt,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  FavoritesTableData copyWithCompanion(FavoritesTableCompanion data) {
    return FavoritesTableData(
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesTableData(')
          ..write('channelId: $channelId, ')
          ..write('addedAt: $addedAt, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(channelId, addedAt, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoritesTableData &&
          other.channelId == this.channelId &&
          other.addedAt == this.addedAt &&
          other.orderIndex == this.orderIndex);
}

class FavoritesTableCompanion extends UpdateCompanion<FavoritesTableData> {
  final Value<String> channelId;
  final Value<DateTime> addedAt;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const FavoritesTableCompanion({
    this.channelId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesTableCompanion.insert({
    required String channelId,
    this.addedAt = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : channelId = Value(channelId);
  static Insertable<FavoritesTableData> custom({
    Expression<String>? channelId,
    Expression<DateTime>? addedAt,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (channelId != null) 'channel_id': channelId,
      if (addedAt != null) 'added_at': addedAt,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesTableCompanion copyWith({
    Value<String>? channelId,
    Value<DateTime>? addedAt,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return FavoritesTableCompanion(
      channelId: channelId ?? this.channelId,
      addedAt: addedAt ?? this.addedAt,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesTableCompanion(')
          ..write('channelId: $channelId, ')
          ..write('addedAt: $addedAt, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryTableTable extends HistoryTable
    with TableInfo<$HistoryTableTable, HistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [channelId, playedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {channelId};
  @override
  HistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryTableData(
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $HistoryTableTable createAlias(String alias) {
    return $HistoryTableTable(attachedDatabase, alias);
  }
}

class HistoryTableData extends DataClass
    implements Insertable<HistoryTableData> {
  final String channelId;
  final DateTime playedAt;
  const HistoryTableData({required this.channelId, required this.playedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['channel_id'] = Variable<String>(channelId);
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  HistoryTableCompanion toCompanion(bool nullToAbsent) {
    return HistoryTableCompanion(
      channelId: Value(channelId),
      playedAt: Value(playedAt),
    );
  }

  factory HistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryTableData(
      channelId: serializer.fromJson<String>(json['channelId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'channelId': serializer.toJson<String>(channelId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  HistoryTableData copyWith({String? channelId, DateTime? playedAt}) =>
      HistoryTableData(
        channelId: channelId ?? this.channelId,
        playedAt: playedAt ?? this.playedAt,
      );
  HistoryTableData copyWithCompanion(HistoryTableCompanion data) {
    return HistoryTableData(
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryTableData(')
          ..write('channelId: $channelId, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(channelId, playedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryTableData &&
          other.channelId == this.channelId &&
          other.playedAt == this.playedAt);
}

class HistoryTableCompanion extends UpdateCompanion<HistoryTableData> {
  final Value<String> channelId;
  final Value<DateTime> playedAt;
  final Value<int> rowid;
  const HistoryTableCompanion({
    this.channelId = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistoryTableCompanion.insert({
    required String channelId,
    this.playedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : channelId = Value(channelId);
  static Insertable<HistoryTableData> custom({
    Expression<String>? channelId,
    Expression<DateTime>? playedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (channelId != null) 'channel_id': channelId,
      if (playedAt != null) 'played_at': playedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryTableCompanion copyWith({
    Value<String>? channelId,
    Value<DateTime>? playedAt,
    Value<int>? rowid,
  }) {
    return HistoryTableCompanion(
      channelId: channelId ?? this.channelId,
      playedAt: playedAt ?? this.playedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryTableCompanion(')
          ..write('channelId: $channelId, ')
          ..write('playedAt: $playedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTableTable extends AppMetaTable
    with TableInfo<$AppMetaTableTable, AppMetaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _metaKeyMeta = const VerificationMeta(
    'metaKey',
  );
  @override
  late final GeneratedColumn<String> metaKey = GeneratedColumn<String>(
    'meta_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaValueMeta = const VerificationMeta(
    'metaValue',
  );
  @override
  late final GeneratedColumn<String> metaValue = GeneratedColumn<String>(
    'meta_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [metaKey, metaValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meta_key')) {
      context.handle(
        _metaKeyMeta,
        metaKey.isAcceptableOrUnknown(data['meta_key']!, _metaKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_metaKeyMeta);
    }
    if (data.containsKey('meta_value')) {
      context.handle(
        _metaValueMeta,
        metaValue.isAcceptableOrUnknown(data['meta_value']!, _metaValueMeta),
      );
    } else if (isInserting) {
      context.missing(_metaValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metaKey};
  @override
  AppMetaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaTableData(
      metaKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_key'],
      )!,
      metaValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_value'],
      )!,
    );
  }

  @override
  $AppMetaTableTable createAlias(String alias) {
    return $AppMetaTableTable(attachedDatabase, alias);
  }
}

class AppMetaTableData extends DataClass
    implements Insertable<AppMetaTableData> {
  final String metaKey;
  final String metaValue;
  const AppMetaTableData({required this.metaKey, required this.metaValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meta_key'] = Variable<String>(metaKey);
    map['meta_value'] = Variable<String>(metaValue);
    return map;
  }

  AppMetaTableCompanion toCompanion(bool nullToAbsent) {
    return AppMetaTableCompanion(
      metaKey: Value(metaKey),
      metaValue: Value(metaValue),
    );
  }

  factory AppMetaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaTableData(
      metaKey: serializer.fromJson<String>(json['metaKey']),
      metaValue: serializer.fromJson<String>(json['metaValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'metaKey': serializer.toJson<String>(metaKey),
      'metaValue': serializer.toJson<String>(metaValue),
    };
  }

  AppMetaTableData copyWith({String? metaKey, String? metaValue}) =>
      AppMetaTableData(
        metaKey: metaKey ?? this.metaKey,
        metaValue: metaValue ?? this.metaValue,
      );
  AppMetaTableData copyWithCompanion(AppMetaTableCompanion data) {
    return AppMetaTableData(
      metaKey: data.metaKey.present ? data.metaKey.value : this.metaKey,
      metaValue: data.metaValue.present ? data.metaValue.value : this.metaValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaTableData(')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(metaKey, metaValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaTableData &&
          other.metaKey == this.metaKey &&
          other.metaValue == this.metaValue);
}

class AppMetaTableCompanion extends UpdateCompanion<AppMetaTableData> {
  final Value<String> metaKey;
  final Value<String> metaValue;
  final Value<int> rowid;
  const AppMetaTableCompanion({
    this.metaKey = const Value.absent(),
    this.metaValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaTableCompanion.insert({
    required String metaKey,
    required String metaValue,
    this.rowid = const Value.absent(),
  }) : metaKey = Value(metaKey),
       metaValue = Value(metaValue);
  static Insertable<AppMetaTableData> custom({
    Expression<String>? metaKey,
    Expression<String>? metaValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (metaKey != null) 'meta_key': metaKey,
      if (metaValue != null) 'meta_value': metaValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaTableCompanion copyWith({
    Value<String>? metaKey,
    Value<String>? metaValue,
    Value<int>? rowid,
  }) {
    return AppMetaTableCompanion(
      metaKey: metaKey ?? this.metaKey,
      metaValue: metaValue ?? this.metaValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (metaKey.present) {
      map['meta_key'] = Variable<String>(metaKey.value);
    }
    if (metaValue.present) {
      map['meta_value'] = Variable<String>(metaValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaTableCompanion(')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChannelsTableTable channelsTable = $ChannelsTableTable(this);
  late final $FavoritesTableTable favoritesTable = $FavoritesTableTable(this);
  late final $HistoryTableTable historyTable = $HistoryTableTable(this);
  late final $AppMetaTableTable appMetaTable = $AppMetaTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    channelsTable,
    favoritesTable,
    historyTable,
    appMetaTable,
  ];
}

typedef $$ChannelsTableTableCreateCompanionBuilder =
    ChannelsTableCompanion Function({
      required String id,
      required String name,
      Value<String> altNames,
      Value<String?> network,
      Value<String> countryCode,
      Value<String> countryName,
      Value<String> countryFlag,
      Value<String> categories,
      Value<String?> logoUrl,
      required String streamsJson,
      Value<String> languages,
      Value<String?> website,
      Value<String?> launched,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ChannelsTableTableUpdateCompanionBuilder =
    ChannelsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> altNames,
      Value<String?> network,
      Value<String> countryCode,
      Value<String> countryName,
      Value<String> countryFlag,
      Value<String> categories,
      Value<String?> logoUrl,
      Value<String> streamsJson,
      Value<String> languages,
      Value<String?> website,
      Value<String?> launched,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ChannelsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChannelsTableTable> {
  $$ChannelsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get altNames => $composableBuilder(
    column: $table.altNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryName => $composableBuilder(
    column: $table.countryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryFlag => $composableBuilder(
    column: $table.countryFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamsJson => $composableBuilder(
    column: $table.streamsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languages => $composableBuilder(
    column: $table.languages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get launched => $composableBuilder(
    column: $table.launched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChannelsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChannelsTableTable> {
  $$ChannelsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get altNames => $composableBuilder(
    column: $table.altNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryName => $composableBuilder(
    column: $table.countryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryFlag => $composableBuilder(
    column: $table.countryFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamsJson => $composableBuilder(
    column: $table.streamsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languages => $composableBuilder(
    column: $table.languages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get launched => $composableBuilder(
    column: $table.launched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChannelsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChannelsTableTable> {
  $$ChannelsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get altNames =>
      $composableBuilder(column: $table.altNames, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryName => $composableBuilder(
    column: $table.countryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryFlag => $composableBuilder(
    column: $table.countryFlag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get streamsJson => $composableBuilder(
    column: $table.streamsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languages =>
      $composableBuilder(column: $table.languages, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get launched =>
      $composableBuilder(column: $table.launched, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChannelsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChannelsTableTable,
          ChannelsTableData,
          $$ChannelsTableTableFilterComposer,
          $$ChannelsTableTableOrderingComposer,
          $$ChannelsTableTableAnnotationComposer,
          $$ChannelsTableTableCreateCompanionBuilder,
          $$ChannelsTableTableUpdateCompanionBuilder,
          (
            ChannelsTableData,
            BaseReferences<
              _$AppDatabase,
              $ChannelsTableTable,
              ChannelsTableData
            >,
          ),
          ChannelsTableData,
          PrefetchHooks Function()
        > {
  $$ChannelsTableTableTableManager(_$AppDatabase db, $ChannelsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> altNames = const Value.absent(),
                Value<String?> network = const Value.absent(),
                Value<String> countryCode = const Value.absent(),
                Value<String> countryName = const Value.absent(),
                Value<String> countryFlag = const Value.absent(),
                Value<String> categories = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String> streamsJson = const Value.absent(),
                Value<String> languages = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String?> launched = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelsTableCompanion(
                id: id,
                name: name,
                altNames: altNames,
                network: network,
                countryCode: countryCode,
                countryName: countryName,
                countryFlag: countryFlag,
                categories: categories,
                logoUrl: logoUrl,
                streamsJson: streamsJson,
                languages: languages,
                website: website,
                launched: launched,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> altNames = const Value.absent(),
                Value<String?> network = const Value.absent(),
                Value<String> countryCode = const Value.absent(),
                Value<String> countryName = const Value.absent(),
                Value<String> countryFlag = const Value.absent(),
                Value<String> categories = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                required String streamsJson,
                Value<String> languages = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String?> launched = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelsTableCompanion.insert(
                id: id,
                name: name,
                altNames: altNames,
                network: network,
                countryCode: countryCode,
                countryName: countryName,
                countryFlag: countryFlag,
                categories: categories,
                logoUrl: logoUrl,
                streamsJson: streamsJson,
                languages: languages,
                website: website,
                launched: launched,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChannelsTableTable, ChannelsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ChannelsTableTable,
                    ChannelsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChannelsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChannelsTableTable,
      ChannelsTableData,
      $$ChannelsTableTableFilterComposer,
      $$ChannelsTableTableOrderingComposer,
      $$ChannelsTableTableAnnotationComposer,
      $$ChannelsTableTableCreateCompanionBuilder,
      $$ChannelsTableTableUpdateCompanionBuilder,
      (
        ChannelsTableData,
        BaseReferences<_$AppDatabase, $ChannelsTableTable, ChannelsTableData>,
      ),
      ChannelsTableData,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableTableCreateCompanionBuilder =
    FavoritesTableCompanion Function({
      required String channelId,
      Value<DateTime> addedAt,
      Value<int> orderIndex,
      Value<int> rowid,
    });
typedef $$FavoritesTableTableUpdateCompanionBuilder =
    FavoritesTableCompanion Function({
      Value<String> channelId,
      Value<DateTime> addedAt,
      Value<int> orderIndex,
      Value<int> rowid,
    });

class $$FavoritesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$FavoritesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTableTable,
          FavoritesTableData,
          $$FavoritesTableTableFilterComposer,
          $$FavoritesTableTableOrderingComposer,
          $$FavoritesTableTableAnnotationComposer,
          $$FavoritesTableTableCreateCompanionBuilder,
          $$FavoritesTableTableUpdateCompanionBuilder,
          (
            FavoritesTableData,
            BaseReferences<
              _$AppDatabase,
              $FavoritesTableTable,
              FavoritesTableData
            >,
          ),
          FavoritesTableData,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableTableManager(
    _$AppDatabase db,
    $FavoritesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> channelId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesTableCompanion(
                channelId: channelId,
                addedAt: addedAt,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String channelId,
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesTableCompanion.insert(
                channelId: channelId,
                addedAt: addedAt,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTableTable, FavoritesTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FavoritesTableTable,
                    FavoritesTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTableTable,
      FavoritesTableData,
      $$FavoritesTableTableFilterComposer,
      $$FavoritesTableTableOrderingComposer,
      $$FavoritesTableTableAnnotationComposer,
      $$FavoritesTableTableCreateCompanionBuilder,
      $$FavoritesTableTableUpdateCompanionBuilder,
      (
        FavoritesTableData,
        BaseReferences<_$AppDatabase, $FavoritesTableTable, FavoritesTableData>,
      ),
      FavoritesTableData,
      PrefetchHooks Function()
    >;
typedef $$HistoryTableTableCreateCompanionBuilder =
    HistoryTableCompanion Function({
      required String channelId,
      Value<DateTime> playedAt,
      Value<int> rowid,
    });
typedef $$HistoryTableTableUpdateCompanionBuilder =
    HistoryTableCompanion Function({
      Value<String> channelId,
      Value<DateTime> playedAt,
      Value<int> rowid,
    });

class $$HistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);
}

class $$HistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryTableTable,
          HistoryTableData,
          $$HistoryTableTableFilterComposer,
          $$HistoryTableTableOrderingComposer,
          $$HistoryTableTableAnnotationComposer,
          $$HistoryTableTableCreateCompanionBuilder,
          $$HistoryTableTableUpdateCompanionBuilder,
          (
            HistoryTableData,
            BaseReferences<_$AppDatabase, $HistoryTableTable, HistoryTableData>,
          ),
          HistoryTableData,
          PrefetchHooks Function()
        > {
  $$HistoryTableTableTableManager(_$AppDatabase db, $HistoryTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> channelId = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryTableCompanion(
                channelId: channelId,
                playedAt: playedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String channelId,
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryTableCompanion.insert(
                channelId: channelId,
                playedAt: playedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HistoryTableTable, HistoryTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HistoryTableTable,
                    HistoryTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryTableTable,
      HistoryTableData,
      $$HistoryTableTableFilterComposer,
      $$HistoryTableTableOrderingComposer,
      $$HistoryTableTableAnnotationComposer,
      $$HistoryTableTableCreateCompanionBuilder,
      $$HistoryTableTableUpdateCompanionBuilder,
      (
        HistoryTableData,
        BaseReferences<_$AppDatabase, $HistoryTableTable, HistoryTableData>,
      ),
      HistoryTableData,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableTableCreateCompanionBuilder =
    AppMetaTableCompanion Function({
      required String metaKey,
      required String metaValue,
      Value<int> rowid,
    });
typedef $$AppMetaTableTableUpdateCompanionBuilder =
    AppMetaTableCompanion Function({
      Value<String> metaKey,
      Value<String> metaValue,
      Value<int> rowid,
    });

class $$AppMetaTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTableTable> {
  $$AppMetaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metaValue => $composableBuilder(
    column: $table.metaValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTableTable> {
  $$AppMetaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metaValue => $composableBuilder(
    column: $table.metaValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTableTable> {
  $$AppMetaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get metaKey =>
      $composableBuilder(column: $table.metaKey, builder: (column) => column);

  GeneratedColumn<String> get metaValue =>
      $composableBuilder(column: $table.metaValue, builder: (column) => column);
}

class $$AppMetaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTableTable,
          AppMetaTableData,
          $$AppMetaTableTableFilterComposer,
          $$AppMetaTableTableOrderingComposer,
          $$AppMetaTableTableAnnotationComposer,
          $$AppMetaTableTableCreateCompanionBuilder,
          $$AppMetaTableTableUpdateCompanionBuilder,
          (
            AppMetaTableData,
            BaseReferences<_$AppDatabase, $AppMetaTableTable, AppMetaTableData>,
          ),
          AppMetaTableData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableTableManager(_$AppDatabase db, $AppMetaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> metaKey = const Value.absent(),
                Value<String> metaValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaTableCompanion(
                metaKey: metaKey,
                metaValue: metaValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String metaKey,
                required String metaValue,
                Value<int> rowid = const Value.absent(),
              }) => AppMetaTableCompanion.insert(
                metaKey: metaKey,
                metaValue: metaValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTableTable, AppMetaTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppMetaTableTable,
                    AppMetaTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTableTable,
      AppMetaTableData,
      $$AppMetaTableTableFilterComposer,
      $$AppMetaTableTableOrderingComposer,
      $$AppMetaTableTableAnnotationComposer,
      $$AppMetaTableTableCreateCompanionBuilder,
      $$AppMetaTableTableUpdateCompanionBuilder,
      (
        AppMetaTableData,
        BaseReferences<_$AppDatabase, $AppMetaTableTable, AppMetaTableData>,
      ),
      AppMetaTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChannelsTableTableTableManager get channelsTable =>
      $$ChannelsTableTableTableManager(_db, _db.channelsTable);
  $$FavoritesTableTableTableManager get favoritesTable =>
      $$FavoritesTableTableTableManager(_db, _db.favoritesTable);
  $$HistoryTableTableTableManager get historyTable =>
      $$HistoryTableTableTableManager(_db, _db.historyTable);
  $$AppMetaTableTableTableManager get appMetaTable =>
      $$AppMetaTableTableTableManager(_db, _db.appMetaTable);
}
