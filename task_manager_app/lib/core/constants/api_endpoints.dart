class ApiEndpoints {
  // Configurable base URL
  static String get baseUrl {
    return 'http://localhost:3000/api';
  }

  // Auth
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Users
  static const String users = '/users';

  // Tasks
  static const String tasks = '/tasks';
  static String taskById(int id) => '/tasks/$id';
}
