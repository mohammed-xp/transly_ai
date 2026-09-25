import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Thin abstraction over the HTTP client so data sources never depend on Dio
/// directly and can be unit-tested with a fake. Implementations throw
/// [DioException]; repositories map it to a `Failure` via `ErrorMapper`.
abstract class ApiConsumer {
  const ApiConsumer();

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  });

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
  });

  Future<Uint8List> getBytes(
    String url, {
    Map<String, dynamic>? queryParameters,
  });

  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  });
}
