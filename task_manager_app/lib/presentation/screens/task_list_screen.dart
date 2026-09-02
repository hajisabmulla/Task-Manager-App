import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/task_model.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../blocs/team/team_bloc.dart';
import '../blocs/team/team_event.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_shimmer.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/quick_status_sheet.dart';
import '../widgets/task_card.dart';
import '../widgets/user_avatar.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounceTimer;

  TaskStatus? _selectedStatus;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial fetch of tasks and team members
    context.read<TaskBloc>().add(const TasksFetchRequested(page: 1));
    context.read<TeamBloc>().add(const TeamMembersFetchRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TaskBloc>().add(const TasksLoadMoreRequested());
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        context.read<TaskBloc>().add(TaskSearchChanged(query));
      },
    );
  }

  void _onFilterSelected(TaskStatus? status) {
    if (_selectedStatus == status) return; // Prevent duplicate queries on same tab
    setState(() {
      _selectedStatus = status;
    });
    context.read<TaskBloc>().add(TaskFilterChanged(status));
  }

  Future<void> _safeNavigate(Future<void> Function() navAction) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      await navAction();
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return Row(
                children: [
                  UserAvatar(user: state.user, size: 36, fontSize: 13),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${state.user.name.split(' ').first}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Manage your team tasks',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const Text('Task Manager');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_outlined),
            tooltip: 'Team Members',
            onPressed: () => _safeNavigate(() async {
              await context.push('/team');
            }),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () async {
              final authBloc = context.read<AuthBloc>();
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Sign Out?',
                message: 'Are you sure you want to sign out of your account?',
                confirmLabel: 'Sign Out',
                isDestructive: false,
              );
              if (confirmed == true) {
                authBloc.add(const AuthLogoutRequested());
              }
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppBreakpoints.contentMaxWidth(context),
          ),
          child: Column(
            children: [
              // Search and Filter Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    // Search Field
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search tasks by title...',
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.textSecondaryLight,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 12,
                        ),
                      ),
                    ),
                    // Filter Chips & Sort Row
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('All', null),
                                const SizedBox(width: AppSpacing.sm),
                                _buildFilterChip('Todo', TaskStatus.todo),
                                const SizedBox(width: AppSpacing.sm),
                                _buildFilterChip('In Progress', TaskStatus.inProgress),
                                const SizedBox(width: AppSpacing.sm),
                                _buildFilterChip('Done', TaskStatus.done),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        BlocBuilder<TaskBloc, TaskState>(
                          builder: (context, state) {
                            final currentSort = (state is TaskLoaded)
                                ? state.activeSortOption
                                : (state is TaskEmpty)
                                    ? state.activeSortOption
                                    : TaskSortOption.dueDateAsc;

                            return PopupMenuButton<TaskSortOption>(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                                child: const Icon(
                                  Icons.sort,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              tooltip: 'Sort tasks',
                              initialValue: currentSort,
                              onSelected: (option) {
                                context.read<TaskBloc>().add(TaskSortChanged(option));
                              },
                              itemBuilder: (context) {
                                return TaskSortOption.values.map((option) {
                                  final isSelected = option == currentSort;
                                  return PopupMenuItem<TaskSortOption>(
                                    value: option,
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected ? Icons.check : Icons.circle_outlined,
                                          size: 16,
                                          color: isSelected ? AppColors.primary : Colors.transparent,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          option.label,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                            color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.borderLight, height: 1),

              // Task List Area
              Expanded(
                child: BlocConsumer<TaskBloc, TaskState>(
                  listener: (context, state) {
                    if (state is TaskActionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is TaskLoading && state is! TaskLoaded) {
                      return const TaskListShimmer();
                    }

                    if (state is TaskError) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<TaskBloc>().add(
                            const TasksRefreshRequested(),
                          );
                        },
                        color: AppColors.primary,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: AppErrorView(
                              message: state.message,
                              onRetry: () {
                                context.read<TaskBloc>().add(
                                  const TasksRefreshRequested(),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }

                    if (state is TaskEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<TaskBloc>().add(
                            const TasksRefreshRequested(),
                          );
                        },
                        color: AppColors.primary,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: AppEmptyState(
                              icon: Icons.assignment_outlined,
                              title: state.searchQuery.isNotEmpty
                                  ? 'No matching tasks'
                                  : 'No tasks found',
                              description: state.searchQuery.isNotEmpty
                                  ? 'No tasks found matching "${state.searchQuery}". Try a different search term.'
                                  : state.activeStatus != null
                                  ? 'No ${state.activeStatus!.label.toLowerCase()} tasks found. Create a new task or change filters.'
                                  : 'You have no tasks yet. Tap "+ New Task" to create your first task.',
                            ),
                          ),
                        ),
                      );
                    }

                    if (state is TaskLoaded) {
                      final tasks = state.tasks;

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<TaskBloc>().add(
                            const TasksRefreshRequested(),
                          );
                        },
                        color: AppColors.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: tasks.length + (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == tasks.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.lg,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final task = tasks[index];
                            return Dismissible(
                              key: ValueKey('task-swipe-${task.id}-${task.status.value}'),
                              direction: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                QuickStatusSheet.show(
                                  context,
                                  task: task,
                                  onStatusSelected: (newStatus) {
                                    context.read<TaskBloc>().add(
                                      TaskUpdateRequested(
                                        id: task.id,
                                        status: newStatus,
                                      ),
                                    );
                                  },
                                );
                                return false;
                              },
                              background: Container(
                                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.swap_horiz, color: AppColors.primary, size: 20),
                                    SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Quick Status',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Quick Status',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.xs),
                                    Icon(Icons.swap_horiz, color: AppColors.primary, size: 20),
                                  ],
                                ),
                              ),
                              child: TaskCard(
                                task: task,
                                onTap: () => _safeNavigate(() async {
                                  final taskBloc = context.read<TaskBloc>();
                                  await context.push('/tasks/${task.id}');
                                  taskBloc.add(const TasksRefreshRequested());
                                }),
                                onStatusTap: () {
                                  QuickStatusSheet.show(
                                    context,
                                    task: task,
                                    onStatusSelected: (newStatus) {
                                      context.read<TaskBloc>().add(
                                        TaskUpdateRequested(
                                          id: task.id,
                                          status: newStatus,
                                        ),
                                      );
                                    },
                                  );
                                },
                                onLongPress: () {
                                  QuickStatusSheet.show(
                                    context,
                                    task: task,
                                    onStatusSelected: (newStatus) {
                                      context.read<TaskBloc>().add(
                                        TaskUpdateRequested(
                                          id: task.id,
                                          status: newStatus,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isNavigating
            ? null
            : () => _safeNavigate(() async {
                final taskBloc = context.read<TaskBloc>();
                final created = await context.push<bool>('/tasks/create');
                if (created == true) {
                  taskBloc.add(const TasksRefreshRequested());
                }
              }),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskStatus? status) {
    final isSelected = _selectedStatus == status;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceLight,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderLight,
        width: 1,
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      onSelected: (_) => _onFilterSelected(status),
    );
  }
}
