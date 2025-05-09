// Generated by row_row_row tool
// Auto-generated file. Do not modify.
class GroupMemberRow {
  static const table = 'group_member';

  static const field = (
    id: 'id',
    createdAt: 'created_at',
    member: 'member',
    assignedBy: 'assigned_by',
    group: 'group',
  );

  final String id;
  final DateTime createdAt;
  final String? member;
  final String? assignedBy;
  final String? group;

  const GroupMemberRow({
    required this.id,
    required this.createdAt,
    this.member,
    this.assignedBy,
    this.group,
  });

  factory GroupMemberRow.fromJson(Map<String, dynamic> json) {
    return GroupMemberRow(
      id: json[field.id] as String,
      createdAt: DateTime.parse(json[field.createdAt]),
      member: json[field.member],
      assignedBy: json[field.assignedBy],
      group: json[field.group],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      field.id: id,
      field.createdAt: createdAt.toIso8601String(),
      field.member: member,
      field.assignedBy: assignedBy,
      field.group: group,
    };
  }

  GroupMemberRow copyWith({
    String? id,
    DateTime? createdAt,
    String? member,
    String? assignedBy,
    String? group,
  }) {
    return GroupMemberRow(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      member: member ?? this.member,
      assignedBy: assignedBy ?? this.assignedBy,
      group: group ?? this.group,
    );
  }
}
