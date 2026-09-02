import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/task_model.dart';
import 'status_badge.dart';

class QuickStatusSheet extends StatelessWidget {
  final TaskModel task;
  final ValueChanged<TaskStatus> onStatusSelected;

  const QuickStatusSheet({
    super.key,
    required this.task,
    required this.onStatusSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskModel task,
    required ValueChanged<TaskStatus> onStatusSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      backgroundColor: AppColors.surfaceLight,
      builder: (ctx) => QuickStatusSheet(
        task: task,
        onStatusSelected: onStatusSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header
            const Text(
              'Quick Status Update',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Status Options
            ...TaskStatus.values.map((status) {
              final isSelected = task.status == status;

              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  if (!isSelected) {
                    onStatusSelected(status);
                  }
                },
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      StatusBadge(status: status),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20,
                        )
                      else
                        const Icon(
                          Icons.radio_button_unchecked,
                          color: AppColors.textMutedLight,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}
