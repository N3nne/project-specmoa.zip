import 'package:specmoa_app/src/core/api/api_client.dart';
import 'package:specmoa_app/src/features/home/data/home_models.dart';

class HomeRepository {
  HomeRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<HomeResponse> fetchHome(String userId) async {
    final json = await _apiClient.getJson(
      '/home',
      queryParameters: {'userId': userId},
    );
    return HomeResponse.fromJson(json);
  }
}
