import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/task_model.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool isLarge;

  const StatusBadge({super.key, required this.status, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;
    IconData icon;

    switch (status) {
      case TaskStatus.todo:
        bg = AppColors.todoBg;
        text = AppColors.todoText;
        border = AppColors.todoBorder;
        icon = Icons.radio_button_unchecked;
        break;
      case TaskStatus.inProgress:
        bg = AppColors.inProgressBg;
        text = AppColors.inProgressText;
        border = AppColors.inProgressBorder;
        icon = Icons.timelapse;
        break;
      case TaskStatus.done:
        bg = AppColors.doneBg;
        text = AppColors.doneText;
        border = AppColors.doneBorder;
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? AppSpacing.md : AppSpacing.sm + 2,
        vertical: isLarge ? AppSpacing.xs + 2 : AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isLarge ? 16 : 13, color: text),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status.label,
            style: TextStyle(
              color: text,
              fontSize: isLarge ? 13 : 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
