import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/friend.dart';
import '../database/database_helper.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Friend> friends = [];

  final picker = ImagePicker();
  XFile? image;

  final nameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final loadedFriends = await DatabaseHelper.instance.getAllFriends();
    setState(() {
      friends = loadedFriends;
    });
  }

  Future<void> pickImageFromCamera() async {
    image = await picker.pickImage(source: ImageSource.camera);
  }

  Future<void> pickImageFromGallery() async {
    image = await picker.pickImage(source: ImageSource.gallery);
  }

  void showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Choose Photo Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  await pickImageFromCamera();
                  if (image != null) {
                    await saveFriend();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.redAccent),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await pickImageFromGallery();
                  if (image != null) {
                    await saveFriend();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.redAccent),
                title: const Text("Continue without photo"),
                onTap: () async {
                  Navigator.pop(context);
                  image = null;
                  await saveFriend();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveFriend() async {
    if (nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name")),
      );
      return;
    }

    // Use a default placeholder image if no photo selected
    String imagePath = image?.path ?? 'assets/No Photo.jpg';

    final friend = Friend(nameCtrl.text, usernameCtrl.text, imagePath);
    await DatabaseHelper.instance.insertFriend(friend);

    // Clear the text fields and image
    nameCtrl.clear();
    usernameCtrl.clear();
    image = null;

    await _loadFriends();
    Navigator.pop(context);
  }

  Future<void> deleteFriend(int index) async {
    await DatabaseHelper.instance.deleteFriend(friends[index].name);
    await _loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Friends"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          // Clear controllers
          nameCtrl.clear();
          usernameCtrl.clear();
          
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_add, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 12),
                  const Text("Add Friend"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Name *",
                      labelStyle: const TextStyle(color: Colors.redAccent),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.redAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameCtrl,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Username / Contact",
                      hintText: "@username or phone number",
                      labelStyle: const TextStyle(color: Colors.redAccent),
                      prefixIcon: const Icon(Icons.alternate_email, color: Colors.redAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  onPressed: showImageSourceDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add_a_photo, size: 20),
                  label: const Text("Next"),
                ),
              ],
            ),
          );
        },
      ),

      body: friends.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No friends yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the + button to add a friend",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: friends.length,
              itemBuilder: (_, i) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey.withOpacity(0.1),
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.redAccent,
                    backgroundImage: friends[i].imagePath.startsWith('assets/')
                        ? AssetImage(friends[i].imagePath) as ImageProvider
                        : FileImage(File(friends[i].imagePath)),
                  ),
                  title: Text(
                    friends[i].name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: friends[i].note.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            friends[i].note,
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                            ),
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => deleteFriend(i),
                  ),
                ),
              ),
            ),
    );
  }
}