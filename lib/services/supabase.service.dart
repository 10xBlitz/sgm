import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sgm/config/supabase_config.dart';

/// A singleton service that manages Supabase authentication and client access.
class SupabaseService {
  // Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();

  // Private constructor
  SupabaseService._internal();

  // Factory constructor to return the same instance
  factory SupabaseService() => _instance;

  // Supabase client instance
  SupabaseClient? _client;

  // Get the initialized Supabase client
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase client has not been initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  // Initialize Supabase
  Future<void> initialize() async {
    if (_client != null) return;

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: kDebugMode,
    );
    _client = Supabase.instance.client;
  }

  // Get current user
  User? get currentUser => client.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Get current session
  Session? get currentSession => client.auth.currentSession;

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
