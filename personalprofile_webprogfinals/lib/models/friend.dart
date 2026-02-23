class Friend {
  final String id;
  final String userId;
  final String name;
  final String? contactInfo;
  final String? imageUrl;
  final DateTime createdAt;

  Friend({
    required this.id,
    required this.userId,
    required this.name,
    this.contactInfo,
    this.imageUrl,
    required this.createdAt,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      contactInfo: json['contact_info'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'contact_info': contactInfo,
      'image_url': imageUrl,
    };
  }
}
