import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_splash_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/update_password_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase - Update these with your Supabase credentials
  await AuthService().initialize(
    supabaseUrl: 'https://byfzmfnmsfwkwcmepclp.supabase.co',
    supabaseAnonKey: 'sb_publishable_UVSt_8v_1tWjT-3ObX0S3A_fsflCP1U',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthenticationWrapper(),
      routes: {
        '/update-password': (_) => UpdatePasswordScreen(
              onPasswordUpdateSuccess: () {},
            ),
      },
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isFirstLaunch = true;
  bool _isPasswordResetFlow = false;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();

    _setupAuthListener();
    _handleDeepLinks(); // ✅ THIS was missing

    // Simulate first launch only once
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isFirstLaunch = false);
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    // Listen for password recovery event
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      debugPrint('AUTH EVENT: $event');
      debugPrint('SESSION EXISTS: ${session != null}');

      // Fired when Supabase recognizes a recovery link session
      if (event == AuthChangeEvent.passwordRecovery) {
        debugPrint('PASSWORD RECOVERY EVENT DETECTED!');
        if (mounted) {
          setState(() => _isPasswordResetFlow = true);
        }
      }
    });
  }

  Future<void> _handleDeepLinks() async {
    // ✅ Cold start (app was closed)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _processUri(initialUri);
    }

    // ✅ Warm start (app already open)
    _linkSub = _appLinks.uriLinkStream.listen((uri) async {
      if (uri != null) {
        await _processUri(uri);
      }
    });
  }

  Future<void> _processUri(Uri uri) async {
    debugPrint('DEEP LINK RECEIVED: $uri');

    try {
      // 🔥 MOST IMPORTANT LINE:
      // This tells Supabase to parse tokens from the recovery link.
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    } catch (e) {
      debugPrint('getSessionFromUrl error: $e');
    }

    // Optional: also force showing update password screen when link matches
    if (uri.scheme == 'test2' && uri.host == 'reset-password') {
      if (mounted) {
        setState(() => _isPasswordResetFlow = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstLaunch) {
      return const AuthSplashScreen();
    }

    // Priority 1: If in password reset flow, show update password screen
    if (_isPasswordResetFlow) {
      return Scaffold(
        body: UpdatePasswordScreen(
          onPasswordUpdateSuccess: () {
            debugPrint('Password updated successfully, resetting flow');
            setState(() => _isPasswordResetFlow = false);
          },
        ),
      );
    }

    // Priority 2: Check authentication state
    return StreamBuilder<AuthState>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return const HomeScreen();
        }

        return SignInScreen(
          onSignInSuccess: () {
            debugPrint('Sign in successful');
          },
        );
      },
    );
  }
}
