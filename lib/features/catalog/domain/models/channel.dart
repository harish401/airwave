import 'stream_source.dart';

class Channel {
  final String id;
  final String name;
  final List<String> altNames;
  final String? network;
  final List<String> owners;
  final String countryCode;
  final String countryName;
  final String countryFlag;
  final List<String> categories;
  final String? logoUrl;
  final List<StreamSource> streams;
  final List<String> languages;
  final String? website;
  final bool isNsfw;
  final String? launched;
  final String? closed;

  const Channel({
    required this.id,
    required this.name,
    this.altNames = const [],
    this.network,
    this.owners = const [],
    this.countryCode = '',
    this.countryName = '',
    this.countryFlag = '',
    this.categories = const [],
    this.logoUrl,
    this.streams = const [],
    this.languages = const [],
    this.website,
    this.isNsfw = false,
    this.launched,
    this.closed,
  });

  bool get hasStreams => streams.isNotEmpty;
  StreamSource? get primaryStream => streams.isNotEmpty ? streams.first : null;

  String get initials {
    final clean = name.trim();
    if (clean.isEmpty) return 'TV';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  Channel copyWith({
    String? id,
    String? name,
    List<String>? altNames,
    String? network,
    List<String>? owners,
    String? countryCode,
    String? countryName,
    String? countryFlag,
    List<String>? categories,
    String? logoUrl,
    List<StreamSource>? streams,
    List<String>? languages,
    String? website,
    bool? isNsfw,
    String? launched,
    String? closed,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      altNames: altNames ?? this.altNames,
      network: network ?? this.network,
      owners: owners ?? this.owners,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      countryFlag: countryFlag ?? this.countryFlag,
      categories: categories ?? this.categories,
      logoUrl: logoUrl ?? this.logoUrl,
      streams: streams ?? this.streams,
      languages: languages ?? this.languages,
      website: website ?? this.website,
      isNsfw: isNsfw ?? this.isNsfw,
      launched: launched ?? this.launched,
      closed: closed ?? this.closed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'altNames': altNames,
        'network': network,
        'owners': owners,
        'countryCode': countryCode,
        'countryName': countryName,
        'countryFlag': countryFlag,
        'categories': categories,
        'logoUrl': logoUrl,
        'streams': streams.map((s) => s.toJson()).toList(),
        'languages': languages,
        'website': website,
        'isNsfw': isNsfw,
        'launched': launched,
        'closed': closed,
      };

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      altNames: (json['altNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      network: json['network']?.toString(),
      owners: (json['owners'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      countryCode: json['countryCode']?.toString() ?? '',
      countryName: json['countryName']?.toString() ?? '',
      countryFlag: json['countryFlag']?.toString() ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      logoUrl: json['logoUrl']?.toString(),
      streams: (json['streams'] as List<dynamic>?)
              ?.map((e) => StreamSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      website: json['website']?.toString(),
      isNsfw: json['isNsfw'] == true,
      launched: json['launched']?.toString(),
      closed: json['closed']?.toString(),
    );
  }
}
