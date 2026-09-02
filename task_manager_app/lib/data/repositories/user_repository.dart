import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<UserModel>> getTeamMembers() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.users);
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      return rawList
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _apiClient.parseError(e);
    }
  }
}
