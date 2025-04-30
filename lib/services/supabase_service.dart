import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sgm/config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient? _client;

  // Get the initialized Supabase client
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase client has not been initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: kDebugMode,
    );
    _client = Supabase.instance.client;
  }

  // Get current user
  static User? get currentUser => client.auth.currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  // Sign in with email and password
  static Future<AuthResponse> signInWithEmail(
    String email,
    String password,
  ) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  static Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
  ) async {
    return await client.auth.signUp(email: email, password: password);
  }

  // Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Get current session
  static Session? get currentSession => client.auth.currentSession;

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
