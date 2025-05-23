// Generated by row_row_row tool
// Auto-generated file. Do not modify.
class ChatRoomMemberRow {
  static const table = 'chat_room_member';

  static const field = (
    id: 'id',
    chatRoom: 'chat_room',
    member: 'member',
    addedBy: 'added_by',
    isAdmin: 'is_admin',
    createdAt: 'created_at',
  );

  final String id;
  final String chatRoom;
  final String? member;
  final String? addedBy;
  final bool isAdmin;
  final DateTime createdAt;

  const ChatRoomMemberRow({
    required this.id,
    required this.chatRoom,
    this.member,
    this.addedBy,
    required this.isAdmin,
    required this.createdAt,
  });

  factory ChatRoomMemberRow.fromJson(Map<String, dynamic> json) {
    return ChatRoomMemberRow(
      id: json[field.id] as String,
      chatRoom: json[field.chatRoom] as String,
      member: json[field.member],
      addedBy: json[field.addedBy],
      isAdmin: json[field.isAdmin] as bool,
      createdAt: DateTime.parse(json[field.createdAt]),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      field.id: id,
      field.chatRoom: chatRoom,
      field.member: member,
      field.addedBy: addedBy,
      field.isAdmin: isAdmin,
      field.createdAt: createdAt.toIso8601String(),
    };
  }

  ChatRoomMemberRow copyWith({
    String? id,
    String? chatRoom,
    String? member,
    String? addedBy,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return ChatRoomMemberRow(
      id: id ?? this.id,
      chatRoom: chatRoom ?? this.chatRoom,
      member: member ?? this.member,
      addedBy: addedBy ?? this.addedBy,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
