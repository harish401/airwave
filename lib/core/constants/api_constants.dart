class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://iptv-org.github.io/api';

  static const String channels = '$baseUrl/channels.json';
  static const String streams = '$baseUrl/streams.json';
  static const String logos = '$baseUrl/logos.json';
  static const String categories = '$baseUrl/categories.json';
  static const String countries = '$baseUrl/countries.json';
  static const String languages = '$baseUrl/languages.json';
  static const String feeds = '$baseUrl/feeds.json';
  static const String blocklist = '$baseUrl/blocklist.json';
  static const String guides = '$baseUrl/guides.json';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration catalogTtl = Duration(hours: 12);
  static const Duration playerStreamTimeout = Duration(seconds: 14);
}
