// Generated by row_row_row tool
// Auto-generated file. Do not modify.
class ChatCategoryRoomRelationRow {
  static const table = 'chat_category_room_relation';

  static const field = (
    chatId: 'chat_id',
    user: 'user',
    createdAt: 'created_at',
    category: 'category',
  );

  final String chatId;
  final String user;
  final DateTime createdAt;
  final String category;

  const ChatCategoryRoomRelationRow({
    required this.chatId,
    required this.user,
    required this.createdAt,
    required this.category,
  });

  factory ChatCategoryRoomRelationRow.fromJson(Map<String, dynamic> json) {
    return ChatCategoryRoomRelationRow(
      chatId: json[field.chatId] as String,
      user: json[field.user] as String,
      createdAt: DateTime.parse(json[field.createdAt]),
      category: json[field.category] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      field.chatId: chatId,
      field.user: user,
      field.createdAt: createdAt.toIso8601String(),
      field.category: category,
    };
  }

  ChatCategoryRoomRelationRow copyWith({
    String? chatId,
    String? user,
    DateTime? createdAt,
    String? category,
  }) {
    return ChatCategoryRoomRelationRow(
      chatId: chatId ?? this.chatId,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
