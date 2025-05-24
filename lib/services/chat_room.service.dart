import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/chat_room.row.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';
import 'package:sgm/services/project.service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling chat room-related operations with Supabase.
class ChatRoomService {
  // Singleton instance
  static final ChatRoomService _instance = ChatRoomService._internal();

  // Factory constructor to return the singleton instance
  factory ChatRoomService() => _instance;

  // Private constructor
  ChatRoomService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  // Cache for chat rooms
  final Map<String, dynamic> _cache = {};

  // Cache for user's chat rooms
  Map<String, List<ChatRoomRow>> _userChatRoomsCache = {};

  /// Gets all chat rooms
  Future<List<ChatRoomRow>> getAllChatRooms({bool forceRefresh = false}) async {
    try {
      final response = await _supabase
          .from('chat_room')
          .select()
          .order(ChatRoomRow.field.lastMessageAt, ascending: false);

      final chatRooms =
          response.map<ChatRoomRow>((data) {
            final chatRoom = ChatRoomRow.fromJson(data);
            _cache[chatRoom.id] = data;
            return chatRoom;
          }).toList();

      return chatRooms;
    } catch (error) {
      debugPrint('Error fetching chat rooms: $error');
      return [];
    }
  }

  /// Gets a chat room by its ID.
  Future<ChatRoomRow?> getChatRoomById(String id, {bool cached = true}) async {
    if (cached && _cache[id] != null) {
      return ChatRoomRow.fromJson(_cache[id]!);
    }

    try {
      final response =
          await _supabase
              .from('chat_room')
              .select()
              .eq(ChatRoomRow.field.id, id)
              .single();

      final chatRoom = ChatRoomRow.fromJson(response);
      _cache[id] = response;
      return chatRoom;
    } catch (error) {
      debugPrint('Error fetching chat room by ID: $error');
      return null;
    }
  }

  /// Gets chat rooms for a specific user
  Future<List<ChatRoomRow>> getChatRoomsByUserId(
    String userId, {
    bool forceRefresh = false,
  }) async {
    // Return cached result if available and not forcing refresh
    if (!forceRefresh && _userChatRoomsCache.containsKey(userId)) {
      return _userChatRoomsCache[userId]!;
    }

    try {
      // Find chat rooms where the user is in singleChatFor
      final response = await _supabase
          .from('chat_room')
          .select()
          .contains(ChatRoomRow.field.singleChatFor, [userId])
          .order(ChatRoomRow.field.lastMessageAt, ascending: false);

      final chatRooms =
          response.map<ChatRoomRow>((data) {
            final chatRoom = ChatRoomRow.fromJson(data);
            _cache[chatRoom.id] = data;
            return chatRoom;
          }).toList();

      // Update cache
      _userChatRoomsCache[userId] = chatRooms;

      return chatRooms;
    } catch (error) {
      debugPrint('Error fetching chat rooms by user ID: $error');
      return [];
    }
  }

  /// Gets chat rooms for a specific project/clinic
  Future<List<ChatRoomRow>> getChatRoomsByProjectId(
    String projectId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _supabase
          .from('chat_room')
          .select()
          .eq(ChatRoomRow.field.projectClinicRel, projectId)
          .order(ChatRoomRow.field.lastMessageAt, ascending: false);

      final chatRooms =
          response.map<ChatRoomRow>((data) {
            final chatRoom = ChatRoomRow.fromJson(data);
            _cache[chatRoom.id] = data;
            return chatRoom;
          }).toList();

      return chatRooms;
    } catch (error) {
      debugPrint('Error fetching chat rooms by project ID: $error');
      return [];
    }
  }

  /// Creates a new chat room
  Future<ChatRoomRow?> createChatRoom({
    required String name,
    required String createdBy,
    String? projectClinicRel,
    bool isApproved = false,
    List<String>? singleChatFor,
    String? photo,
  }) async {
    try {
      final data = {
        ChatRoomRow.field.name: name,
        ChatRoomRow.field.createdBy: createdBy,
        ChatRoomRow.field.isActive: true,
        ChatRoomRow.field.projectClinicRel: projectClinicRel,
        ChatRoomRow.field.isApproved: isApproved,
        ChatRoomRow.field.singleChatFor: singleChatFor,
        ChatRoomRow.field.photo: photo,
      };

      final response =
          await _supabase.from('chat_room').insert(data).select().single();

      final chatRoom = ChatRoomRow.fromJson(response);
      _cache[chatRoom.id] = response;

      // Clear user cache to force refresh
      if (singleChatFor != null) {
        for (final userId in singleChatFor) {
          _userChatRoomsCache.remove(userId);
        }
      }

      return chatRoom;
    } catch (error) {
      debugPrint('Error creating chat room: $error');
      return null;
    }
  }

  /// Updates an existing chat room
  Future<ChatRoomRow?> updateChatRoom({
    required String id,
    String? name,
    DateTime? lastMessageAt,
    bool? isActive,
    String? lastMessage,
    String? photo,
    String? projectClinicRel,
    bool? isApproved,
    List<String>? singleChatFor,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data[ChatRoomRow.field.name] = name;
      if (lastMessageAt != null)
        data[ChatRoomRow.field.lastMessageAt] = lastMessageAt.toIso8601String();
      if (isActive != null) data[ChatRoomRow.field.isActive] = isActive;
      if (lastMessage != null)
        data[ChatRoomRow.field.lastMessage] = lastMessage;
      if (photo != null) data[ChatRoomRow.field.photo] = photo;
      if (projectClinicRel != null)
        data[ChatRoomRow.field.projectClinicRel] = projectClinicRel;
      if (isApproved != null) data[ChatRoomRow.field.isApproved] = isApproved;
      if (singleChatFor != null)
        data[ChatRoomRow.field.singleChatFor] = singleChatFor;

      if (data.isEmpty) {
        // Nothing to update
        final cachedRoom = await getChatRoomById(id);
        return cachedRoom;
      }

      final response =
          await _supabase
              .from('chat_room')
              .update(data)
              .eq(ChatRoomRow.field.id, id)
              .select()
              .single();

      final chatRoom = ChatRoomRow.fromJson(response);
      _cache[id] = response;

      // Clear user cache if singleChatFor is updated
      if (singleChatFor != null) {
        for (final userId in singleChatFor) {
          _userChatRoomsCache.remove(userId);
        }
      }

      return chatRoom;
    } catch (error) {
      debugPrint('Error updating chat room: $error');
      return null;
    }
  }

  /// Updates the last message information for a chat room
  Future<bool> updateLastMessage({
    required String chatRoomId,
    required String message,
  }) async {
    try {
      final now = DateTime.now();
      await _supabase
          .from('chat_room')
          .update({
            ChatRoomRow.field.lastMessage: message,
            ChatRoomRow.field.lastMessageAt: now.toIso8601String(),
          })
          .eq(ChatRoomRow.field.id, chatRoomId);

      // Update cache
      if (_cache[chatRoomId] != null) {
        _cache[chatRoomId][ChatRoomRow.field.lastMessage] = message;
        _cache[chatRoomId][ChatRoomRow.field.lastMessageAt] =
            now.toIso8601String();
      }

      // Clear all user caches to ensure they get the updated chat room order
      _userChatRoomsCache = {};

      return true;
    } catch (error) {
      debugPrint('Error updating last message: $error');
      return false;
    }
  }

  /// Clears the cache for this service
  void clearCache() {
    _cache.clear();
    _userChatRoomsCache.clear();
  }
}
