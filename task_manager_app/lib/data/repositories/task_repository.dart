import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/pagination_model.dart';
import '../models/task_model.dart';

class TaskListResult {
  final List<TaskModel> tasks;
  final PaginationModel pagination;

  TaskListResult({required this.tasks, required this.pagination});
}

class TaskRepository {
  final ApiClient _apiClient;

  TaskRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<TaskListResult> getTasks({
    int page = 1,
    int limit = AppConstants.defaultPageLimit,
    TaskStatus? status,
    String? search,
    String sortBy = 'dueDate',
    String sortOrder = 'asc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (status != null) {
        queryParams['status'] = status.value;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.tasks,
        queryParameters: queryParams,
      );

      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final tasks = rawList
          .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
          .toList();
      final pagination = PaginationModel.fromJson(
        response.data['pagination'] as Map<String, dynamic>? ?? {},
      );

      return TaskListResult(tasks: tasks, pagination: pagination);
    } catch (e) {
      throw _apiClient.parseError(e);
    }
  }

  Future<TaskModel> getTaskById(int id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.taskById(id));
      return TaskModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _apiClient.parseError(e);
    }
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    required TaskStatus status,
    int? assigneeId,
    required String dueDate,
  }) async {
    try {
      final payload = {
        'title': title.trim(),
        'description': description?.trim(),
        'status': status.value,
        'assigneeId': assigneeId,
        'dueDate': dueDate,
      };

      final response = await _apiClient.dio.post(
        ApiEndpoints.tasks,
        data: payload,
      );

      return TaskModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _apiClient.parseError(e);
    }
  }

  Future<TaskModel> updateTask({
    required int id,
    String? title,
    String? description,
    TaskStatus? status,
    int? assigneeId,
    String? dueDate,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (title != null) payload['title'] = title.trim();
      if (description != null) payload['description'] = description.trim();
      if (status != null) payload['status'] = status.value;
      if (assigneeId != null) payload['assigneeId'] = assigneeId;
      if (dueDate != null) payload['dueDate'] = dueDate;

      final response = await _apiClient.dio.put(
        ApiEndpoints.taskById(id),
        data: payload,
      );

      return TaskModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _apiClient.parseError(e);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.taskById(id));
    } catch (e) {
      throw _apiClient.parseError(e);
    }
  }
}
