import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:specmoa_app/src/core/api/api_exception.dart';
import 'package:specmoa_app/src/core/config/api_config.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: queryParameters,
    );
    final response = await _client.get(uri);

    _throwIfFailed(response);

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: queryParameters,
    );
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    _throwIfFailed(response);

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    _throwIfFailed(response);

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteJson(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.delete(uri);

    _throwIfFailed(response);

    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message = '요청에 실패했습니다.';

    if (response.body.isNotEmpty) {
      try {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic>) {
          final errorMessage = json['message'];
          if (errorMessage is String && errorMessage.trim().isNotEmpty) {
            message = errorMessage;
          } else if (errorMessage is List && errorMessage.isNotEmpty) {
            message = errorMessage.first.toString();
          } else if (json['error'] is String) {
            message = json['error'] as String;
          }
        }
      } catch (_) {
        message = response.body;
      }
    }

    throw ApiException(
      message: message,
      statusCode: response.statusCode,
    );
  }
}
