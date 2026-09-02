class AppConstants {
  static const String appName = 'Task Manager';
  static const int minPasswordLength = 8;
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  static const int minTitleLength = 3;
  static const int maxTitleLength = 100;
  static const int searchDebounceMs = 350;
  static const int defaultPageLimit = 10;

  // Storage Keys
  static const String keyAccessToken = 'task_manager_access_token';
  static const String keyRefreshToken = 'task_manager_refresh_token';
  static const String keyUserData = 'task_manager_user_data';
}
