import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String bio;
  final String email;
  final List<String> skills;
  final Function(String, String, String, List<String>) onSave;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.bio,
    required this.email,
    required this.skills,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController bioCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController skillsCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.name);
    bioCtrl = TextEditingController(text: widget.bio);
    emailCtrl = TextEditingController(text: widget.email);
    skillsCtrl = TextEditingController(text: widget.skills.join(","));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextFormField(
                controller: bioCtrl,
                decoration: const InputDecoration(labelText: "Bio"),
              ),
              TextFormField(
                controller: emailCtrl,
                validator: (v) => v!.contains("@") ? null : "Invalid email",
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: skillsCtrl,
                decoration: const InputDecoration(labelText: "Skills (comma separated)"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave(
                      nameCtrl.text,
                      bioCtrl.text,
                      emailCtrl.text,
                      skillsCtrl.text.split(","),
                    );

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Saved"),
                        content: const Text("Profile updated successfully."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    );
                  }
                },
                child: const Text("Save"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
