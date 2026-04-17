import 'package:specmoa_app/src/core/api/api_client.dart';
import 'package:specmoa_app/src/features/my/data/my_models.dart';

class MyRepository {
  MyRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<MyResponse> fetchMy(String userId) async {
    final json = await _apiClient.getJson(
      '/my',
      queryParameters: {'userId': userId},
    );

    return MyResponse.fromJson(json);
  }

  Future<WeeklyGoalData> updateWeeklyGoal({
    required String userId,
    required int targetHours,
    required bool notificationEnabled,
  }) async {
    final json = await _apiClient.patchJson(
      '/my/weekly-goal',
      body: {
        'userId': userId,
        'targetHours': targetHours,
        'notificationEnabled': notificationEnabled,
      },
    );

    return WeeklyGoalData.fromJson(json);
  }

  Future<UserSettingItem> updateNotificationsSetting({
    required String userId,
    required bool pushEnabled,
  }) async {
    final json = await _apiClient.patchJson(
      '/my/settings',
      body: {
        'userId': userId,
        'key': 'notifications',
        'value': {
          'pushEnabled': pushEnabled,
          'marketingEnabled': false,
        },
      },
    );

    return UserSettingItem.fromJson(json);
  }
}
