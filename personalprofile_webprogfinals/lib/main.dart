import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Profile App',

      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor:
            isDark ? const Color(0xFF121212) : Colors.white,
      ),

      home: ProfileScreen(
        onToggleTheme: () {
          setState(() => isDark = !isDark);
        },
      ),
    );
  }
}
