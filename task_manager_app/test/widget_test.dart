import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_app/data/models/task_model.dart';
import 'package:task_manager_app/data/models/user_model.dart';
import 'package:task_manager_app/presentation/widgets/app_button.dart';
import 'package:task_manager_app/presentation/widgets/app_text_field.dart';
import 'package:task_manager_app/presentation/widgets/status_badge.dart';
import 'package:task_manager_app/presentation/widgets/task_card.dart';
import 'package:task_manager_app/presentation/widgets/user_avatar.dart';

void main() {
  group('UI Widgets Tests', () {
    testWidgets('AppButton renders label and reacts to taps', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Submit Task',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit Task'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('StatusBadge renders correct status and color themes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(status: TaskStatus.todo),
                StatusBadge(status: TaskStatus.inProgress),
                StatusBadge(status: TaskStatus.done),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Todo'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('AppTextField renders label, hint, and asterisk', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Email',
              hint: 'Enter your email',
              isRequired: true,
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text(' *'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('TaskCard displays title, status, and assignee', (
      WidgetTester tester,
    ) async {
      const sampleTask = TaskModel(
        id: 1,
        title: 'Design Wireframes',
        description: 'Design preliminary UI mocks',
        status: TaskStatus.todo,
        dueDate: '2026-09-18',
        assignee: UserModel(
          id: 3,
          name: 'Sarah Connor',
          email: 'sarah@example.com',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(task: sampleTask, onTap: () {}),
          ),
        ),
      );

      expect(find.text('Design Wireframes'), findsOneWidget);
      expect(find.text('Design preliminary UI mocks'), findsOneWidget);
      expect(find.text('Todo'), findsOneWidget);
      expect(find.text('Sarah Connor'), findsOneWidget);
    });

    testWidgets('UserAvatar displays correct initials', (
      WidgetTester tester,
    ) async {
      const user = UserModel(
        id: 1,
        name: 'Alex Johnson',
        email: 'alex@example.com',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserAvatar(user: user)),
        ),
      );

      expect(find.text('AJ'), findsOneWidget);
    });
  });
}
