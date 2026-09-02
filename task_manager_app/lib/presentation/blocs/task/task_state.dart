import 'package:equatable/equatable.dart';
import '../../../data/models/pagination_model.dart';
import '../../../data/models/task_model.dart';
import 'task_event.dart';

abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  final PaginationModel pagination;
  final TaskStatus? activeStatus;
  final String searchQuery;
  final TaskSortOption activeSortOption;
  final bool isLoadingMore;

  const TaskLoaded({
    required this.tasks,
    required this.pagination,
    this.activeStatus,
    this.searchQuery = '',
    this.activeSortOption = TaskSortOption.dueDateAsc,
    this.isLoadingMore = false,
  });

  TaskLoaded copyWith({
    List<TaskModel>? tasks,
    PaginationModel? pagination,
    TaskStatus? activeStatus,
    bool clearStatus = false,
    String? searchQuery,
    TaskSortOption? activeSortOption,
    bool? isLoadingMore,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      pagination: pagination ?? this.pagination,
      activeStatus: clearStatus ? null : (activeStatus ?? this.activeStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      activeSortOption: activeSortOption ?? this.activeSortOption,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    tasks,
    pagination,
    activeStatus,
    searchQuery,
    activeSortOption,
    isLoadingMore,
  ];
}

class TaskEmpty extends TaskState {
  final TaskStatus? activeStatus;
  final String searchQuery;
  final TaskSortOption activeSortOption;

  const TaskEmpty({
    this.activeStatus,
    this.searchQuery = '',
    this.activeSortOption = TaskSortOption.dueDateAsc,
  });

  @override
  List<Object?> get props => [activeStatus, searchQuery, activeSortOption];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskActionSuccess extends TaskState {
  final String message;
  final TaskModel? task;

  const TaskActionSuccess(this.message, {this.task});

  @override
  List<Object?> get props => [message, task];
}
