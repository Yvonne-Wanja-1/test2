import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final SupabaseClient _supabaseClient;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    _supabaseClient = Supabase.instance.client;
  }

  SupabaseClient get client => _supabaseClient;

  // Get current user
  User? get currentUser => _supabaseClient.auth.currentUser;

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  // Update password
  Future<void> updatePassword({required String newPassword}) async {
    await _supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        await _supabaseClient.auth.admin.deleteUser(user.id);
        await _supabaseClient.auth.signOut();
      }
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
  }

  // Check authentication state
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  // Get auth session
  Future<Session?> getSession() async {
    return _supabaseClient.auth.currentSession;
  }
}
