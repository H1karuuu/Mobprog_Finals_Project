import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_profile.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final profile = await SupabaseService.instance.getProfile(
      userId,
      forceRefresh: true,
    );
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _bioController.text = profile?.bio ?? '';
      _skillsController.text = profile?.skills ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveAbout() async {
    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) return;

    setState(() => _isSaving = true);
    await SupabaseService.instance.updateProfile(
      userId: userId,
      bio: _bioController.text.trim(),
      skills: _skillsController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('About info saved.')),
    );
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('ABOUT ME'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Profile not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'Full Name',
                        _profile!.fullName,
                        Icons.badge,
                      ),
                      _buildSection(
                        'Username',
                        '@${_profile!.username}',
                        Icons.alternate_email,
                      ),
                      _buildSection(
                        'Email',
                        _profile!.email ?? 'No email',
                        Icons.email,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bio',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Write your about me details here...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Skills / Interests (comma separated)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _skillsController,
                        decoration: const InputDecoration(
                          hintText: 'Flutter, Web, Cybersecurity',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveAbout,
                          icon: _isSaving
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Saving...' : 'Save About Info'),
                        ),
                      ),
                      if (_profile!.skills != null &&
                          _profile!.skills!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSkillsSection(),
                      ],
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Personal Profile App',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Version 1.0.0',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Powered by Supabase',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Widget _buildSkillsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Skills',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _profile!.skillsList.map((skill) {
              return Chip(
                label: Text(skill),
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
