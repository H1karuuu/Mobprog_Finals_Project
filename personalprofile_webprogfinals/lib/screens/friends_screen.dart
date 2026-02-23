import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/friend.dart';
import '../services/supabase_service.dart';
import '../widgets/friend_card.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Friend> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final friends = await SupabaseService.instance.getFriends(userId);
    if (!mounted) return;
    setState(() {
      _friends = friends;
      _isLoading = false;
    });
  }

  void _showFriendDialog({Friend? friend}) {
    final isEditing = friend != null;
    final nameController = TextEditingController(text: friend?.name ?? '');
    final contactController = TextEditingController(text: friend?.contactInfo ?? '');
    File? selectedImage;
    bool removePhoto = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final ImageProvider previewImage;
          if (selectedImage != null) {
            previewImage = FileImage(selectedImage!);
          } else if (!removePhoto && friend?.imageUrl != null) {
            previewImage = CachedNetworkImageProvider(friend!.imageUrl!)
                as ImageProvider<Object>;
          } else {
            previewImage = const AssetImage('assets/No Photo.jpg');
          }

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing ? 'Edit Friend' : 'Add Friend',
                      style: Theme.of(dialogContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact (username/phone)',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: previewImage,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final source = await showDialog<String>(
                          context: dialogContext,
                          builder: (pickerContext) => AlertDialog(
                            title: const Text('Choose source'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Camera'),
                                  onTap: () => Navigator.pop(pickerContext, 'camera'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Gallery'),
                                  onTap: () => Navigator.pop(pickerContext, 'gallery'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image_not_supported),
                                  title: const Text('Continue without photo'),
                                  onTap: () => Navigator.pop(pickerContext, 'none'),
                                ),
                              ],
                            ),
                          ),
                        );

                        if (source == null) return;
                        if (source == 'none') {
                          setDialogState(() {
                            selectedImage = null;
                            removePhoto = true;
                          });
                          return;
                        }

                        final picked = await picker.pickImage(
                          source: source == 'camera'
                              ? ImageSource.camera
                              : ImageSource.gallery,
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedImage = File(picked.path);
                            removePhoto = false;
                          });
                        }
                      },
                      icon: const Icon(Icons.add_a_photo),
                      label: Text(selectedImage == null ? 'Add Photo' : 'Change Photo'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final name = nameController.text.trim();
                              final contact = contactController.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Name is required')),
                                );
                                return;
                              }
                              if (contact.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Contact is required (username or phone).',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final isPhone = RegExp(r'^\d+$').hasMatch(contact);
                              if (isPhone && contact.length < 11) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Phone number must be at least 11 digits.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final userId = SupabaseService.instance.currentUserId;
                              if (userId == null) return;

                              if (isEditing) {
                                await SupabaseService.instance.updateFriend(
                                  friend: friend,
                                  name: name,
                                  contactInfo: contact,
                                  image: selectedImage,
                                  removePhoto: removePhoto,
                                );
                              } else {
                                await SupabaseService.instance.addFriend(
                                  userId: userId,
                                  name: name,
                                  contactInfo: contact,
                                  image: selectedImage,
                                );
                              }

                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);
                              _loadFriends();
                            },
                            child: Text(isEditing ? 'Save' : 'Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('FRIENDS'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFriendDialog(),
        child: const Icon(Icons.person_add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No friends yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Tap + to add your first friend'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFriends,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      return FriendCard(
                        friend: _friends[index],
                        onEdit: () => _showFriendDialog(friend: _friends[index]),
                        onDelete: _loadFriends,
                      );
                    },
                  ),
                ),
    );
  }
}
