import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_page.dart';

// ⚠️ Remplace ces deux valeurs par les tiennes
// (Supabase → Project Settings → API)
const supabaseUrl = 'https://kiyruyneaaiwveblaucf.supabase.co';
const supabaseAnonKey = 'COLLE_ICI_TA_CLE_ANON_PUBLIC';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const CongoConnectApp());
}

// Accès rapide au client Supabase depuis n'importe où dans l'app
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
      home: const HomePage(),
    );
  }
}
