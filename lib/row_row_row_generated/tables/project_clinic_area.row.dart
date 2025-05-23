// Generated by row_row_row tool
// Auto-generated file. Do not modify.
class ProjectClinicAreaRow {
  static const table = 'project_clinic_area';

  static const field = (
    id: 'id',
    areaName: 'area_name',
    description: 'description',
    createdBy: 'created_by',
    createdAt: 'created_at',
  );

  final String id;
  final String? areaName;
  final String? description;
  final String? createdBy;
  final DateTime createdAt;

  const ProjectClinicAreaRow({
    required this.id,
    this.areaName,
    this.description,
    this.createdBy,
    required this.createdAt,
  });

  factory ProjectClinicAreaRow.fromJson(Map<String, dynamic> json) {
    return ProjectClinicAreaRow(
      id: json[field.id] as String,
      areaName: json[field.areaName],
      description: json[field.description],
      createdBy: json[field.createdBy],
      createdAt: DateTime.parse(json[field.createdAt]),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      field.id: id,
      field.areaName: areaName,
      field.description: description,
      field.createdBy: createdBy,
      field.createdAt: createdAt.toIso8601String(),
    };
  }

  ProjectClinicAreaRow copyWith({
    String? id,
    String? areaName,
    String? description,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return ProjectClinicAreaRow(
      id: id ?? this.id,
      areaName: areaName ?? this.areaName,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
