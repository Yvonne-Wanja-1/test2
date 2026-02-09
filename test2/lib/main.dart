import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_splash_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_completion_screen.dart';
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

  @override
  void initState() {
    super.initState();
    // Simulate first launch only once
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isFirstLaunch = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstLaunch) {
      return const AuthSplashScreen();
    }

    return StreamBuilder<AuthState>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is authenticated
        final session = snapshot.data?.session;
        final user = session?.user;

        if (session != null) {
          // Check if user profile is complete
          final profileComplete = user?.userMetadata?['profile_complete'] ?? false;
          
          if (profileComplete) {
            // User is signed in and profile is complete
            return const HomeScreen();
          } else {
            // User is signed in but needs to complete profile
            return ProfileCompletionScreen(
              onProfileComplete: () {
                // Navigation happens automatically via StreamBuilder
              },
            );
          }
        } else {
          // User is not signed in
          return SignInScreen(
            onSignInSuccess: () {
              // Navigation will happen automatically via StreamBuilder
            },
          );
        }
      },
    );
  }
}
