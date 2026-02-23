class UserProfile {
  final String id;
  final String username;
  final String fullName;
  final String? bio;
  final String? email;
  final String? skills;
  final String? avatarUrl;
  final String? coverUrl;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    this.bio,
    this.email,
    this.skills,
    this.avatarUrl,
    this.coverUrl,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      bio: json['bio'] as String?,
      email: json['email'] as String?,
      skills: json['skills'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'bio': bio,
      'email': email,
      'skills': skills,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  List<String> get skillsList {
    if (skills == null || skills!.isEmpty) return [];
    return skills!.split(',').map((s) => s.trim()).toList();
  }
}
