import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/services/supabase.service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  bool _isInitialized = false;

  final supabaseService = SupabaseService();

  // FutureOr<bool> approvedUser = false;

  // Initialize the auth service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Supabase using the singleton instance
    await supabaseService.initialize();

    // Listen for auth changes
    supabaseService.authStateChanges.listen((event) async {
      final userId = supabaseService.currentUser?.id;
      final isAuthenticated = supabaseService.currentUser != null;
      if (!isAuthenticated) _hasLoaded = false;
      final isAnonymous =
          isAuthenticated &&
          (supabaseService.currentUser?.isAnonymous ?? false);
      debugPrint(
        "Current user ID: $userId, Authenticated: $isAuthenticated, Anonymous: $isAnonymous",
      );

      if (!isAuthenticated) {
        _hasLoaded = false;
        currentUserRow = null;
      }

      notifyListeners();
    });

    _isInitialized = true;
  }

  UserRow? currentUserRow;

  FutureOr<bool?>? _hasLoaded = false;

  /// Indicates whether the profile has been loaded
  ///
  /// Returns false if there is no profile
  /// Returns true if the profile is loaded
  /// Returns Future if still loading
  /// Returns null if has error
  FutureOr<bool?>? get hasProfileLoaded => _hasLoaded;

  bool get isApproved => currentUserRow?.acceptedAt != null;
  bool get isConfirmedEmail => currentUserRow?.emailConfirmedAt != null;

  /// Load the user's profile from the database
  ///
  /// Returns true if user has profile the profile was loaded successfully.
  ///
  /// Returns false if tried to load but user has no profile.
  ///
  /// Returns null if there is an error.
  Future<bool?> loadProfile() async {
    if (supabaseService.currentUser == null) return false;
    try {
      final response = await supabaseService.client
          .from('user')
          .select()
          .eq(UserRow.field.id, supabaseService.currentUser!.id);
      debugPrint("Load Profile Response: $response");
      if (response.isEmpty) return false;
      if (response.length > 1) throw Exception("Multiple profiles found");
      currentUserRow = UserRow.fromJson(
        response[0],
      ); // Update to parse the first item
      return true;
    } catch (e) {
      debugPrint('Load profile error: $e');
      return null;
    }
  }

  Future<UserRow?> createProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (supabaseService.currentUser == null) return null;
    try {
      final response =
          await supabaseService.client.from('user').insert({
            UserRow.field.id: supabaseService.currentUser!.id,
            UserRow.field.email: email,
            UserRow.field.name: name,
            UserRow.field.phoneNumber: phone,
            UserRow.field.emailConfirmationCode: _random6Chars(),
          }).single();
      debugPrint("Create Profile Response: $response");
      currentUserRow = UserRow.fromJson(response);
      return currentUserRow;
    } catch (e) {
      debugPrint('Create profile error: $e');
      return null;
    }
  }

  String _random6Chars() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      6,
      (index) => chars[(Random().nextInt(chars.length))],
    ).join();
  }

  /// Sends email confirmation code using Cloud Function
  Future<bool> sendEmailCloudFunctionConfirmation({
    required String email,
    required String code,
  }) async {
    const url =
        'https://us-central1-clinicinquiryforms.cloudfunctions.net/sendEmailConfirmation';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'code': code}),
      );

      debugPrint('Email confirmation API response: ${response.statusCode}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Email confirmation API error: $e');
      return false;
    }
  }

  /// Resends email confirmation code to the current user
  Future<bool> resendEmailConfirmation() async {
    if (currentUser == null) return false;

    // Generate a new confirmation code
    final newCode = _random6Chars();

    try {
      // Update the code in the database
      await supabaseService.client
          .from('user')
          .update({UserRow.field.emailConfirmationCode: newCode})
          .eq(UserRow.field.id, currentUser!.id);

      // Send the confirmation email
      final success = await sendEmailCloudFunctionConfirmation(
        email: currentUser!.email!,
        code: newCode,
      );

      // Reload the profile to get the updated code
      if (success) {
        await loadProfile();
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('Resend email confirmation error: $e');
      return false;
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => supabaseService.isLoggedIn;

  // Get current user
  User? get currentUser => supabaseService.currentUser;

  UserRow? get currentUserProfile => currentUserRow;

  /// Login with email and password
  ///
  /// Returns true if the login was successful, false otherwise.
  Future<bool> login(String email, String password) async {
    _hasLoaded = false;
    try {
      final response = await supabaseService.signInWithEmail(email, password);
      final session = response.session;
      final user = response.user;

      debugPrint("Login attempt response: $response");

      if (session == null || user == null) {
        debugPrint("Login failed: session or user is null");
        return false;
      }

      debugPrint("Login successful for user: ${user.id}");

      _hasLoaded = loadProfile();
      await _hasLoaded;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Register with email and password
  Future<bool> register(String email, String password) async {
    try {
      final response = await supabaseService.signUpWithEmail(email, password);
      final user = response.user;

      // For email confirmation flow, session might be null until confirmed
      if (user == null) {
        return false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await supabaseService.signOut();
    _hasLoaded = false;
    currentUserRow = null;
    notifyListeners();
  }
}
