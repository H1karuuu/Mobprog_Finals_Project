import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const SettingsScreen({
    super.key,
    required this.onThemeToggle,
  });

  Future<void> _logout(BuildContext context) async {
    await SupabaseService.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(onThemeToggle: onThemeToggle),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final email = SupabaseService.instance.currentUser?.email ?? 'No email';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Signed in as'),
              subtitle: Text(email),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: isDarkMode,
              onChanged: (_) => onThemeToggle(),
              secondary: const Icon(Icons.brightness_6),
              title: const Text('Dark Mode'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
