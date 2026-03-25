import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const ArcanaApp(),
    ),
  );
}

class ArcanaApp extends StatelessWidget {
  const ArcanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arcana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07061A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC8A84B),
          secondary: Color(0xFFEAD98A),
          surface: Color(0xFF0E0A2A),
        ),
        textTheme: GoogleFonts.cormorantGaramondTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.cinzel(
            color: const Color(0xFFC8A84B),
            fontSize: 42,
            fontWeight: FontWeight.w400,
            letterSpacing: 8,
          ),
        ),
        useMaterial3: true,
      ),
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (auth.token == null) return const WelcomeScreen();
          return const HomeScreen();
        },
      ),
    );
  }
}
