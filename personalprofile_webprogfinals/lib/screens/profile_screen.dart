import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/skill_chip.dart';
import '../models/friend.dart';
import 'friends_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const ProfileScreen({super.key, required this.onToggleTheme});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String name = "John Christian Z. Lopez";
  String bio = "Flutter Student Developer";
  String email = "jzlopez@student.apc.edu.ph";

  List<String> skills = ["Flutter", "Dart", "UI Design", "Web Designer"];
  List<Friend> friends = [];

  void updateProfile(n, b, e, s) {
    setState(() {
      name = n;
      bio = b;
      email = e;
      skills = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: const AssetImage("assets/profile.jpg"),
                  ),

                  const SizedBox(height: 12),

                  Text(name, style: const TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),
                  Text(bio),
                  Text(email, style: const TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              children: skills.map((e)=>SkillChip(label: e)).toList(),
            ),

            const Divider(),

            ListTile(
              title: const Text("Edit Profile"),
              leading: const Icon(Icons.edit),
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      name: name,
                      bio: bio,
                      email: email,
                      skills: skills,
                      onSave: updateProfile,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              title: const Text("Friends"),
              leading: const Icon(Icons.people),
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FriendsScreen()),
                );
              },
            ),

            const SizedBox(height:10),

            const Text("Friends Preview"),

            ...friends.map((f)=>ListTile(
              leading: CircleAvatar(backgroundImage: FileImage(File(f.imagePath))),
              title: Text(f.name),
            )),
          ],
        ),
      ),
    );
  }
}
