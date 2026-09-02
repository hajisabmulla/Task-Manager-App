import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../data/models/task_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/task_repository.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../blocs/team/team_bloc.dart';
import '../blocs/team/team_event.dart';
import '../blocs/team/team_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/app_text_field.dart';
import '../widgets/user_avatar.dart';

class TaskFormScreen extends StatefulWidget {
  final int? taskId;

  const TaskFormScreen({super.key, this.taskId});

  bool get isEditing => taskId != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleKey = GlobalKey();
  final _descriptionKey = GlobalKey();
  final _statusKey = GlobalKey();
  final _dueDateKey = GlobalKey();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  TaskStatus _status = TaskStatus.todo;
  int? _selectedAssigneeId;
  DateTime? _selectedDueDate = DateTime.now();

  bool _isLoadingInitial = false;
  String? _initialError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Ensure assignee dropdown has the latest registered team members
    context.read<TeamBloc>().add(const TeamMembersFetchRequested());
    if (widget.isEditing) {
      _loadTaskData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTaskData() async {
    setState(() {
      _isLoadingInitial = true;
      _initialError = null;
    });

    try {
      final taskRepo = context.read<TaskRepository>();
      final task = await taskRepo.getTaskById(widget.taskId!);
      if (mounted) {
        setState(() {
          _titleController.text = task.title;
          _descriptionController.text = task.description ?? '';
          _status = task.status;
          _selectedAssigneeId = task.assignee?.id;
          try {
            if (task.dueDate.length >= 10 && RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(task.dueDate)) {
              final parts = task.dueDate.substring(0, 10).split('-');
              _selectedDueDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            } else {
              _selectedDueDate = DateTime.parse(task.dueDate).toLocal();
            }
          } catch (_) {
            _selectedDueDate = DateTime.now();
          }
          _isLoadingInitial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialError = e.toString();
          _isLoadingInitial = false;
        });
      }
    }
  }

  Future<void> _selectDueDate(FormFieldState<DateTime> fieldState) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _selectedDueDate ?? today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(today) ? today : initial,
      firstDate: today,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: AppColors.lightColorScheme),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDueDate = picked;
      });
      fieldState.didChange(picked);
    }
  }

  void _scrollToFirstError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AppValidators.taskTitle(_titleController.text) != null) {
        _titleFocusNode.requestFocus();
        if (_titleKey.currentContext != null) {
          Scrollable.ensureVisible(
            _titleKey.currentContext!,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      } else if (AppValidators.taskDescription(_descriptionController.text) != null) {
        _descriptionFocusNode.requestFocus();
        if (_descriptionKey.currentContext != null) {
          Scrollable.ensureVisible(
            _descriptionKey.currentContext!,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      } else if (AppValidators.dueDate(_selectedDueDate) != null) {
        if (_dueDateKey.currentContext != null) {
          Scrollable.ensureVisible(
            _dueDateKey.currentContext!,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      }
    });
  }

  void _onSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      _scrollToFirstError();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final formattedDate = _selectedDueDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDueDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    final trimmedTitle = _titleController.text.trim();
    final trimmedDescription = _descriptionController.text.trim();

    if (widget.isEditing) {
      context.read<TaskBloc>().add(
        TaskUpdateRequested(
          id: widget.taskId!,
          title: trimmedTitle,
          description: trimmedDescription.isEmpty ? null : trimmedDescription,
          status: _status,
          assigneeId: _selectedAssigneeId,
          dueDate: formattedDate,
        ),
      );
    } else {
      context.read<TaskBloc>().add(
        TaskCreateRequested(
          title: trimmedTitle,
          description: trimmedDescription.isEmpty ? null : trimmedDescription,
          status: _status,
          assigneeId: _selectedAssigneeId,
          dueDate: formattedDate,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.isEditing
        ? AppStrings.editTask
        : AppStrings.createTask;

    return Scaffold(
      appBar: AppBar(title: Text(titleText)),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskActionSuccess) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.isEditing
                      ? 'Task updated successfully'
                      : 'Task created successfully',
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop(true);
          } else if (state is TaskError) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: _isLoadingInitial
            ? const AppLoadingIndicator(message: 'Loading task information...')
            : _initialError != null
            ? AppErrorView(message: _initialError!, onRetry: _loadTaskData)
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppBreakpoints.contentMaxWidth(context),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Task Title
                          Container(
                            key: _titleKey,
                            child: AppTextField(
                              label: 'Task Title',
                              hint: 'e.g. Implement user authentication',
                              controller: _titleController,
                              focusNode: _titleFocusNode,
                              isRequired: true,
                              validator: AppValidators.taskTitle,
                              maxLength: 100,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Description
                          Container(
                            key: _descriptionKey,
                            child: AppTextField(
                              label: 'Description',
                              hint:
                                  'Add details, context, and criteria (optional)',
                              controller: _descriptionController,
                              focusNode: _descriptionFocusNode,
                              validator: AppValidators.taskDescription,
                              maxLines: 4,
                              maxLength: 1000,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Status Dropdown
                          Container(
                            key: _statusKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text(
                                      'Status',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    Text(
                                      ' *',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs + 2),
                                DropdownButtonFormField<TaskStatus>(
                                  initialValue: _status,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 12,
                                    ),
                                  ),
                                  validator: (val) =>
                                      val == null ? 'Status is required' : null,
                                  items: TaskStatus.values.map((status) {
                                    return DropdownMenuItem<TaskStatus>(
                                      value: status,
                                      child: Text(status.label),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _status = val;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Assignee Dropdown
                          const Text(
                            'Assignee',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs + 2),
                          BlocBuilder<TeamBloc, TeamState>(
                            builder: (context, teamState) {
                              List<UserModel> members = [];
                              if (teamState is TeamLoaded) {
                                members = teamState.members;
                              }

                              return DropdownButtonFormField<int?>(
                                initialValue: _selectedAssigneeId,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: 12,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('Unassigned (None)'),
                                  ),
                                  ...members.map((m) {
                                    return DropdownMenuItem<int?>(
                                      value: m.id,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          UserAvatar(
                                            user: m,
                                            size: 22,
                                            fontSize: 9,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(m.name),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedAssigneeId = val;
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Due Date Picker Field with FormField Validator
                          Container(
                            key: _dueDateKey,
                            child: FormField<DateTime>(
                              initialValue: _selectedDueDate,
                              validator: (val) =>
                                  AppValidators.dueDate(_selectedDueDate),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              builder: (fieldState) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text(
                                          'Due Date',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimaryLight,
                                          ),
                                        ),
                                        Text(
                                          ' *',
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs + 2),
                                    InkWell(
                                      onTap: () => _selectDueDate(fieldState),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMd,
                                      ),
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          suffixIcon: const Icon(
                                            Icons.calendar_month_outlined,
                                            size: 20,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: AppSpacing.md,
                                                vertical: 14,
                                              ),
                                          errorText: fieldState.errorText,
                                        ),
                                        child: Text(
                                          _selectedDueDate != null
                                              ? DateFormat(
                                                  'EEEE, MMMM d, yyyy',
                                                ).format(_selectedDueDate!)
                                              : 'Select a due date',
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            color: _selectedDueDate != null
                                                ? AppColors.textPrimaryLight
                                                : AppColors.textMutedLight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Submit Button
                          AppButton(
                            label: widget.isEditing
                                ? 'Save Changes'
                                : 'Create Task',
                            isLoading: _isSubmitting,
                            onPressed: _isSubmitting ? null : _onSubmit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
