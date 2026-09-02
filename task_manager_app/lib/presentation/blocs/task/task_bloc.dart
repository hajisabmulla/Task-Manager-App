import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskStatus? _currentStatus;
  String _currentSearch = '';
  TaskSortOption _currentSortOption = TaskSortOption.dueDateAsc;

  TaskBloc({required TaskRepository taskRepository})
    : _taskRepository = taskRepository,
      super(const TaskInitial()) {
    on<TasksFetchRequested>(_onTasksFetchRequested);
    on<TasksRefreshRequested>(_onTasksRefreshRequested);
    on<TasksLoadMoreRequested>(_onTasksLoadMoreRequested);
    on<TaskFilterChanged>(_onTaskFilterChanged);
    on<TaskSearchChanged>(_onTaskSearchChanged);
    on<TaskSortChanged>(_onTaskSortChanged);
    on<TaskCreateRequested>(_onTaskCreateRequested);
    on<TaskUpdateRequested>(_onTaskUpdateRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
  }

  Future<void> _onTasksFetchRequested(
    TasksFetchRequested event,
    Emitter<TaskState> emit,
  ) async {
    if (!event.isRefresh && state is! TaskLoaded) {
      emit(const TaskLoading());
    }

    _currentStatus = event.status ?? _currentStatus;
    _currentSearch = event.search ?? _currentSearch;

    try {
      final result = await _taskRepository.getTasks(
        page: event.page,
        status: _currentStatus,
        search: _currentSearch,
        sortBy: _currentSortOption.sortBy,
        sortOrder: _currentSortOption.sortOrder,
      );

      if (result.tasks.isEmpty && event.page == 1) {
        emit(
          TaskEmpty(
            activeStatus: _currentStatus,
            searchQuery: _currentSearch,
            activeSortOption: _currentSortOption,
          ),
        );
      } else {
        emit(
          TaskLoaded(
            tasks: result.tasks,
            pagination: result.pagination,
            activeStatus: _currentStatus,
            searchQuery: _currentSearch,
            activeSortOption: _currentSortOption,
          ),
        );
      }
    } on ApiException catch (e) {
      emit(TaskError(e.message));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onTasksRefreshRequested(
    TasksRefreshRequested event,
    Emitter<TaskState> emit,
  ) async {
    add(
      TasksFetchRequested(
        status: _currentStatus,
        search: _currentSearch,
        sortBy: _currentSortOption.sortBy,
        sortOrder: _currentSortOption.sortOrder,
        page: 1,
        isRefresh: true,
      ),
    );
  }

  Future<void> _onTasksLoadMoreRequested(
    TasksLoadMoreRequested event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded &&
        currentState.pagination.hasNextPage &&
        !currentState.isLoadingMore) {
      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final nextPage = currentState.pagination.page + 1;
        final result = await _taskRepository.getTasks(
          page: nextPage,
          status: _currentStatus,
          search: _currentSearch,
          sortBy: _currentSortOption.sortBy,
          sortOrder: _currentSortOption.sortOrder,
        );

        final combinedTasks = [...currentState.tasks, ...result.tasks];
        emit(
          currentState.copyWith(
            tasks: combinedTasks,
            pagination: result.pagination,
            isLoadingMore: false,
          ),
        );
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  void _onTaskFilterChanged(TaskFilterChanged event, Emitter<TaskState> emit) {
    _currentStatus = event.status;
    add(
      TasksFetchRequested(
        status: _currentStatus,
        search: _currentSearch,
        sortBy: _currentSortOption.sortBy,
        sortOrder: _currentSortOption.sortOrder,
        page: 1,
      ),
    );
  }

  void _onTaskSearchChanged(TaskSearchChanged event, Emitter<TaskState> emit) {
    _currentSearch = event.search;
    add(
      TasksFetchRequested(
        status: _currentStatus,
        search: _currentSearch,
        sortBy: _currentSortOption.sortBy,
        sortOrder: _currentSortOption.sortOrder,
        page: 1,
      ),
    );
  }

  void _onTaskSortChanged(TaskSortChanged event, Emitter<TaskState> emit) {
    _currentSortOption = event.sortOption;
    add(
      TasksFetchRequested(
        status: _currentStatus,
        search: _currentSearch,
        sortBy: _currentSortOption.sortBy,
        sortOrder: _currentSortOption.sortOrder,
        page: 1,
      ),
    );
  }

  Future<void> _onTaskCreateRequested(
    TaskCreateRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final task = await _taskRepository.createTask(
        title: event.title,
        description: event.description,
        status: event.status,
        assigneeId: event.assigneeId,
        dueDate: event.dueDate,
      );

      emit(TaskActionSuccess('Task created successfully!', task: task));
      add(
        TasksFetchRequested(
          status: _currentStatus,
          search: _currentSearch,
          sortBy: _currentSortOption.sortBy,
          sortOrder: _currentSortOption.sortOrder,
          page: 1,
        ),
      );
    } on ApiException catch (e) {
      emit(TaskError(e.message));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onTaskUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final task = await _taskRepository.updateTask(
        id: event.id,
        title: event.title,
        description: event.description,
        status: event.status,
        assigneeId: event.assigneeId,
        dueDate: event.dueDate,
      );

      emit(TaskActionSuccess('Task updated successfully!', task: task));
      add(
        TasksFetchRequested(
          status: _currentStatus,
          search: _currentSearch,
          sortBy: _currentSortOption.sortBy,
          sortOrder: _currentSortOption.sortOrder,
          page: 1,
        ),
      );
    } on ApiException catch (e) {
      emit(TaskError(e.message));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onTaskDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      await _taskRepository.deleteTask(event.id);
      emit(const TaskActionSuccess('Task deleted successfully!'));
      add(
        TasksFetchRequested(
          status: _currentStatus,
          search: _currentSearch,
          sortBy: _currentSortOption.sortBy,
          sortOrder: _currentSortOption.sortOrder,
          page: 1,
        ),
      );
    } on ApiException catch (e) {
      emit(TaskError(e.message));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
