import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_app/data/models/task_model.dart';
import 'package:task_manager_app/data/models/user_model.dart';
import 'package:task_manager_app/data/models/pagination_model.dart';
import 'package:task_manager_app/data/models/auth_response_model.dart';

void main() {
  group('Data Models Tests', () {
    test('UserModel serialization and initials extraction', () {
      const user = UserModel(
        id: 1,
        name: 'Alex Johnson',
        email: 'alex@example.com',
      );
      expect(user.initials, 'AJ');
      expect(user.toJson()['email'], 'alex@example.com');

      final deserialized = UserModel.fromJson({
        'id': 2,
        'name': 'Sarah',
        'email': 'sarah@example.com',
      });
      expect(deserialized.id, 2);
      expect(deserialized.initials, 'SA');
    });

    test('TaskModel serialization and status handling', () {
      final json = {
        'id': 10,
        'title': 'Test Task',
        'description': 'A task for unit testing',
        'status': 'IN_PROGRESS',
        'dueDate': '2026-09-20',
        'assignee': {
          'id': 1,
          'name': 'Alex Johnson',
          'email': 'alex@example.com',
        },
      };

      final task = TaskModel.fromJson(json);
      expect(task.id, 10);
      expect(task.status, TaskStatus.inProgress);
      expect(task.assignee?.name, 'Alex Johnson');
      expect(task.dueDate, '2026-09-20');
    });

    test('PaginationModel calculates hasNextPage properly', () {
      final p1 = PaginationModel.fromJson({
        'page': 1,
        'limit': 10,
        'total': 25,
        'totalPages': 3,
      });
      expect(p1.hasNextPage, isTrue);

      final p2 = PaginationModel.fromJson({
        'page': 3,
        'limit': 10,
        'total': 25,
        'totalPages': 3,
      });
      expect(p2.hasNextPage, isFalse);
    });

    test('AuthResponseModel deserializes token pair and user', () {
      final auth = AuthResponseModel.fromJson({
        'accessToken': 'acc_token_123',
        'refreshToken': 'ref_token_456',
        'user': {'id': 5, 'name': 'David Smith', 'email': 'david@example.com'},
      });

      expect(auth.accessToken, 'acc_token_123');
      expect(auth.refreshToken, 'ref_token_456');
      expect(auth.user.name, 'David Smith');
    });
  });
}
