import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../features/catalog/data/catalog_parser.dart';
import '../../features/catalog/domain/models/taxonomy.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                headers: {
                  'Accept': 'application/json',
                  'User-Agent': 'Airwave/1.0.0 (Flutter; Mobile)',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          // Simple exponential backoff retry for network errors
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            try {
              final response = await _retry(error.requestOptions);
              return handler.resolve(response);
            } catch (_) {}
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<RawCatalogData> fetchAllCatalogData() async {
    // Fetch all 8 endpoints concurrently
    final results = await Future.wait([
      _fetchList(ApiConstants.channels),
      _fetchList(ApiConstants.streams),
      _fetchList(ApiConstants.logos),
      _fetchList(ApiConstants.feeds),
      _fetchList(ApiConstants.categories),
      _fetchList(ApiConstants.countries),
      _fetchList(ApiConstants.languages),
      _fetchList(ApiConstants.blocklist),
    ]);

    return RawCatalogData(
      channelsJson: results[0],
      streamsJson: results[1],
      logosJson: results[2],
      feedsJson: results[3],
      categoriesJson: results[4],
      countriesJson: results[5],
      languagesJson: results[6],
      blocklistJson: results[7],
    );
  }

  Future<List<dynamic>> _fetchList(String url) async {
    try {
      final response = await _dio.get<dynamic>(url);
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return const [];
    } catch (e) {
      // Degrade gracefully with empty list on single endpoint failure
      return const [];
    }
  }

  Future<List<BlockedChannel>> fetchBlocklistOnly() async {
    final raw = await _fetchList(ApiConstants.blocklist);
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => BlockedChannel.fromJson(e))
        .toList();
  }
}
