import 'package:flutter/foundation.dart';
import 'package:sgm/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  bool _isInitialized = false;

  // Initialize the auth service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Supabase using the singleton instance
    await supabaseService.initialize();

    // Listen for auth changes
    supabaseService.authStateChanges.listen((event) {
      notifyListeners();
    });

    _isInitialized = true;
  }

  // Check if user is logged in
  bool get isLoggedIn => supabaseService.isLoggedIn;

  // Get current user
  User? get currentUser => supabaseService.currentUser;

  // Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      final response = await supabaseService.signInWithEmail(email, password);
      final session = response.session;
      final user = response.user;

      debugPrint("Login attempt response: $response");

      if (session == null || user == null) {
        return false;
      }

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
      final session = response.session;
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
    notifyListeners();
  }
}

// Create a global instance for easy access
final authService = AuthService();
