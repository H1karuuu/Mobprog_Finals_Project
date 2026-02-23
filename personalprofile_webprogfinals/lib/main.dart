import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qrzxepepyyyopmioaopi.supabase.co',
    anonKey: 'sb_publishable_pZOUULADbfg1oQTmkjWkNQ_P6n7jRRG',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true;
  static const Color _darkAccent = Color(0xFFE53935);
  static const Color _darkAccentSecondary = Color(0xFFB71C1C);
  static const Color _lightAccent = Color(0xFFD32F2F);
  static const Color _lightAccentSecondary = Color(0xFF9A1B1B);

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile App',
      theme: isDarkMode ? _darkTheme() : _lightTheme(),
      home: Supabase.instance.client.auth.currentUser == null
          ? LoginScreen(onThemeToggle: toggleTheme)
          : MainScreen(onThemeToggle: toggleTheme),
    );
  }

  // Tron-style Dark Theme
  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000),
      primaryColor: _darkAccent,
      colorScheme: const ColorScheme.dark(
        primary: _darkAccent,
        secondary: _darkAccentSecondary,
        surface: Color(0xFF0A0A0A),
        error: Color(0xFFFF7F96),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0A0A0A),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _darkAccent, width: 0.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        iconTheme: IconThemeData(color: _darkAccent),
        titleTextStyle: TextStyle(
          color: _darkAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF000000),
        selectedItemColor: _darkAccent,
        unselectedItemColor: Color(0xFF666666),
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkAccent,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0A0A0A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: _darkAccent),
        hintStyle: const TextStyle(color: Color(0xFF666666)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(color: Colors.white),
        bodyMedium: const TextStyle(color: Color(0xFFCCCCCC)),
        titleLarge: const TextStyle(
          color: _darkAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Light Theme
  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: _lightAccent,
      colorScheme: const ColorScheme.light(
        primary: _lightAccent,
        secondary: _lightAccentSecondary,
        surface: Color(0xFFF5F5F5),
        error: Color(0xFFED7B91),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: _lightAccent),
        titleTextStyle: TextStyle(
          color: _lightAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _lightAccent,
        unselectedItemColor: Color(0xFF666666),
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _lightAccent,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: _lightAccent),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: const TextStyle(color: Colors.black),
        bodyMedium: const TextStyle(color: Color(0xFF666666)),
        titleLarge: const TextStyle(
          color: _lightAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
