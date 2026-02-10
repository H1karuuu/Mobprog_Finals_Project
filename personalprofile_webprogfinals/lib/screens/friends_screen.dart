import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/friend.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final List<Friend> friends = [];

  final picker = ImagePicker();
  XFile? image;

  final nameCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  Future pickImage() async {
    image = await picker.pickImage(source: ImageSource.camera);
  }

  void addFriend() async {
    await pickImage();

    if (image == null) return;

    setState(() {
      friends.add(
        Friend(nameCtrl.text, noteCtrl.text, image!.path),
      );
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friends")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Add Friend"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
                  TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: "Note")),
                ],
              ),
              actions: [
                TextButton(onPressed: addFriend, child: const Text("Camera"))
              ],
            ),
          );
        },
      ),

      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (_, i) => ListTile(
          leading: CircleAvatar(
            backgroundImage: FileImage(File(friends[i].imagePath)),
          ),
          title: Text(friends[i].name),
          subtitle: Text(friends[i].note),
        ),
      ),
    );
  }
}
