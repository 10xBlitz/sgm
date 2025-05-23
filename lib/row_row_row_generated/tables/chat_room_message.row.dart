// Generated by row_row_row tool
// Auto-generated file. Do not modify.
class ChatRoomMessageRow {
  static const table = 'chat_room_message';

  static const field = (
    id: 'id',
    text: 'text',
    attachment: 'attachment',
    sentBy: 'sent_by',
    chatRoom: 'chat_room',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    image: 'image',
    deletedAt: 'deleted_at',
    deletedBy: 'deleted_by',
  );

  final String id;
  final String? text;
  final String? attachment;
  final String? sentBy;
  final String? chatRoom;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? image;
  final DateTime? deletedAt;
  final String? deletedBy;

  const ChatRoomMessageRow({
    required this.id,
    this.text,
    this.attachment,
    this.sentBy,
    this.chatRoom,
    required this.createdAt,
    this.updatedAt,
    this.image,
    this.deletedAt,
    this.deletedBy,
  });

  factory ChatRoomMessageRow.fromJson(Map<String, dynamic> json) {
    return ChatRoomMessageRow(
      id: json[field.id] as String,
      text: json[field.text],
      attachment: json[field.attachment],
      sentBy: json[field.sentBy],
      chatRoom: json[field.chatRoom],
      createdAt: DateTime.parse(json[field.createdAt]),
      updatedAt:
          json[field.updatedAt] == null
              ? null
              : DateTime.tryParse(json[field.updatedAt] ?? ''),
      image: json[field.image],
      deletedAt:
          json[field.deletedAt] == null
              ? null
              : DateTime.tryParse(json[field.deletedAt] ?? ''),
      deletedBy: json[field.deletedBy],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      field.id: id,
      field.text: text,
      field.attachment: attachment,
      field.sentBy: sentBy,
      field.chatRoom: chatRoom,
      field.createdAt: createdAt.toIso8601String(),
      field.updatedAt: updatedAt?.toIso8601String(),
      field.image: image,
      field.deletedAt: deletedAt?.toIso8601String(),
      field.deletedBy: deletedBy,
    };
  }

  ChatRoomMessageRow copyWith({
    String? id,
    String? text,
    String? attachment,
    String? sentBy,
    String? chatRoom,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? image,
    DateTime? deletedAt,
    String? deletedBy,
  }) {
    return ChatRoomMessageRow(
      id: id ?? this.id,
      text: text ?? this.text,
      attachment: attachment ?? this.attachment,
      sentBy: sentBy ?? this.sentBy,
      chatRoom: chatRoom ?? this.chatRoom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      image: image ?? this.image,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }
}
