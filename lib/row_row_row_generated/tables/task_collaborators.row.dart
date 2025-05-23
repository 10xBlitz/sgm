// Generated by row_row_row tool
// Auto-generated file. Do not modify.
class TaskCollaboratorsRow {
  static const table = 'task_collaborators';

  static const field = (
    id: 'id',
    createdAt: 'created_at',
    collaborator: 'collaborator',
    assignedBy: 'assigned_by',
    task: 'task',
  );

  final String id;
  final DateTime createdAt;
  final String? collaborator;
  final String? assignedBy;
  final String? task;

  const TaskCollaboratorsRow({
    required this.id,
    required this.createdAt,
    this.collaborator,
    this.assignedBy,
    this.task,
  });

  factory TaskCollaboratorsRow.fromJson(Map<String, dynamic> json) {
    return TaskCollaboratorsRow(
      id: json[field.id] as String,
      createdAt: DateTime.parse(json[field.createdAt]),
      collaborator: json[field.collaborator],
      assignedBy: json[field.assignedBy],
      task: json[field.task],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      field.id: id,
      field.createdAt: createdAt.toIso8601String(),
      field.collaborator: collaborator,
      field.assignedBy: assignedBy,
      field.task: task,
    };
  }

  TaskCollaboratorsRow copyWith({
    String? id,
    DateTime? createdAt,
    String? collaborator,
    String? assignedBy,
    String? task,
  }) {
    return TaskCollaboratorsRow(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      collaborator: collaborator ?? this.collaborator,
      assignedBy: assignedBy ?? this.assignedBy,
      task: task ?? this.task,
    );
  }
}
