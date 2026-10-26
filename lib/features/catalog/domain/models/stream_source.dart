class StreamSource {
  final String channel;
  final String? feed;
  final String? title;
  final String url;
  final String? referrer;
  final String? userAgent;
  final String? quality;
  final List<String> labels;
  final bool isGeoBlocked;
  final bool is247;
  final int height;

  const StreamSource({
    required this.channel,
    this.feed,
    this.title,
    required this.url,
    this.referrer,
    this.userAgent,
    this.quality,
    this.labels = const [],
    this.isGeoBlocked = false,
    this.is247 = true,
    this.height = 0,
  });

  factory StreamSource.fromJson(Map<String, dynamic> json) {
    final rawQuality = json['quality']?.toString();
    final labelsList = (json['labels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    final isGeo = labelsList.any((l) => l.toLowerCase().contains('geo-blocked'));
    final isNot247 = labelsList.any((l) => l.toLowerCase().contains('not 24/7'));

    int parsedHeight = 0;
    if (rawQuality != null) {
      final match = RegExp(r'(\d+)p?').firstMatch(rawQuality);
      if (match != null) {
        parsedHeight = int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }

    return StreamSource(
      channel: json['channel']?.toString() ?? '',
      feed: json['feed']?.toString(),
      title: json['title']?.toString(),
      url: json['url']?.toString() ?? '',
      referrer: json['referrer']?.toString(),
      userAgent: json['user_agent']?.toString(),
      quality: rawQuality,
      labels: labelsList,
      isGeoBlocked: isGeo,
      is247: !isNot247,
      height: parsedHeight,
    );
  }

  Map<String, dynamic> toJson() => {
        'channel': channel,
        'feed': feed,
        'title': title,
        'url': url,
        'referrer': referrer,
        'user_agent': userAgent,
        'quality': quality,
        'labels': labels,
        'isGeoBlocked': isGeoBlocked,
        'is247': is247,
        'height': height,
      };
}
