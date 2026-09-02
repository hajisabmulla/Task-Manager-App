import 'package:equatable/equatable.dart';
import '../../../data/models/task_model.dart';

enum TaskSortOption {
  dueDateAsc('dueDate', 'asc', 'Due Date (Earliest)'),
  dueDateDesc('dueDate', 'desc', 'Due Date (Latest)'),
  createdAtDesc('createdAt', 'desc', 'Newest First'),
  createdAtAsc('createdAt', 'asc', 'Oldest First'),
  titleAsc('title', 'asc', 'Title (A-Z)'),
  titleDesc('title', 'desc', 'Title (Z-A)'),
  statusAsc('status', 'asc', 'Status');

  final String sortBy;
  final String sortOrder;
  final String label;

  const TaskSortOption(this.sortBy, this.sortOrder, this.label);
}

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class TasksFetchRequested extends TaskEvent {
  final TaskStatus? status;
  final String? search;
  final String? sortBy;
  final String? sortOrder;
  final int page;
  final bool isRefresh;

  const TasksFetchRequested({
    this.status,
    this.search,
    this.sortBy,
    this.sortOrder,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [status, search, sortBy, sortOrder, page, isRefresh];
}

class TasksRefreshRequested extends TaskEvent {
  const TasksRefreshRequested();
}

class TasksLoadMoreRequested extends TaskEvent {
  const TasksLoadMoreRequested();
}

class TaskFilterChanged extends TaskEvent {
  final TaskStatus? status;

  const TaskFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class TaskSearchChanged extends TaskEvent {
  final String search;

  const TaskSearchChanged(this.search);

  @override
  List<Object?> get props => [search];
}

class TaskSortChanged extends TaskEvent {
  final TaskSortOption sortOption;

  const TaskSortChanged(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

class TaskCreateRequested extends TaskEvent {
  final String title;
  final String? description;
  final TaskStatus status;
  final int? assigneeId;
  final String dueDate;

  const TaskCreateRequested({
    required this.title,
    this.description,
    required this.status,
    this.assigneeId,
    required this.dueDate,
  });

  @override
  List<Object?> get props => [title, description, status, assigneeId, dueDate];
}

class TaskUpdateRequested extends TaskEvent {
  final int id;
  final String? title;
  final String? description;
  final TaskStatus? status;
  final int? assigneeId;
  final String? dueDate;

  const TaskUpdateRequested({
    required this.id,
    this.title,
    this.description,
    this.status,
    this.assigneeId,
    this.dueDate,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    assigneeId,
    dueDate,
  ];
}

class TaskDeleteRequested extends TaskEvent {
  final int id;

  const TaskDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
