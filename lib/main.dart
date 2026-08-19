import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_page.dart';
import 'screens/reset_password_page.dart';
import 'services/remember_me_store.dart';

const supabaseUrl = 'https://kiyruyneaaiwveblaucf.supabase.co';
const supabaseAnonKey = 'sb_publishable_z2dH9HoqzI5HSXbwEcWCXg_AhVielKx';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const CongoConnectApp());
}

final supabase = Supabase.instance.client;
final navigatorKey = GlobalKey<NavigatorState>();

class CongoConnectApp extends StatefulWidget {
  const CongoConnectApp({super.key});

  @override
  State<CongoConnectApp> createState() => _CongoConnectAppState();
}

class _CongoConnectAppState extends State<CongoConnectApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Quand le lien "mot de passe oublié" est ouvert, Supabase déclenche
    // cet événement — on redirige alors vers l'écran de nouveau mot de passe.
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si l'utilisateur a décoché "Se souvenir de moi", on le déconnecte
    // quand il ferme complètement l'application.
    if (state == AppLifecycleState.detached) {
      RememberMeStore.getRememberMe().then((remember) {
        if (!remember) {
          supabase.auth.signOut();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Congo Connect',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
      home: const HomePage(),
    );
  }
}
