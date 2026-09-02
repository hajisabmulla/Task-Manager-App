import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class TeamState extends Equatable {
  const TeamState();
  @override
  List<Object?> get props => [];
}

class TeamInitial extends TeamState {
  const TeamInitial();
}

class TeamLoading extends TeamState {
  const TeamLoading();
}

class TeamLoaded extends TeamState {
  final List<UserModel> members;

  const TeamLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class TeamEmpty extends TeamState {
  const TeamEmpty();
}

class TeamError extends TeamState {
  final String message;

  const TeamError(this.message);

  @override
  List<Object?> get props => [message];
}
