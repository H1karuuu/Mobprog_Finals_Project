import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _skillsController;
  bool _isSaving = false;
  File? _newAvatar;
  File? _newCover;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _skillsController = TextEditingController(text: widget.profile.skills ?? '');
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _newAvatar = File(image.path));
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _newCover = File(image.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) return;

    setState(() => _isSaving = true);
    if (_newAvatar != null) {
      await SupabaseService.instance.uploadAvatar(userId, _newAvatar!);
    }
    if (_newCover != null) {
      await SupabaseService.instance.uploadCover(userId, _newCover!);
    }
    await SupabaseService.instance.updateProfile(
      userId: userId,
      fullName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      skills: _skillsController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final coverProvider = _newCover != null
        ? FileImage(_newCover!)
        : widget.profile.coverUrl != null
            ? CachedNetworkImageProvider(widget.profile.coverUrl!)
                as ImageProvider<Object>
            : const AssetImage('assets/header.gif');
    final avatarProvider = _newAvatar != null
        ? FileImage(_newAvatar!)
        : widget.profile.avatarUrl != null
            ? CachedNetworkImageProvider(widget.profile.avatarUrl!)
                as ImageProvider<Object>
            : const AssetImage('assets/profile.png');

    return Scaffold(
      appBar: AppBar(title: const Text('EDIT PROFILE')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 170,
                child: Image(image: coverProvider, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickCover,
              icon: const Icon(Icons.photo),
              label: const Text('Change Cover Photo'),
            ),
            const SizedBox(height: 14),
            Center(
              child: CircleAvatar(
                radius: 46,
                backgroundImage: avatarProvider,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: OutlinedButton.icon(
                onPressed: _pickAvatar,
                icon: const Icon(Icons.person),
                label: const Text('Change Profile Photo'),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: widget.profile.email ?? 'No email',
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'About Me'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Skills / Interests (comma separated)',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }
}
