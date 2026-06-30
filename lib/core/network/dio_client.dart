import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import 'api_endpoints.dart';

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    _LoggingInterceptor(),
    _ErrorInterceptor(),
  ]);

  return dio;
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[Dio] → ${options.method} ${options.path}');
      return true;
    }());
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[Dio] ✗ ${err.response?.statusCode} ${err.message}');
      return true;
    }());
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw const NetworkException();

      case DioExceptionType.badResponse:
        throw ServerException(
          message: err.response?.statusMessage ?? 'Server error.',
          statusCode: err.response?.statusCode,
        );

      default:
        throw const ServerException();
    }
  }
}
