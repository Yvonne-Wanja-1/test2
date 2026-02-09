import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final SupabaseClient _supabaseClient;
  late final GoogleSignIn _googleSignIn;

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
    _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  }

  SupabaseClient get client => _supabaseClient;
  GoogleSignIn get googleSignIn => _googleSignIn;

  // Get current user
  User? get currentUser => _supabaseClient.auth.currentUser;

  // Sign in with Gmail
  Future<AuthResponse> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      throw Exception('No access token or ID token');
    }

    final response = await _supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return response;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
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
