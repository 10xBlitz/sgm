import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
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

  final Map<String, UserRoleRow> _roleCache = {};

  /// Gets all users with optional filters.
  Future<List<UserRow>> getAllUsers({
    String? role,
    bool? activated,
    bool? isBanned,
  }) async {
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
      final response = await query.order(
        UserRow.field.createdAt,
        ascending: false,
      );

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

  /// Gets all new user requests (users with approved_at null and role null).
  ///
  /// Returns a list of users who have requested access but haven't been
  /// approved yet.
  Future<List<UserRow>> getAllNewUserRequests() async {
    try {
      final response = await Supabase.instance.client
          .from('user')
          .select()
          // .not('accepted_at', 'is', null) // accepted_at IS NOT NULL
          .filter('role', 'is', null) // role IS NULL
          .filter(UserRow.field.rejectedAt, 'is', null) // rejectedAt IS NULL
          .order('created_at', ascending: false);
      print('-----> $response');
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
              debugPrint('Error converting user request data: $e');
              debugPrint('Problematic data: $data');
              rethrow;
            }
          }).toList();

      // Add all users to cache with their IDs as keys
      for (final user in users) {
        _cache[user.id] = user;
      }

      return users;
    } catch (error) {
      debugPrint('Error fetching new user requests: $error');
      return [];
    }
  }

  Future<List<UserRoleRow>> fetchUserRolesWithCache() async {
    // If already cached, return the cached values
    if (_roleCache.isNotEmpty) {
      return _roleCache.values.toList();
    }

    try {
      final response = await _supabase
          .from(UserRoleRow.table)
          .select()
          .order(UserRoleRow.field.orderPriority, ascending: true)
          .order(UserRoleRow.field.createdAt, ascending: false);

      // Parse and cache each row
      for (final item in response) {
        try {
          final role = UserRoleRow.fromJson(item);
          _roleCache[role.id] = role;
        } catch (e) {
          debugPrint('Error converting role data: $e');
          debugPrint('Problematic data: $item');
        }
      }

      return _roleCache.values.toList();
    } catch (error) {
      debugPrint('Error fetching user roles: $error');
      return [];
    }
  }

  Future<bool> updateUserRole(String userId, String roleId) async {
    try {
      // Update user with new role and set approvedAt if not already approved
      await _supabase
          .from(UserRow.table)
          .update({UserRow.field.role: roleId})
          .eq(UserRow.field.id, userId);

      // Remove from cache so next fetch will get updated data
      _cache.remove(userId);

      return true;
    } catch (error) {
      debugPrint('Error updating user role: $error');
      return false;
    }
  }

  Future<bool> approveUser(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();

      await _supabase
          .from(UserRow.table)
          .update({UserRow.field.acceptedAt: now})
          .eq(UserRow.field.id, userId);

      // Remove from cache to ensure fresh data on next fetch
      _cache.remove(userId);

      return true;
    } catch (error) {
      debugPrint('Error approving user: $error');
      return false;
    }
  }

  Future<bool> rejectUser(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();

      await _supabase
          .from(UserRow.table)
          .update({UserRow.field.rejectedAt: now})
          .eq(UserRow.field.id, userId);

      // Remove from cache to ensure fresh data on next fetch
      _cache.remove(userId);

      return true;
    } catch (error) {
      debugPrint('Error rejecting user: $error');
      return false;
    }
  }

  /// Clears the cache
  void clearCache() {
    _cache.clear();
    _roleCache.clear();
  }
}
