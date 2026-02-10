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
      body: CustomScrollView(
        slivers: [
          // HEADER WITH BACKGROUND IMAGE
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/header.gif", // <-- add a header image in assets
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: const AssetImage("assets/profile.png"),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: widget.onToggleTheme,
              )
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 65), // spacing below avatar
                  Text(bio, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: Colors.redAccent)),

                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: skills.map((e) => SkillChip(label: e)).toList(),
                  ),

                  const SizedBox(height: 20),

                  // FEATURE MENU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _featureButton(
                        icon: Icons.edit,
                        label: "Edit Profile",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(
                                        name: name,
                                        bio: bio,
                                        email: email,
                                        skills: skills,
                                        onSave: updateProfile,
                                      )));
                        },
                      ),
                      _featureButton(
                        icon: Icons.people,
                        label: "Friends",
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const FriendsScreen()));
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  const Text("Friends Preview", style: TextStyle(fontWeight: FontWeight.bold)),

                  ...friends.map(
                    (f) => ListTile(
                      leading: CircleAvatar(backgroundImage: FileImage(File(f.imagePath))),
                      title: Text(f.name),
                      subtitle: Text(f.note),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureButton(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.redAccent, size: 30),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}
