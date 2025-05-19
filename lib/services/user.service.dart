import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling user-related operations with Supabase.
class UserService {
  // Singleton instance
  static final UserService _instance = UserService._internal();

  // Factory constructor to return the singleton instance
  factory UserService() => _instance;

  // Private constructor
  UserService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  // Cache for user objects
  final Map<String, UserRow> _cache = {};

  /// Gets all users with optional filters.
  Future<List<UserRow>> getAllUsers({String? role, bool? activated, bool? isBanned}) async {
    try {
      var query = _supabase.from(UserRow.table).select();

      // Apply filters first
      if (role != null) {
        query = query.filter(UserRow.field.role, 'eq', role);
      }

      if (activated != null) {
        query = query.filter(UserRow.field.activated, 'eq', activated);
      }

      if (isBanned != null) {
        query = query.filter(UserRow.field.isBanned, 'eq', isBanned);
      }

      // Then apply ordering
      final response = await query.order(UserRow.field.createdAt, ascending: false);

      final users =
          response.map<UserRow>((dynamic data) {
            try {
              if (data is! Map<String, dynamic>) {
                final convertedData = Map<String, dynamic>.from(data as Map);
                final user = UserRow.fromJson(convertedData);
                _cache[user.id] = user;
                return user;
              }

              final user = UserRow.fromJson(data);
              _cache[user.id] = user;
              return user;
            } catch (e) {
              debugPrint('Error converting user data: $e');
              debugPrint('Problematic data: $data');
              rethrow;
            }
          }).toList();

      return users;
    } catch (error) {
      debugPrint('Error fetching users: $error');
      return [];
    }
  }

  /// Searches users by name and email.
  Future<List<UserRow>> searchUsers(String query) async {
    try {
      final response = await _supabase
          .from(UserRow.table)
          .select()
          .or('name.ilike.%$query%,email.ilike.%$query%')
          .order(UserRow.field.createdAt, ascending: false);

      final users =
          response.map<UserRow>((data) {
            final user = UserRow.fromJson(data);
            _cache[user.id] = user;
            return user;
          }).toList();

      return users;
    } catch (error) {
      debugPrint('Error searching users: $error');
      return [];
    }
  }

  Future<UserRow?> getById(String id, {bool cached = true}) async {
    if (cached && _cache.containsKey(id)) {
      return _cache[id];
    }
    try {
      final response =
      await _supabase
          .from(UserRow.table)
          .select()
          .eq(UserRow.field.id, id)
          .single();
      final user = UserRow.fromJson(response);
      _cache[id] = user;
      return user;
    } catch (error) {
      debugPrint('Error fetching user by ID: $error');
      return null;
    }
  }
  /// Clears the cache
  void clearCache() {
    _cache.clear();
  }
}
