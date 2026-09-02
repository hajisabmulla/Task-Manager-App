import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_app/core/utils/validators.dart';

void main() {
  group('AppValidators Tests', () {
    test('Name validator checks length and alphabetic constraints', () {
      expect(AppValidators.name(''), isNotNull);
      expect(AppValidators.name('Al'), isNotNull); // < 3 chars
      expect(AppValidators.name('John123'), isNotNull); // contains numbers
      expect(AppValidators.name('John@Doe'), isNotNull); // contains special symbols
      expect(AppValidators.name('John Doe'), isNull); // valid
      expect(AppValidators.name('Sarah Connor Smith'), isNull); // valid
    });

    test('Email validator enforces standard RFC format and trims', () {
      expect(AppValidators.email(''), isNotNull);
      expect(AppValidators.email('invalid-email'), isNotNull);
      expect(AppValidators.email('test@'), isNotNull);
      expect(AppValidators.email('test@domain'), isNotNull);
      expect(AppValidators.email('test@domain.com'), isNull);
      expect(AppValidators.email(' alex@example.org '), isNull);
    });

    test('Password validator enforces min 8 chars, uppercase, digit, and special char', () {
      expect(AppValidators.password(''), isNotNull);
      expect(AppValidators.password('short'), isNotNull);
      expect(AppValidators.password('lowercase123!'), isNotNull); // missing uppercase
      expect(AppValidators.password('UPPERCASE123!'), isNull); // has upper, digit, special, 8+
      expect(AppValidators.password('Password123'), isNotNull); // missing special char
      expect(AppValidators.password('Password123!'), isNull); // valid strong password
    });

    test('Confirm password validator ensures exact match', () {
      expect(AppValidators.confirmPassword('Password123!', 'Different123!'), isNotNull);
      expect(AppValidators.confirmPassword('Password123!', 'Password123!'), isNull);
    });

    test('Task Title validator enforces required, trim, min 3, max 100 length, and allows normal characters & punctuation', () {
      expect(AppValidators.taskTitle(''), 'Task title is required');
      expect(AppValidators.taskTitle('   '), 'Task title is required');
      expect(AppValidators.taskTitle(null), 'Task title is required');
      expect(AppValidators.taskTitle('A'), 'Task title must be at least 3 characters');
      expect(AppValidators.taskTitle('AB'), 'Task title must be at least 3 characters');
      expect(AppValidators.taskTitle('Fix login bug'), isNull);
      expect(AppValidators.taskTitle(' Fix login bug '), isNull); // trims whitespace
      expect(AppValidators.taskTitle('Fix bug #42 (auth_flow)'), isNull); // symbols, underscores, parens
      expect(AppValidators.taskTitle('Task-123: Update UI/UX & API!'), isNull); // hyphens, punctuation, ampersand
      expect(AppValidators.taskTitle('a' * 100), isNull);
      expect(AppValidators.taskTitle('a' * 101), 'Task title cannot exceed 100 characters');
    });

    test('Task Description validator allows optional and enforces max 1000 length', () {
      expect(AppValidators.taskDescription(null), isNull);
      expect(AppValidators.taskDescription(''), isNull);
      expect(AppValidators.taskDescription('   '), isNull);
      expect(AppValidators.taskDescription('Short description'), isNull);
      expect(AppValidators.taskDescription('d' * 1000), isNull);
      expect(AppValidators.taskDescription('d' * 1001), 'Description cannot exceed 1000 characters');
    });

    test('Due date validator enforces required and forbids past dates', () {
      expect(AppValidators.dueDate(null), 'Due date is required');
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(AppValidators.dueDate(yesterday), 'Due date cannot be in the past');
      final today = DateTime.now();
      expect(AppValidators.dueDate(today), isNull);
      final futureDate = DateTime.now().add(const Duration(days: 7));
      expect(AppValidators.dueDate(futureDate), isNull);
    });
  });
}
