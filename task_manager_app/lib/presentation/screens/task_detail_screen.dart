import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../widgets/app_button.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_shimmer.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/quick_status_sheet.dart';
import '../widgets/status_badge.dart';
import '../widgets/user_avatar.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TaskModel? _task;
  bool _isLoading = true;
  String? _error;
  bool _isNavigating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchTask();
  }

  Future<void> _fetchTask() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final taskRepo = context.read<TaskRepository>();
      final task = await taskRepo.getTaskById(widget.taskId);
      if (mounted) {
        setState(() {
          _task = task;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _safeNavigateToEdit() async {
    if (_isNavigating || _isDeleting) return;
    setState(() {
      _isNavigating = true;
    });
    try {
      final updated = await context.push<bool>('/tasks/${widget.taskId}/edit');
      if (updated == true && mounted) {
        _fetchTask();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  Future<void> _onDelete() async {
    if (_isDeleting) return;

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Task?',
      message:
          'Are you sure you want to delete this task? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isDeleting = true;
      });
      context.read<TaskBloc>().add(TaskDeleteRequested(widget.taskId));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.taskDetails),
        actions: [
          if (_task != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Task',
              onPressed: (_isNavigating || _isDeleting) ? null : _safeNavigateToEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Delete Task',
              onPressed: _isDeleting ? null : _onDelete,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
      body: _isLoading
          ? const TaskDetailShimmer()
          : _error != null
          ? RefreshIndicator(
              onRefresh: _fetchTask,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: AppErrorView(message: _error!, onRetry: _fetchTask),
                ),
              ),
            )
          : _task == null
          ? const Center(child: Text('Task not found'))
          : RefreshIndicator(
              onRefresh: _fetchTask,
              color: AppColors.primary,
              child: _buildTaskDetailView(_task!),
            ),
    );
  }

  Widget _buildTaskDetailView(TaskModel task) {
    final isOverdue = AppDateFormatter.isOverdue(
      task.dueDate,
      task.status.value,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppBreakpoints.contentMaxWidth(context),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Title and Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              QuickStatusSheet.show(
                                context,
                                task: task,
                                onStatusSelected: (newStatus) async {
                                  context.read<TaskBloc>().add(
                                    TaskUpdateRequested(
                                      id: task.id,
                                      status: newStatus,
                                    ),
                                  );
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  _fetchTask();
                                },
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StatusBadge(status: task.status, isLarge: true),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm + 2,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isOverdue
                                  ? AppColors.errorBg
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  size: 14,
                                  color: isOverdue
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  AppDateFormatter.formatShort(task.dueDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isOverdue
                                        ? AppColors.error
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (task.description != null &&
                          task.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        const Divider(color: AppColors.borderLight),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          task.description!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimaryLight,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Metadata Cards
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assignment & Details',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Assignee
                      _buildMetaRow(
                        label: 'Assignee',
                        child: task.assignee != null
                            ? Row(
                                children: [
                                  UserAvatar(
                                    user: task.assignee,
                                    size: 28,
                                    fontSize: 11,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.assignee!.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      Text(
                                        task.assignee!.email,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const Text(
                                'Unassigned',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                      ),

                      const Divider(
                        color: AppColors.borderLight,
                        height: AppSpacing.lg,
                      ),

                      // Due Date Full
                      _buildMetaRow(
                        label: 'Due Date',
                        child: Text(
                          AppDateFormatter.formatFull(task.dueDate),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isOverdue
                                ? AppColors.error
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),

                      if (task.createdBy != null) ...[
                        const Divider(
                          color: AppColors.borderLight,
                          height: AppSpacing.lg,
                        ),
                        _buildMetaRow(
                          label: 'Created By',
                          child: Text(
                            task.createdBy!.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],

                      if (task.createdAt != null) ...[
                        const Divider(
                          color: AppColors.borderLight,
                          height: AppSpacing.lg,
                        ),
                        _buildMetaRow(
                          label: 'Created At',
                          child: Text(
                            AppDateFormatter.formatTimestamp(task.createdAt),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Edit Task',
                      icon: Icons.edit_outlined,
                      variant: ButtonVariant.primary,
                      isLoading: _isNavigating,
                      onPressed: (_isNavigating || _isDeleting)
                          ? null
                          : _safeNavigateToEdit,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Delete',
                      icon: Icons.delete_outline,
                      variant: ButtonVariant.destructive,
                      isLoading: _isDeleting,
                      onPressed: (_isDeleting || _isNavigating)
                          ? null
                          : _onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
