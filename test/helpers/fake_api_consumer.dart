import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:transly_ai/core/network/api_consumer.dart';

/// Answers every GET and POST with [response], records the requested URLs, and
/// records each POST and DELETE with its body.
class FakeApiConsumer extends ApiConsumer {
  FakeApiConsumer([this.response = const {}]);

  final Map<String, dynamic> response;
  final List<String> requestedUrls = [];
  final List<(String, Map<String, dynamic>?)> postRequests = [];
  final List<(String, Map<String, dynamic>?)> deleteRequests = [];

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
  }) async {
    postRequests.add((url, data));
    return response;
  }

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

  @override
  Future<void> delete(String url, {Map<String, dynamic>? data}) async {
    deleteRequests.add((url, data));
  }
}
