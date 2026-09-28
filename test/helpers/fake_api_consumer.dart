import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:transly_ai/core/network/api_consumer.dart';

/// Answers every GET with [response] and records the requested URLs.
class FakeApiConsumer extends ApiConsumer {
  FakeApiConsumer(this.response);

  final Map<String, dynamic> response;
  final List<String> requestedUrls = [];

  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    requestedUrls.add(url);
    return response;
  }

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
  }) => throw UnimplementedError();

  @override
  Future<Uint8List> getBytes(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) => throw UnimplementedError();
}
