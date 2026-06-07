import 'package:dio/dio.dart';
import '../../core/constants.dart';

/// HTTP 客户端封装
///
/// 统一处理超时、重试、错误格式化。
/// 所有 API 调用通过此客户端发起。
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: AppConstants.requestTimeout,
      receiveTimeout: AppConstants.requestTimeout,
      headers: {
        'User-Agent': 'StockCal/1.0',
        'Accept': 'application/json',
      },
    ));

    // 日志拦截器（仅在 debug 模式输出）
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      error: true,
    ));
  }

  /// GET 请求，带自动重试
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    int retries = AppConstants.maxRetries,
  }) async {
    for (int i = 0; i <= retries; i++) {
      try {
        final response = await _dio.get(
          url,
          queryParameters: queryParameters,
        );
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else if (response.data is List) {
          return {'data': response.data};
        }
        return {'data': response.data};
      } on DioException catch (_) {
        if (i == retries) rethrow;
        await Future.delayed(
          Duration(milliseconds: 500 * (i + 1)),
        );
      }
    }
    return {}; // unreachable
  }

  /// POST 请求
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'data': response.data};
    } on DioException {
      rethrow;
    }
  }

  void dispose() {
    _dio.close();
  }
}
