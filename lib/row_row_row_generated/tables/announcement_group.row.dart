// Generated by row_row_row tool
// Auto-generated file. Do not modify.
class AnnouncementGroupRow {
  static const table = 'announcement_group';

  static const field = (
    id: 'id',
    announcement: 'announcement',
    group: 'group',
    createdAt: 'created_at',
  );

  final String id;
  final String? announcement;
  final String? group;
  final DateTime createdAt;

  const AnnouncementGroupRow({
    required this.id,
    this.announcement,
    this.group,
    required this.createdAt,
  });

  factory AnnouncementGroupRow.fromJson(Map<String, dynamic> json) {
    return AnnouncementGroupRow(
      id: json[field.id] as String,
      announcement: json[field.announcement],
      group: json[field.group],
      createdAt: DateTime.parse(json[field.createdAt]),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      field.id: id,
      field.announcement: announcement,
      field.group: group,
      field.createdAt: createdAt.toIso8601String(),
    };
  }

  AnnouncementGroupRow copyWith({
    String? id,
    String? announcement,
    String? group,
    DateTime? createdAt,
  }) {
    return AnnouncementGroupRow(
      id: id ?? this.id,
      announcement: announcement ?? this.announcement,
      group: group ?? this.group,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
