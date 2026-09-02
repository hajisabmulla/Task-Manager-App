class AppValidators {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? name(String? value, {String fieldName = 'Full Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return '$fieldName must be at least 3 characters.';
    }
    if (trimmed.length > 50) {
      return '$fieldName must not exceed 50 characters.';
    }
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(trimmed)) {
      return '$fieldName can only contain alphabetic characters and single spaces.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != originalPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }

  static String? taskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Task title is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Task title must be at least 3 characters';
    }
    if (trimmed.length > 100) {
      return 'Task title cannot exceed 100 characters';
    }
    return null;
  }

  static String? taskDescription(String? value) {
    if (value != null && value.trim().length > 1000) {
      return 'Description cannot exceed 1000 characters';
    }
    return null;
  }

  static String? dueDate(DateTime? date) {
    if (date == null) {
      return 'Due date is required';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate.isBefore(today)) {
      return 'Due date cannot be in the past';
    }
    return null;
  }
}
