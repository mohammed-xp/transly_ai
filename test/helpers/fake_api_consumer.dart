import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:transly_ai/core/network/api_consumer.dart';
import 'package:transly_ai/core/network/api_response.dart';

/// Answers every GET and POST with [response], records the requested URLs, and
/// records each POST and DELETE with its body. Multipart posts get
/// [responseHeaders] too, or throw [multipartError] when set.
class FakeApiConsumer extends ApiConsumer {
  FakeApiConsumer([this.response = const {}]);

  Map<String, dynamic> response;
  Map<String, List<String>> responseHeaders = const {};
  Object? multipartError;
  final List<String> requestedUrls = [];
  final List<(String, Map<String, dynamic>?)> postRequests = [];
  final List<(String, Map<String, dynamic>?)> deleteRequests = [];
  final List<(String, FormData, Duration?)> multipartRequests = [];

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
  Future<ApiResponse> postMultipart(
    String url, {
    required FormData formData,
    Duration? receiveTimeout,
  }) async {
    multipartRequests.add((url, formData, receiveTimeout));
    final error = multipartError;
    if (error != null) throw error;
    return ApiResponse(data: response, headers: responseHeaders);
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
