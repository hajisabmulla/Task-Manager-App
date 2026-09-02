import 'package:equatable/equatable.dart';

abstract class TeamEvent extends Equatable {
  const TeamEvent();
  @override
  List<Object?> get props => [];
}

class TeamMembersFetchRequested extends TeamEvent {
  const TeamMembersFetchRequested();
}

class TeamMembersRefreshRequested extends TeamEvent {
  const TeamMembersRefreshRequested();
}
