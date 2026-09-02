import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_state.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/signup_screen.dart';
import '../presentation/screens/task_detail_screen.dart';
import '../presentation/screens/task_form_screen.dart';
import '../presentation/screens/task_list_screen.dart';
import '../presentation/screens/team_screen.dart';
import 'app_routes.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is Authenticated;
      final isAuthLoading =
          authState is AuthInitial || authState is AuthLoading;

      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isSigningUp = state.matchedLocation == AppRoutes.signup;

      if (isAuthLoading) {
        if (isLoggingIn || isSigningUp) return null;
        return AppRoutes.login;
      }

      if (!isAuth) {
        // If unauthenticated, allow only login and signup
        if (isLoggingIn || isSigningUp) return null;
        return AppRoutes.login;
      }

      // If authenticated and trying to access login/signup, redirect to tasks
      if (isLoggingIn || isSigningUp) {
        return AppRoutes.tasks;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.tasks,
        builder: (context, state) => const TaskListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const TaskFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return TaskDetailScreen(taskId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final id =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return TaskFormScreen(taskId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.team,
        builder: (context, state) => const TeamScreen(),
      ),
    ],
  );
}
