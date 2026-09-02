import 'package:equatable/equatable.dart';
import 'user_model.dart';

enum TaskStatus {
  todo('TODO', 'Todo'),
  inProgress('IN_PROGRESS', 'In Progress'),
  done('DONE', 'Done');

  final String value;
  final String label;
  const TaskStatus(this.value, this.label);

  static TaskStatus fromString(String? val) {
    if (val == null) return TaskStatus.todo;
    switch (val.toUpperCase()) {
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'DONE':
        return TaskStatus.done;
      case 'TODO':
      default:
        return TaskStatus.todo;
    }
  }
}

class TaskModel extends Equatable {
  final int id;
  final String title;
  final String? description;
  final TaskStatus status;
  final String dueDate;
  final UserModel? assignee;
  final UserModel? createdBy;
  final String? createdAt;
  final String? updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.dueDate,
    this.assignee,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      status: TaskStatus.fromString(json['status'] as String?),
      dueDate: json['dueDate'] as String? ?? json['due_date'] as String? ?? '',
      assignee: json['assignee'] != null
          ? UserModel.fromJson(json['assignee'] as Map<String, dynamic>)
          : null,
      createdBy: json['createdBy'] != null
          ? UserModel.fromJson(json['createdBy'] as Map<String, dynamic>)
          : json['created_by'] != null
          ? UserModel.fromJson(json['created_by'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.value,
      'dueDate': dueDate,
      'assignee': assignee?.toJson(),
      'createdBy': createdBy?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    String? dueDate,
    UserModel? assignee,
    UserModel? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assignee: assignee ?? this.assignee,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    dueDate,
    assignee,
    createdBy,
    createdAt,
    updatedAt,
  ];
}
