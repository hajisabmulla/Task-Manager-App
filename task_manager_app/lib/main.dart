import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/user_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/task/task_bloc.dart';
import 'presentation/blocs/team/team_bloc.dart';
import 'routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = SecureStorageService();
  final apiClient = ApiClient(storageService: storageService);

  final authRepository = AuthRepository(
    apiClient: apiClient,
    storageService: storageService,
  );
  final userRepository = UserRepository(apiClient: apiClient);
  final taskRepository = TaskRepository(apiClient: apiClient);

  runApp(
    MyApp(
      authRepository: authRepository,
      userRepository: userRepository,
      taskRepository: taskRepository,
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final TaskRepository taskRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.userRepository,
    required this.taskRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final TaskBloc _taskBloc;
  late final TeamBloc _teamBloc;
  late final dynamic _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository: widget.authRepository)
      ..add(const AuthCheckRequested());

    _taskBloc = TaskBloc(taskRepository: widget.taskRepository);
    _teamBloc = TeamBloc(userRepository: widget.userRepository);

    _router = createAppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _taskBloc.close();
    _teamBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.userRepository),
        RepositoryProvider.value(value: widget.taskRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _taskBloc),
          BlocProvider.value(value: _teamBloc),
        ],
        child: MaterialApp.router(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
