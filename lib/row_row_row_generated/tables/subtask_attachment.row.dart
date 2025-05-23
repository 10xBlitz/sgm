// Generated by row_row_row tool
// Auto-generated file. Do not modify.
class SubtaskAttachmentRow {
  static const table = 'subtask_attachment';

  static const field = (
    id: 'id',
    name: 'name',
    isImage: 'is_image',
    subtask: 'subtask',
    createdAt: 'created_at',
    uploadedBy: 'uploaded_by',
    url: 'url',
    asanaGid: 'asana_gid',
    fileName: 'file_name',
    folderName: 'folder_name',
    bucketName: 'bucket_name',
  );

  final String id;
  final String? name;
  final bool isImage;
  final String? subtask;
  final DateTime createdAt;
  final String? uploadedBy;
  final String url;
  final String? asanaGid;
  final String? fileName;
  final String? folderName;
  final String? bucketName;

  const SubtaskAttachmentRow({
    required this.id,
    this.name,
    required this.isImage,
    this.subtask,
    required this.createdAt,
    this.uploadedBy,
    required this.url,
    this.asanaGid,
    this.fileName,
    this.folderName,
    this.bucketName,
  });

  factory SubtaskAttachmentRow.fromJson(Map<String, dynamic> json) {
    return SubtaskAttachmentRow(
      id: json[field.id] as String,
      name: json[field.name],
      isImage: json[field.isImage] as bool,
      subtask: json[field.subtask],
      createdAt: DateTime.parse(json[field.createdAt]),
      uploadedBy: json[field.uploadedBy],
      url: json[field.url] as String,
      asanaGid: json[field.asanaGid],
      fileName: json[field.fileName],
      folderName: json[field.folderName],
      bucketName: json[field.bucketName],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      field.id: id,
      field.name: name,
      field.isImage: isImage,
      field.subtask: subtask,
      field.createdAt: createdAt.toIso8601String(),
      field.uploadedBy: uploadedBy,
      field.url: url,
      field.asanaGid: asanaGid,
      field.fileName: fileName,
      field.folderName: folderName,
      field.bucketName: bucketName,
    };
  }

  SubtaskAttachmentRow copyWith({
    String? id,
    String? name,
    bool? isImage,
    String? subtask,
    DateTime? createdAt,
    String? uploadedBy,
    String? url,
    String? asanaGid,
    String? fileName,
    String? folderName,
    String? bucketName,
  }) {
    return SubtaskAttachmentRow(
      id: id ?? this.id,
      name: name ?? this.name,
      isImage: isImage ?? this.isImage,
      subtask: subtask ?? this.subtask,
      createdAt: createdAt ?? this.createdAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      url: url ?? this.url,
      asanaGid: asanaGid ?? this.asanaGid,
      fileName: fileName ?? this.fileName,
      folderName: folderName ?? this.folderName,
      bucketName: bucketName ?? this.bucketName,
    );
  }
}
