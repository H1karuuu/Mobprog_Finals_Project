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

  Future<void> updateProfile(String name, String bio, String email, List<String> skills) async {
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