import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive.dart';
import '../blocs/team/team_bloc.dart';
import '../blocs/team/team_event.dart';
import '../blocs/team/team_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_shimmer.dart';
import '../widgets/user_avatar.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(const TeamMembersFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.teamTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppBreakpoints.contentMaxWidth(context),
          ),
          child: BlocBuilder<TeamBloc, TeamState>(
            builder: (context, state) {
              if (state is TeamLoading && state is! TeamLoaded) {
                return const TeamListShimmer();
              }

              if (state is TeamError) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TeamBloc>().add(
                      const TeamMembersRefreshRequested(),
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
                          context.read<TeamBloc>().add(
                            const TeamMembersFetchRequested(),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }

              if (state is TeamEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TeamBloc>().add(
                      const TeamMembersRefreshRequested(),
                    );
                  },
                  color: AppColors.primary,
                  child: const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 300,
                      child: AppEmptyState(
                        icon: Icons.group_outlined,
                        title: 'No Team Members',
                        description:
                            'No registered team members were found in the workspace.',
                      ),
                    ),
                  ),
                );
              }

              if (state is TeamLoaded) {
                final members = state.members;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TeamBloc>().add(
                      const TeamMembersRefreshRequested(),
                    );
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: AppSpacing.sm + 2,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              UserAvatar(user: member, size: 44, fontSize: 16),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      member.email,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    if (member.createdAt != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Joined ${AppDateFormatter.formatShort(member.createdAt)}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textMutedLight,
                                        ),
                                      ),
                                    ],
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

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
