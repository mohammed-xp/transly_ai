import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../security/token_storage.dart';
import '../session/session_manager.dart';
import 'api_consumer.dart';
import 'endpoints.dart';

class DioBaseApi extends ApiConsumer {
  DioBaseApi(this._dio, this._tokenStorage, this._sessionManager) {
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          responseBody: true,
          filter: (options, _) => !_isAuthEndpoint(options.path),
        ),
      );
    }
  }

  static const _retriedKey = 'retried';

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final SessionManager _sessionManager;

  Future<bool>? _refreshInFlight;

  static bool _isAuthEndpoint(String path) =>
      path.contains(Endpoints.login) ||
      path.contains(Endpoints.register) ||
      path.contains(Endpoints.refreshToken);

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  /// A 401 from an authenticated endpoint means the access token was
  /// rejected: refresh once and replay the request, or end the session. A 401
  /// from login or register just means bad credentials and is passed through.
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isRejectedToken =
        err.response?.statusCode == 401 &&
        !_isAuthEndpoint(options.path) &&
        options.extra[_retriedKey] != true;

    if (!isRejectedToken) return handler.next(err);

    if (!await _refreshTokens()) {
      await _sessionManager.expire();
      return handler.next(err);
    }

    try {
      options.extra[_retriedKey] = true;
      options.headers.remove('Authorization');
      handler.resolve(await _dio.fetch(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Concurrent 401s share one refresh call instead of each starting their own.
  Future<bool> _refreshTokens() {
    return _refreshInFlight ??= _doRefresh().whenComplete(
      () => _refreshInFlight = null,
    );
  }

  Future<bool> _doRefresh() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await _dio.post(
        Endpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      final tokens = data is Map ? data['data'] : null;
      final newAccess = tokens is Map ? tokens['accessToken'] : null;
      if (newAccess is! String || newAccess.isEmpty) return false;

      final newRefresh = tokens['refreshToken'];
      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh is String && newRefresh.isNotEmpty
            ? newRefresh
            : refreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await _dio.get(url, queryParameters: queryParameters);
    return result.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await _dio.post(
      url,
      data: formData ?? data,
      queryParameters: queryParameters,
    );
    return result.data as Map<String, dynamic>;
  }

  @override
  Future<Uint8List> getBytes(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await _dio.get(
      url,
      queryParameters: queryParameters,
      options: Options(responseType: ResponseType.bytes),
    );
    return result.data as Uint8List;
  }

  @override
  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await _dio.put(
      url,
      data: data,
      queryParameters: queryParameters,
    );
    return result.data as Map<String, dynamic>;
  }

  @override
  Future<void> delete(String url, {Map<String, dynamic>? data}) async {
    await _dio.delete(url, data: data);
  }
}
