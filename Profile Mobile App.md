# Personal Profile Mobile Application
## Final Project Documentation

**Course:** Mobile Programming
**Developer:** John Christian Z. Lopez
**Email:** jzlopez@student.apc.edu.ph
**Date:** February 13, 2026

---

## Table of Contents
1. [Introduction](#introduction)
2. [Application Overview](#application-overview)
3. [Features](#features)
4. [Technical Stack](#technical-stack)
5. [Application Architecture](#application-architecture)
6. [Database Design](#database-design)
7. [Source Code Documentation](#source-code-documentation)
8. [User Interface Screenshots](#user-interface-screenshots)
9. [Installation & Setup](#installation--setup)
10. [How to Use](#how-to-use)
11. [Conclusion](#conclusion)

---

## 1. Introduction

The **Personal Profile Mobile Application** is a fully functional Flutter-based mobile application designed to showcase user profiles with comprehensive features for managing personal information and social connections. This application demonstrates proficiency in Flutter development, including UI/UX design, navigation, form validation, data persistence, and modern mobile app architecture.

### Project Objectives
- Create a clean, responsive, and user-friendly mobile interface
- Implement proper navigation between multiple screens
- Demonstrate form handling with validation
- Utilize local database for data persistence
- Showcase understanding of Flutter widgets and state management

---

## 2. Application Overview

This personal profile app allows users to:
- View their personal profile with customizable information
- Edit profile details including name, bio, email, and skills
- Manage a list of friends with photos and notes
- Toggle between dark and light themes
- Capture or select photos from gallery for friend profiles
- Persist data locally using SQLite database

---

## 3. Features

### ✅ Core Features (Required)

#### 3.1 Home/Profile Screen
- **Profile Picture Display**: Shows user avatar with custom header image
- **Personal Information**: Name, bio, email prominently displayed
- **Skills Section**: Dynamic skill chips showcasing user abilities
- **Friends Preview**: Quick view of added friends
- **Theme Toggle**: Switch between dark and light modes

#### 3.2 Edit Profile Feature
- **Form-based Editing**: Complete form with validation
- **Text Fields**: Name (required), Bio, Email (validated), Skills
- **Validation**: Email format validation, required field checks
- **Save Confirmation**: Alert dialog confirms successful update
- **Persistent Storage**: All changes saved to SQLite database

#### 3.3 Navigation System
The app implements 4 main screens:
1. **Profile Screen** - Main dashboard
2. **Edit Profile Screen** - Profile editing interface
3. **Friends Screen** - Friends list management
4. **About Screen** - Application information

Navigation uses `Navigator.push` and `Navigator.pop` for seamless transitions.

#### 3.4 Forms and Validation
- **Required Fields**: Name field must not be empty
- **Email Validation**: Validates proper email format
- **Error Messages**: Clear feedback for validation failures
- **Form State Management**: Uses `GlobalKey<FormState>` for proper form control

#### 3.5 Alert Dialogs
- **Save Confirmation**: Displayed after profile updates
- **Success Messages**: Confirms successful operations
- **Styled Dialogs**: Custom-themed dialog boxes matching app design

#### 3.6 Friends List Feature
- **Add Friend**: Form to add new friends with name and username/contact
- **Photo Selection**: Choose from camera or gallery, or skip photo
- **Friend List Display**: Scrollable list with photos and details
- **Delete Functionality**: Remove friends from the list
- **Empty State**: Helpful message when no friends added yet
- **Persistent Storage**: Friends data saved to database

---

## 4. Technical Stack

### Technologies Used
- **Framework**: Flutter 3.x
- **Language**: Dart 3.0+
- **Database**: SQLite (sqflite package)
- **Image Handling**: image_picker package
- **State Management**: StatefulWidget with setState
- **Navigation**: Navigator API (imperative routing)

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  image_picker: ^1.0.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

---

## 5. Application Architecture

### Project Structure
```
lib/
├── main.dart                      # Entry point with theme management
├── screens/
│   ├── profile_screen.dart        # Main profile display
│   ├── edit_profile_screen.dart   # Profile editing form
│   ├── friends_screen.dart        # Friends list management
│   └── about_screen.dart          # About page
├── models/
│   └── friend.dart                # Friend data model
├── database/
│   └── database_helper.dart       # SQLite database operations
└── widgets/
    ├── skill_chip.dart            # Custom skill chip widget
    └── app_colors.dart            # Color constants

assets/
├── header.gif                     # Profile header animation
├── profile.png                    # Default profile picture
└── No Photo.jpg                   # Placeholder for friends
```

### Architecture Pattern
The application follows a **layered architecture**:
1. **Presentation Layer**: UI screens and widgets
2. **Business Logic Layer**: Data models and state management
3. **Data Layer**: Database helper for persistence

---

## 6. Database Design

### Database Schema

#### Profile Table
```sql
CREATE TABLE profile (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  bio TEXT,
  email TEXT,
  skills TEXT
)
```

**Fields:**
- `id`: Unique identifier
- `name`: User's full name (required)
- `bio`: Short biography or description
- `email`: Contact email address
- `skills`: Comma-separated list of skills

#### Friends Table
```sql
CREATE TABLE friends (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  note TEXT,
  imagePath TEXT NOT NULL
)
```

**Fields:**
- `id`: Unique identifier
- `name`: Friend's name (required)
- `note`: Username or contact information
- `imagePath`: Path to friend's photo or placeholder

### Database Operations

**Profile Operations:**
- `getProfile()`: Retrieve user profile
- `updateProfile()`: Update profile information

**Friends Operations:**
- `insertFriend()`: Add new friend
- `getAllFriends()`: Retrieve all friends
- `deleteFriend()`: Remove a friend

---

## 7. Source Code Documentation

### 7.1 Main Application Entry Point

**File:** `lib/main.dart`

```dart
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
```

**Key Features:**
- Dynamic theme switching (dark/light mode)
- Material Design implementation
- Clean app initialization

---

### 7.2 Profile Screen

**File:** `lib/screens/profile_screen.dart`

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/skill_chip.dart';
import '../models/friend.dart';
import 'friends_screen.dart';
import 'edit_profile_screen.dart';
import '../database/database_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadFriends();
  }

  Future<void> _loadProfile() async {
    final profile = await DatabaseHelper.instance.getProfile();
    if (profile.isNotEmpty) {
      setState(() {
        name = profile['name'] ?? 'John Christian Z. Lopez';
        bio = profile['bio'] ?? 'Flutter Student Developer';
        email = profile['email'] ?? 'jzlopez@student.apc.edu.ph';
        skills = (profile['skills'] as String?)?.split(',') ??
                 ["Flutter", "Dart", "UI Design", "Web Designer"];
      });
    }
  }

  Future<void> _loadFriends() async {
    final loadedFriends = await DatabaseHelper.instance.getAllFriends();
    setState(() {
      friends = loadedFriends;
    });
  }

  void updateProfile(n, b, e, s) async {
    await DatabaseHelper.instance.updateProfile(n, b, e, s);
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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/header.gif",
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
                  const SizedBox(height: 65),
                  Text(name,
                       style: const TextStyle(fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
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
                        onTap: () async {
                          await Navigator.push(
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
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const FriendsScreen()));
                          _loadFriends();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  const Text("Friends Preview",
                             style: TextStyle(fontWeight: FontWeight.bold)),

                  ...friends.map(
                    (f) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: f.imagePath.startsWith('assets/')
                            ? AssetImage(f.imagePath) as ImageProvider
                            : FileImage(File(f.imagePath)),
                      ),
                      title: Text(f.name),
                      subtitle: f.note.isNotEmpty ? Text(f.note) : null,
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
      {required IconData icon,
       required String label,
       required VoidCallback onTap}) {
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
```

**Key Features:**
- CustomScrollView with SliverAppBar for collapsing header
- Profile information display
- Skills visualization with custom chips
- Friends preview list
- Navigation to Edit and Friends screens
- Theme toggle button
- Database integration for loading data

---

### 7.3 Edit Profile Screen

**File:** `lib/screens/edit_profile_screen.dart`

```dart
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Name Field
              TextFormField(
                controller: nameCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: const TextStyle(color: Colors.redAccent),
                  prefixIcon: const Icon(Icons.person_outline,
                                        color: Colors.redAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent,
                                                 width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 16),

              // Bio Field
              TextFormField(
                controller: bioCtrl,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Bio",
                  labelStyle: const TextStyle(color: Colors.redAccent),
                  prefixIcon: const Icon(Icons.info_outline,
                                        color: Colors.redAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent,
                                                 width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: emailCtrl,
                validator: (v) => v!.contains("@") ? null : "Invalid email",
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Colors.redAccent),
                  prefixIcon: const Icon(Icons.email_outlined,
                                        color: Colors.redAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent,
                                                 width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 16),

              // Skills Field
              TextFormField(
                controller: skillsCtrl,
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Skills (comma separated)",
                  labelStyle: const TextStyle(color: Colors.redAccent),
                  prefixIcon: const Icon(Icons.code, color: Colors.redAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent,
                                                 width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
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
                        backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                      color: Colors.green,
                                      size: 28),
                            const SizedBox(width: 12),
                            const Text("Saved"),
                          ],
                        ),
                        content: const Text("Profile updated successfully."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
```

**Key Features:**
- Form validation with GlobalKey<FormState>
- Required field validation (name)
- Email format validation
- Custom styled form fields with icons
- Success alert dialog after save
- Callback function to update parent screen
- Proper controller disposal

---

### 7.4 Friends Screen

**File:** `lib/screens/friends_screen.dart`

```dart
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
                leading: const Icon(Icons.camera_alt,
                                   color: Colors.redAccent),
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
                leading: const Icon(Icons.photo_library,
                                   color: Colors.redAccent),
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
                leading: const Icon(Icons.person_outline,
                                   color: Colors.redAccent),
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

    String imagePath = image?.path ?? 'assets/No Photo.jpg';

    final friend = Friend(nameCtrl.text, usernameCtrl.text, imagePath);
    await DatabaseHelper.instance.insertFriend(friend);

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
                    child: const Icon(Icons.person_add,
                                     color: Colors.redAccent),
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
                      prefixIcon: const Icon(Icons.person_outline,
                                            color: Colors.redAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                                    color: Colors.redAccent, width: 2),
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
                      prefixIcon: const Icon(Icons.alternate_email,
                                            color: Colors.redAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                                    color: Colors.redAccent, width: 2),
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
                  contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
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
                    icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                    onPressed: () => deleteFriend(i),
                  ),
                ),
              ),
            ),
    );
  }
}
```

**Key Features:**
- Add friend dialog with two input fields
- Image picker integration (camera/gallery/skip)
- Friend list with cards
- Delete functionality
- Empty state message
- Photo display (file or asset)
- Database persistence

---

### 7.5 Database Helper

**File:** `lib/database/database_helper.dart`

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/friend.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('profile.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create profile table
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bio TEXT,
        email TEXT,
        skills TEXT
      )
    ''');

    // Create friends table
    await db.execute('''
      CREATE TABLE friends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        note TEXT,
        imagePath TEXT NOT NULL
      )
    ''');

    // Insert default profile
    await db.insert('profile', {
      'name': 'John Christian Z. Lopez',
      'bio': 'Flutter Student Developer',
      'email': 'jzlopez@student.apc.edu.ph',
      'skills': 'Flutter,Dart,UI Design,Web Designer'
    });
  }

  // PROFILE OPERATIONS
  Future<Map<String, dynamic>> getProfile() async {
    final db = await database;
    final result = await db.query('profile', limit: 1);
    return result.isNotEmpty ? result.first : {};
  }

  Future<void> updateProfile(String name, String bio,
                            String email, List<String> skills) async {
    final db = await database;
    await db.update(
      'profile',
      {
        'name': name,
        'bio': bio,
        'email': email,
        'skills': skills.join(','),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // FRIENDS OPERATIONS
  Future<int> insertFriend(Friend friend) async {
    final db = await database;
    return await db.insert('friends', {
      'name': friend.name,
      'note': friend.note,
      'imagePath': friend.imagePath,
    });
  }

  Future<List<Friend>> getAllFriends() async {
    final db = await database;
    final result = await db.query('friends', orderBy: 'id DESC');
    return result.map((json) => Friend(
      json['name'] as String,
      json['note'] as String,
      json['imagePath'] as String,
    )).toList();
  }

  Future<void> deleteFriend(String name) async {
    final db = await database;
    await db.delete(
      'friends',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
```

**Key Features:**
- Singleton pattern for database access
- Two tables: profile and friends
- CRUD operations for both tables
- Default profile data insertion
- Proper database initialization

---

### 7.6 Data Models

**File:** `lib/models/friend.dart`

```dart
class Friend {
  String name;
  String note;
  String imagePath;

  Friend(this.name, this.note, this.imagePath);
}
```

---

### 7.7 Custom Widgets

**File:** `lib/widgets/skill_chip.dart`

```dart
import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.red.withOpacity(.2),
      labelStyle: const TextStyle(color: Colors.redAccent),
      side: const BorderSide(color: Colors.redAccent),
    );
  }
}
```

---

## 8. User Interface Screenshots

### Profile Screen (Home)
**Screenshot Location:** `screenshots/profile_screen.png`

Features visible:
- Animated header with profile picture
- Name, bio, and email display
- Skills chips
- Edit Profile and Friends buttons
- Friends preview list
- Theme toggle button (top right)

---

### Edit Profile Screen
**Screenshot Location:** `screenshots/edit_profile_screen.png`

Features visible:
- Profile icon
- Name field (required validation)
- Bio field
- Email field (email format validation)
- Skills field (comma-separated)
- Save button

---

### Friends List Screen
**Screenshot Location:** `screenshots/friends_screen.png`

Features visible:
- Friends list with photos
- Delete button for each friend
- Floating action button to add friend
- Empty state when no friends

---

### Add Friend Dialog
**Screenshot Location:** `screenshots/add_friend_dialog.png`

Features visible:
- Name field (required)
- Username/Contact field
- Cancel and Next buttons

---

### Photo Source Selection Dialog
**Screenshot Location:** `screenshots/photo_source_dialog.png`

Features visible:
- Take Photo option
- Choose from Gallery option
- Continue without photo option

---

### Success Alert Dialog
**Screenshot Location:** `screenshots/success_dialog.png`

Features visible:
- Success icon
- "Saved" title
- Success message
- OK button

---

## 9. Installation & Setup

### Prerequisites
- Flutter SDK (3.0 or higher)
- Android Studio / VS Code
- Android device or emulator
- Git (optional)

### Installation Steps

1. **Clone or Extract the Project**
   ```bash
   cd personalprofile_webprogfinals
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Check Flutter Setup**
   ```bash
   flutter doctor
   ```

4. **Connect Device or Start Emulator**
   ```bash
   flutter devices
   ```

5. **Run the Application**
   ```bash
   flutter run
   ```

6. **Build APK** (for submission)
   ```bash
   flutter build apk --release
   ```

   APK will be located at:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 10. How to Use

### First Launch
1. App opens with default profile information
2. Header displays animated GIF
3. Profile shows: John Christian Z. Lopez's information

### Editing Profile
1. Tap "Edit Profile" button on home screen
2. Modify any fields (name, bio, email, skills)
3. Name is required - validation will show error if empty
4. Email must contain "@" - validation will show error if invalid
5. Skills should be comma-separated
6. Tap "Save" button
7. Confirmation dialog appears
8. Tap "OK" to return to profile screen
9. Changes are reflected immediately and saved to database

### Managing Friends
1. Tap "Friends" button on home screen
2. To add a friend:
   - Tap the floating "+" button
   - Enter friend's name (required)
   - Optionally enter username/contact
   - Tap "Next"
   - Choose photo source or skip
   - Friend appears in the list
3. To delete a friend:
   - Tap the delete icon on any friend card
   - Friend is removed immediately

### Theme Switching
1. Tap the theme icon (brightness button) in the app bar
2. App switches between dark and light mode instantly

---

## 11. Conclusion

### Project Achievement Summary

This Personal Profile Mobile Application successfully demonstrates:

✅ **Complete Flutter Implementation**
- Built entirely with Flutter framework
- Runs smoothly on Android devices
- Clean, organized code structure

✅ **All Required Features Implemented**
1. Profile Screen with all required information
2. Edit Profile with form validation
3. Multiple screen navigation (4 screens)
4. Forms with proper validation
5. Alert dialogs for user feedback
6. Friends list with add/edit/delete functionality

✅ **Additional Features**
- Dark/Light theme toggle
- Image picker integration
- Local database persistence (SQLite)
- Animated UI elements
- Custom widgets
- Responsive design

✅ **Best Practices**
- Proper project structure
- Meaningful naming conventions
- Code formatting and organization
- State management
- Error handling
- User feedback mechanisms

### Technical Skills Demonstrated

**Flutter Development:**
- Widget composition and customization
- State management with StatefulWidget
- Navigation and routing
- Form handling and validation
- Material Design implementation

**Database Management:**
- SQLite integration
- CRUD operations
- Data persistence
- Singleton pattern

**UI/UX Design:**
- Responsive layouts
- Custom styling and theming
- User-friendly interfaces
- Visual feedback
- Empty states

**Mobile Development:**
- Camera/Gallery integration
- File handling
- Platform-specific features
- Asset management

### Future Enhancements

Potential improvements for this application:
- Cloud backup integration
- Profile photo upload
- Social media integration
- Friend categories/groups
- Search and filter functionality
- Data export/import
- Multiple profile support
- Notification system

---

## Appendix

### Package Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0      # SQLite database
  path: ^1.8.3         # Path manipulation
  image_picker: ^1.0.4 # Camera/Gallery access

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

### Assets Used

```yaml
assets:
  - assets/header.gif      # Profile header animation
  - assets/profile.png     # Default profile picture
  - assets/No Photo.jpg    # Friend placeholder image
```

### Color Scheme

**Primary Colors:**
- Red Accent: `#FF0055` (Primary action color)
- Dark Background: `#121212`
- Card Background: `#111111`

**Text Colors:**
- Primary Text: White (dark mode) / Black (light mode)
- Secondary Text: `#B0B0B0`

### Contact Information

**Developer:** John Christian Z. Lopez
**Email:** jzlopez@student.apc.edu.ph
**Course:** Mobile Programming
**Institution:** Asia Pacific College

---

## End of Documentation

**Date Generated:** February 13, 2026
**Version:** 1.0
**Status:** Final Submission

---

© 2026 John Christian Z. Lopez - All Rights Reserved
