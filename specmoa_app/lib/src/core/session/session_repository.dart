import 'package:specmoa_app/src/core/api/api_client.dart';
import 'package:specmoa_app/src/core/session/app_user.dart';

class SessionRepository {
  SessionRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;
  AppUser? _cachedUser;

  Future<AppUser> ensureDemoUser() async {
    if (_cachedUser != null) {
      return _cachedUser!;
    }

    final json = await _apiClient.postJson('/users/demo');
    _cachedUser = AppUser.fromJson(json);
    return _cachedUser!;
  }
}
