import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/task_model.dart';
import 'status_badge.dart';
import 'user_avatar.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback? onStatusTap;
  final VoidCallback? onLongPress;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onStatusTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = AppDateFormatter.isOverdue(
      task.dueDate,
      task.status.value,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge and Due Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onStatusTap,
                    behavior: HitTestBehavior.opaque,
                    child: Tooltip(
                      message: 'Tap to quick change status',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusBadge(status: task.status),
                          if (onStatusTap != null) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 16,
                              color: AppColors.textSecondaryLight,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: isOverdue
                            ? AppColors.error
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        AppDateFormatter.formatShort(task.dueDate),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isOverdue
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isOverdue
                              ? AppColors.error
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm + 2),

              // Title
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Description preview (if available)
              if (task.description != null &&
                  task.description!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  task.description!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondaryLight,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.borderLight, height: 1),
              const SizedBox(height: AppSpacing.sm + 2),

              // Bottom Row: Assignee Info
              Row(
                children: [
                  UserAvatar(user: task.assignee, size: 24, fontSize: 10),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      task.assignee != null
                          ? task.assignee!.name
                          : 'Unassigned',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: task.assignee != null
                            ? AppColors.textPrimaryLight
                            : AppColors.textMutedLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textMutedLight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
