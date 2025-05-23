// Generated by row_row_row tool
// Auto-generated file. Do not modify.
class AnnouncementTargetAudienceViewRow {
  static const table = 'announcement_target_audience_view';

  static const field = (
    announcementId: 'announcement_id',
    announcementTitle: 'announcement_title',
    announcementContent: 'announcement_content',
    announcementCreatedAt: 'announcement_created_at',
    taggedGroupIds: 'tagged_group_ids',
    taggedGroupNames: 'tagged_group_names',
    taggedRoleIds: 'tagged_role_ids',
    taggedRoleNames: 'tagged_role_names',
    taggedUserIds: 'tagged_user_ids',
    taggedUserNames: 'tagged_user_names',
  );

  final String? announcementId;
  final String? announcementTitle;
  final String? announcementContent;
  final DateTime? announcementCreatedAt;
  final List<String>? taggedGroupIds;
  final List<String>? taggedGroupNames;
  final List<String>? taggedRoleIds;
  final List<String>? taggedRoleNames;
  final List<String>? taggedUserIds;
  final List<String>? taggedUserNames;

  const AnnouncementTargetAudienceViewRow({
    this.announcementId,
    this.announcementTitle,
    this.announcementContent,
    this.announcementCreatedAt,
    this.taggedGroupIds,
    this.taggedGroupNames,
    this.taggedRoleIds,
    this.taggedRoleNames,
    this.taggedUserIds,
    this.taggedUserNames,
  });

  factory AnnouncementTargetAudienceViewRow.fromJson(
    Map<String, dynamic> json,
  ) {
    return AnnouncementTargetAudienceViewRow(
      announcementId: json[field.announcementId],
      announcementTitle: json[field.announcementTitle],
      announcementContent: json[field.announcementContent],
      announcementCreatedAt:
          json[field.announcementCreatedAt] == null
              ? null
              : DateTime.tryParse(json[field.announcementCreatedAt] ?? ''),
      taggedGroupIds:
          json[field.taggedGroupIds] == null
              ? null
              : List<String>.from(json[field.taggedGroupIds]),
      taggedGroupNames:
          json[field.taggedGroupNames] == null
              ? null
              : List<String>.from(json[field.taggedGroupNames]),
      taggedRoleIds:
          json[field.taggedRoleIds] == null
              ? null
              : List<String>.from(json[field.taggedRoleIds]),
      taggedRoleNames:
          json[field.taggedRoleNames] == null
              ? null
              : List<String>.from(json[field.taggedRoleNames]),
      taggedUserIds:
          json[field.taggedUserIds] == null
              ? null
              : List<String>.from(json[field.taggedUserIds]),
      taggedUserNames:
          json[field.taggedUserNames] == null
              ? null
              : List<String>.from(json[field.taggedUserNames]),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      field.announcementId: announcementId,
      field.announcementTitle: announcementTitle,
      field.announcementContent: announcementContent,
      field.announcementCreatedAt: announcementCreatedAt?.toIso8601String(),
      field.taggedGroupIds: taggedGroupIds,
      field.taggedGroupNames: taggedGroupNames,
      field.taggedRoleIds: taggedRoleIds,
      field.taggedRoleNames: taggedRoleNames,
      field.taggedUserIds: taggedUserIds,
      field.taggedUserNames: taggedUserNames,
    };
  }

  AnnouncementTargetAudienceViewRow copyWith({
    String? announcementId,
    String? announcementTitle,
    String? announcementContent,
    DateTime? announcementCreatedAt,
    List<String>? taggedGroupIds,
    List<String>? taggedGroupNames,
    List<String>? taggedRoleIds,
    List<String>? taggedRoleNames,
    List<String>? taggedUserIds,
    List<String>? taggedUserNames,
  }) {
    return AnnouncementTargetAudienceViewRow(
      announcementId: announcementId ?? this.announcementId,
      announcementTitle: announcementTitle ?? this.announcementTitle,
      announcementContent: announcementContent ?? this.announcementContent,
      announcementCreatedAt:
          announcementCreatedAt ?? this.announcementCreatedAt,
      taggedGroupIds: taggedGroupIds ?? this.taggedGroupIds,
      taggedGroupNames: taggedGroupNames ?? this.taggedGroupNames,
      taggedRoleIds: taggedRoleIds ?? this.taggedRoleIds,
      taggedRoleNames: taggedRoleNames ?? this.taggedRoleNames,
      taggedUserIds: taggedUserIds ?? this.taggedUserIds,
      taggedUserNames: taggedUserNames ?? this.taggedUserNames,
    );
  }
}
