import 'package:specmoa_app/src/core/api/api_client.dart';
import 'package:specmoa_app/src/features/timer/data/timer_models.dart';

class TimerRepository {
  TimerRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ActiveStudySession> startSession({
    required String userId,
    required String userQualificationId,
  }) async {
    final json = await _apiClient.postJson(
      '/study-sessions/start',
      body: {
        'userId': userId,
        'userQualificationId': userQualificationId,
        'goalDurationSeconds': 1800,
      },
    );

    return ActiveStudySession.fromJson(json);
  }

  Future<void> stopSession(String sessionId) async {
    await _apiClient.patchJson('/study-sessions/$sessionId/stop');
  }

  Future<StudySessionSummary> fetchTodaySummary(String userId) async {
    final json = await _apiClient.getJson(
      '/study-sessions/summary/today',
      queryParameters: {'userId': userId},
    );

    return StudySessionSummary.fromJson(json);
  }
}
