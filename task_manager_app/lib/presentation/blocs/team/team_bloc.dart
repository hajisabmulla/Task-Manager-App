import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/repositories/user_repository.dart';
import 'team_event.dart';
import 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final UserRepository _userRepository;

  TeamBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const TeamInitial()) {
    on<TeamMembersFetchRequested>(_onTeamMembersFetchRequested);
    on<TeamMembersRefreshRequested>(_onTeamMembersRefreshRequested);
  }

  Future<void> _onTeamMembersFetchRequested(
    TeamMembersFetchRequested event,
    Emitter<TeamState> emit,
  ) async {
    if (state is! TeamLoaded) {
      emit(const TeamLoading());
    }

    try {
      final members = await _userRepository.getTeamMembers();
      if (members.isEmpty) {
        emit(const TeamEmpty());
      } else {
        emit(TeamLoaded(members));
      }
    } on ApiException catch (e) {
      emit(TeamError(e.message));
    } catch (e) {
      emit(TeamError(e.toString()));
    }
  }

  Future<void> _onTeamMembersRefreshRequested(
    TeamMembersRefreshRequested event,
    Emitter<TeamState> emit,
  ) async {
    add(const TeamMembersFetchRequested());
  }
}
