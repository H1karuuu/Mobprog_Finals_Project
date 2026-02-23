import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/post.dart';
import '../models/friend.dart';
import '../models/gallery_item.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._();
  SupabaseService._();

  final supabase = Supabase.instance.client;
  UserProfile? _cachedProfile;
  String? _cachedProfileUserId;
  DateTime? _cachedProfileAt;

  // ==================== AUTH ====================

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'full_name': fullName,
      },
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resendSignupConfirmation({required String email}) async {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  Future<void> ensureCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return;

    final metadata = user.userMetadata ?? <String, dynamic>{};
    final username =
        (metadata['username'] as String?)?.trim().isNotEmpty == true
            ? (metadata['username'] as String).trim()
            : (user.email?.split('@').first ?? 'user_${user.id.substring(0, 8)}');
    final fullName =
        (metadata['full_name'] as String?)?.trim().isNotEmpty == true
            ? (metadata['full_name'] as String).trim()
            : username;

    await supabase.from('profiles').upsert(
      {
        'id': user.id,
        'username': username,
        'full_name': fullName,
        'email': user.email,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'id',
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    _clearProfileCache();
  }

  User? get currentUser => supabase.auth.currentUser;
  String? get currentUserId => supabase.auth.currentUser?.id;

  // ==================== PROFILE ====================

  Future<UserProfile?> getProfile(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _cachedProfile != null &&
        _cachedProfileUserId == userId &&
        _cachedProfileAt != null &&
        DateTime.now().difference(_cachedProfileAt!) <
            const Duration(seconds: 30)) {
      return _cachedProfile;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = UserProfile.fromJson(response);
      _cachedProfile = profile;
      _cachedProfileUserId = userId;
      _cachedProfileAt = DateTime.now();
      return profile;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? bio,
    String? skills,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updates['full_name'] = fullName;
    if (bio != null) updates['bio'] = bio;
    if (skills != null) updates['skills'] = skills;

    await supabase.from('profiles').update(updates).eq('id', userId);
    _clearProfileCache();
  }

  Future<String?> uploadAvatar(String userId, File file) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$fileName';

      await supabase.storage.from('avatars').upload(
        filePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final url = supabase.storage.from('avatars').getPublicUrl(filePath);
      
      await supabase.from('profiles').update({
        'avatar_url': url,
      }).eq('id', userId);
      _clearProfileCache();

      return url;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  Future<String?> uploadCover(String userId, File file) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$fileName';

      await supabase.storage.from('covers').upload(
        filePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final url = supabase.storage.from('covers').getPublicUrl(filePath);
      
      await supabase.from('profiles').update({
        'cover_url': url,
      }).eq('id', userId);
      _clearProfileCache();

      return url;
    } catch (e) {
      debugPrint('Error uploading cover: $e');
      return null;
    }
  }

  // ==================== POSTS ====================

  Future<List<Post>> getPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);
      return _attachProfilesToPosts(response as List);
    } catch (e) {
      debugPrint('Error getting posts: $e');
      return [];
    }
  }

  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final response = await supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return _attachProfilesToPosts(response as List);
    } catch (e) {
      debugPrint('Error getting user posts: $e');
      return [];
    }
  }

  Future<Post?> createPost({
    required String userId,
    required String content,
    File? image,
  }) async {
    try {
      String? imageUrl;

      if (image != null) {
        final fileExt = image.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '$userId/$fileName';

        await supabase.storage.from('posts').upload(filePath, image);
        imageUrl = supabase.storage.from('posts').getPublicUrl(filePath);
      }

      final response = await supabase
          .from('posts')
          .insert({
            'user_id': userId,
            'content': content,
            'image_url': imageUrl,
          })
          .select()
          .single();

      return Post.fromJson(response);
    } catch (e) {
      debugPrint('Error creating post: $e');
      return null;
    }
  }

  Future<void> deletePost(String postId) async {
    await supabase.from('posts').delete().eq('id', postId);
  }

  // ==================== FRIENDS ====================

  Future<List<Friend>> getFriends(String userId) async {
    try {
      final response = await supabase
          .from('friends')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Friend.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting friends: $e');
      return [];
    }
  }

  Future<Friend?> addFriend({
    required String userId,
    required String name,
    String? contactInfo,
    File? image,
  }) async {
    try {
      String? imageUrl;

      if (image != null) {
        final fileExt = image.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '$userId/$fileName';

        await supabase.storage.from('friends').upload(filePath, image);
        imageUrl = supabase.storage.from('friends').getPublicUrl(filePath);
      }

      final response = await supabase
          .from('friends')
          .insert({
            'user_id': userId,
            'name': name,
            'contact_info': contactInfo,
            'image_url': imageUrl,
          })
          .select()
          .single();

      return Friend.fromJson(response);
    } catch (e) {
      debugPrint('Error adding friend: $e');
      return null;
    }
  }

  Future<Friend?> updateFriend({
    required Friend friend,
    required String name,
    required String contactInfo,
    File? image,
    bool removePhoto = false,
  }) async {
    try {
      String? imageUrl = removePhoto ? null : friend.imageUrl;

      if (image != null) {
        final fileExt = image.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '${friend.userId}/$fileName';

        await supabase.storage.from('friends').upload(filePath, image);
        imageUrl = supabase.storage.from('friends').getPublicUrl(filePath);
      }

      final response = await supabase
          .from('friends')
          .update({
            'name': name,
            'contact_info': contactInfo,
            'image_url': imageUrl,
          })
          .eq('id', friend.id)
          .select()
          .single();

      return Friend.fromJson(response);
    } catch (e) {
      debugPrint('Error updating friend (trying fallback): $e');
      try {
        String? imageUrl = removePhoto ? null : friend.imageUrl;

        if (image != null) {
          final fileExt = image.path.split('.').last;
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          final filePath = '${friend.userId}/$fileName';

          await supabase.storage.from('friends').upload(filePath, image);
          imageUrl = supabase.storage.from('friends').getPublicUrl(filePath);
        }

        final inserted = await supabase
            .from('friends')
            .insert({
              'user_id': friend.userId,
              'name': name,
              'contact_info': contactInfo,
              'image_url': imageUrl,
            })
            .select()
            .single();

        await supabase.from('friends').delete().eq('id', friend.id);
        return Friend.fromJson(inserted);
      } catch (fallbackError) {
        debugPrint('Error updating friend fallback: $fallbackError');
        return null;
      }
    }
  }

  Future<void> deleteFriend(String friendId) async {
    await supabase.from('friends').delete().eq('id', friendId);
  }

  // ==================== GALLERY ====================

  Future<List<GalleryItem>> getGallery(String userId) async {
    try {
      final response = await supabase
          .from('gallery')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => GalleryItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting gallery: $e');
      return [];
    }
  }

  Future<GalleryItem?> addToGallery({
    required String userId,
    required File image,
    String? caption,
  }) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$fileName';

      await supabase.storage.from('gallery').upload(filePath, image);
      final imageUrl = supabase.storage.from('gallery').getPublicUrl(filePath);

      final response = await supabase
          .from('gallery')
          .insert({
            'user_id': userId,
            'image_url': imageUrl,
            'caption': caption,
          })
          .select()
          .single();

      return GalleryItem.fromJson(response);
    } catch (e) {
      debugPrint('Error adding to gallery: $e');
      return null;
    }
  }

  Future<void> deleteFromGallery(String itemId) async {
    await supabase.from('gallery').delete().eq('id', itemId);
  }

  void _clearProfileCache() {
    _cachedProfile = null;
    _cachedProfileUserId = null;
    _cachedProfileAt = null;
  }

  Future<List<Post>> _attachProfilesToPosts(List rawPosts) async {
    final posts = rawPosts
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
    if (posts.isEmpty) return posts;

    final userIds = posts.map((p) => p.userId).toSet().toList();
    final profileRows = await supabase
        .from('profiles')
        .select('id, username, avatar_url, full_name')
        .inFilter('id', userIds);

    final profileById = <String, Map<String, dynamic>>{};
    for (final row in (profileRows as List)) {
      final profile = row as Map<String, dynamic>;
      final id = profile['id'] as String?;
      if (id != null) {
        profileById[id] = profile;
      }
    }

    for (final post in posts) {
      final profile = profileById[post.userId];
      if (profile != null) {
        post.username = profile['username'] as String?;
        post.userAvatar = profile['avatar_url'] as String?;
        post.userFullName = profile['full_name'] as String?;
      }
    }
    return posts;
  }
}
