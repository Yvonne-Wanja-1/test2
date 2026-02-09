import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
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

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Check if user is authenticated
        final session = snapshot.data?.session;

        if (session != null) {
          // User is signed in
          return const HomeScreen();
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
