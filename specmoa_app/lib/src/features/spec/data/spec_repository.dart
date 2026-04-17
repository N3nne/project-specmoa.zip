import 'package:specmoa_app/src/core/api/api_client.dart';
import 'package:specmoa_app/src/features/spec/data/spec_models.dart';

class SpecRepository {
  SpecRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<MySpecItem>> fetchMySpecs(String userId) async {
    final json = await _apiClient.getJson(
      '/user-qualifications',
      queryParameters: {'userId': userId},
    );

    return (json['items'] as List<dynamic>? ?? [])
        .map((item) => MySpecItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MySpecItem> addMySpec({
    required String userId,
    required String qualificationCode,
  }) async {
    final json = await _apiClient.postJson(
      '/user-qualifications',
      body: {
        'userId': userId,
        'qualificationCode': qualificationCode,
        'status': 'preparing',
      },
    );

    return MySpecItem.fromJson(json);
  }
}
