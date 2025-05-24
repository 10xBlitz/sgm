import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/chat_room_message.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling chat room messages with Supabase.
class ChatRoomMessagesService {
  // Singleton instance
  static final ChatRoomMessagesService _instance =
      ChatRoomMessagesService._internal();

  // Factory constructor to return the singleton instance
  factory ChatRoomMessagesService() => _instance;

  // Private constructor
  ChatRoomMessagesService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  // Cache for messages by chat room
  final Map<String, List<ChatRoomMessageRow>> _messagesByRoomCache = {};

  /// Gets all messages for a specific chat room
  Future<List<ChatRoomMessageRow>> getMessagesByChatRoomId(
    String chatRoomId, {
    bool cached = true,
    bool forceRefresh = false,
  }) async {
    // Return from cache if available and allowed
    if (cached &&
        !forceRefresh &&
        _messagesByRoomCache.containsKey(chatRoomId)) {
      return _messagesByRoomCache[chatRoomId]!;
    }

    try {
      final response = await _supabase
          .from(ChatRoomMessageRow.table)
          .select()
          .eq(ChatRoomMessageRow.field.chatRoom, chatRoomId)
          .order(ChatRoomMessageRow.field.createdAt);

      final messages =
          response.map<ChatRoomMessageRow>((data) {
            return ChatRoomMessageRow.fromJson(data);
          }).toList();

      // Update cache
      _messagesByRoomCache[chatRoomId] = messages;

      return messages;
    } catch (error) {
      debugPrint('Error fetching messages for chat room: $error');
      return [];
    }
  }

  /// Creates a new message in a chat room
  Future<ChatRoomMessageRow?> createMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
  }) async {
    try {
      final data = {
        ChatRoomMessageRow.field.chatRoom: chatRoomId,
        ChatRoomMessageRow.field.sentBy: senderId,
        ChatRoomMessageRow.field.text: content,
      };

      final response =
          await _supabase
              .from(ChatRoomMessageRow.table)
              .insert(data)
              .select()
              .single();

      final message = ChatRoomMessageRow.fromJson(response);

      // Update cache if exists
      if (_messagesByRoomCache.containsKey(chatRoomId)) {
        _messagesByRoomCache[chatRoomId]!.add(message);
      }

      return message;
    } catch (error) {
      debugPrint('Error creating chat message: $error');
      return null;
    }
  }

  /// Streams messages from a specific chat room in real-time
  Stream<List<ChatRoomMessageRow>> streamChatRoomMessages(String chatRoomId) {
    // First get existing messages
    getMessagesByChatRoomId(chatRoomId, forceRefresh: true);

    // Then set up a stream for new messages
    return _supabase
        .from(ChatRoomMessageRow.table)
        .stream(primaryKey: ['id'])
        .eq(ChatRoomMessageRow.field.chatRoom, chatRoomId)
        .order(ChatRoomMessageRow.field.createdAt, ascending: true)
        // sort in reverse
        .map((data) {
          return data.map<ChatRoomMessageRow>((item) {
            return ChatRoomMessageRow.fromJson(item);
          }).toList();
        });
  }

  /// Deletes a message from a chat room
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _supabase
          .from(ChatRoomMessageRow.table)
          .delete()
          .eq(ChatRoomMessageRow.field.id, messageId);

      // Update all caches that might contain this message
      _messagesByRoomCache.forEach((roomId, messages) {
        _messagesByRoomCache[roomId] =
            messages.where((message) => message.id != messageId).toList();
      });

      return true;
    } catch (error) {
      debugPrint('Error deleting chat message: $error');
      return false;
    }
  }

  /// Updates a message's content
  Future<ChatRoomMessageRow?> updateMessage({
    required String messageId,
    String? content,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (content != null) data[ChatRoomMessageRow.field.text] = content;

      // Don't update if nothing was provided
      if (data.isEmpty) return null;

      final response =
          await _supabase
              .from(ChatRoomMessageRow.table)
              .update(data)
              .eq(ChatRoomMessageRow.field.id, messageId)
              .select()
              .single();

      final message = ChatRoomMessageRow.fromJson(response);

      // Update all caches that might contain this message
      _messagesByRoomCache.forEach((roomId, messages) {
        final index = messages.indexWhere((msg) => msg.id == messageId);
        if (index != -1) {
          _messagesByRoomCache[roomId]![index] = message;
        }
      });

      return message;
    } catch (error) {
      debugPrint('Error updating chat message: $error');
      return null;
    }
  }

  /// Clears all cached messages
  void clearCache() {
    _messagesByRoomCache.clear();
  }

  /// Clears cached messages for a specific chat room
  void clearCacheForRoom(String chatRoomId) {
    _messagesByRoomCache.remove(chatRoomId);
  }
}
