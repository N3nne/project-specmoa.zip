import 'package:specmoa_app/src/core/api/api_client.dart';
import 'package:specmoa_app/src/core/session/app_user.dart';

class SessionRepository {
  SessionRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<AppUser> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.postJson(
      '/auth/signup',
      body: {
        'displayName': displayName,
        'email': email,
        'password': password,
      },
    );

    _currentUser = AppUser.fromJson(json);
    return _currentUser!;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.postJson(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    _currentUser = AppUser.fromJson(json);
    return _currentUser!;
  }

  Future<AppUser> requireAuthenticatedUser() async {
    if (_currentUser == null) {
      throw StateError('로그인된 사용자가 없습니다.');
    }

    return _currentUser!;
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}

