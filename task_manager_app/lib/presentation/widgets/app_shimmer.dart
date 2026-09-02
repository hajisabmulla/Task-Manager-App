import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AppShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const AppShimmer({super.key, required this.child, this.enabled = true});

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppSpacing.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class TaskListShimmer extends StatelessWidget {
  final int itemCount;

  const TaskListShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShimmerBox(
                        width: 70,
                        height: 22,
                        borderRadius: AppSpacing.radiusXl,
                      ),
                      const ShimmerBox(width: 80, height: 16),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                  const ShimmerBox(width: double.infinity, height: 18),
                  const SizedBox(height: AppSpacing.xs + 2),
                  const ShimmerBox(width: 220, height: 14),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(color: AppColors.borderLight, height: 1),
                  const SizedBox(height: AppSpacing.sm + 2),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const ShimmerBox(width: 120, height: 14),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TeamListShimmer extends StatelessWidget {
  final int itemCount;

  const TeamListShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 140, height: 16),
                        SizedBox(height: 6),
                        ShimmerBox(width: 180, height: 13),
                        SizedBox(height: 6),
                        ShimmerBox(width: 90, height: 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TaskDetailShimmer extends StatelessWidget {
  const TaskDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBox(
                          width: 80,
                          height: 26,
                          borderRadius: AppSpacing.radiusXl,
                        ),
                        ShimmerBox(
                          width: 90,
                          height: 22,
                          borderRadius: AppSpacing.radiusSm,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const ShimmerBox(width: double.infinity, height: 24),
                    const SizedBox(height: AppSpacing.xs),
                    const ShimmerBox(width: 180, height: 24),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: AppColors.borderLight),
                    const SizedBox(height: AppSpacing.sm),
                    const ShimmerBox(width: 80, height: 14),
                    const SizedBox(height: AppSpacing.xs + 2),
                    const ShimmerBox(width: double.infinity, height: 14),
                    const SizedBox(height: 4),
                    const ShimmerBox(width: 250, height: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 140, height: 16),
                    const SizedBox(height: AppSpacing.md),
                    const Row(
                      children: [
                        ShimmerBox(width: 80, height: 14),
                        SizedBox(width: AppSpacing.lg),
                        ShimmerBox(width: 120, height: 14),
                      ],
                    ),
                    const Divider(
                      color: AppColors.borderLight,
                      height: AppSpacing.lg,
                    ),
                    const Row(
                      children: [
                        ShimmerBox(width: 80, height: 14),
                        SizedBox(width: AppSpacing.lg),
                        ShimmerBox(width: 150, height: 14),
                      ],
                    ),
                    const Divider(
                      color: AppColors.borderLight,
                      height: AppSpacing.lg,
                    ),
                    const Row(
                      children: [
                        ShimmerBox(width: 80, height: 14),
                        SizedBox(width: AppSpacing.lg),
                        ShimmerBox(width: 110, height: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
