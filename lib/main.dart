import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';

const supabaseUrl = 'https://kiyruyneaaiwveblaucf.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtpeXJ1eW5lYWFpd3ZlYmxhdWNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwMjAxMDgsImV4cCI6MjA5ODU5NjEwOH0.3n4JWy4Q5whtjx1nr9mDnzJ6eFtr6_8TiMSMFgYBP3o';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const CongoConnectApp());
}

final supabase = Supabase.instance.client;

class CongoConnectApp extends StatelessWidget {
  const CongoConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Congo Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0057B8),
          primary: const Color(0xFF0057B8),
          secondary: const Color(0xFF2E8B57),
          tertiary: const Color(0xFFF39C12),
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0057B8),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;
        if (session != null) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}
