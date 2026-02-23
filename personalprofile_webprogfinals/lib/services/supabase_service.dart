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
  String? _lastErrorMessage;

  String? get lastErrorMessage => _lastErrorMessage;

  void _clearError() {
    _lastErrorMessage = null;
  }

  String _extFromPath(String path) {
    final trimmed = path.trim();
    if (!trimmed.contains('.')) return 'jpg';
    final ext = trimmed.split('.').last.toLowerCase();
    if (ext.isEmpty) return 'jpg';
    return ext;
  }

  String _contentTypeForExt(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      default:
        return 'application/octet-stream';
    }
  }

  String _friendlyErrorMessage(Object error, String action) {
    final raw = error.toString();
    final lower = raw.toLowerCase();

    if (lower.contains('failed host lookup') ||
        lower.contains('socketexception')) {
      return '$action failed: no internet/DNS on device.';
    }
    if (lower.contains('bucket not found')) {
      return '$action failed: missing Supabase storage bucket.';
    }
    if (lower.contains('row-level security') ||
        lower.contains('new row violates row-level security policy') ||
        lower.contains('permission denied')) {
      return '$action failed: Supabase RLS policy denied this action.';
    }
    if (lower.contains('jwt') || lower.contains('not authenticated')) {
      return '$action failed: session expired. Please log in again.';
    }

    return '$action failed: $raw';
  }

  void _setError(Object error, String action) {
    _lastErrorMessage = _friendlyErrorMessage(error, action);
    debugPrint(_lastErrorMessage);
    debugPrint('Raw error: $error');
  }

  Future<String> _uploadImageToBucket({
    required String bucket,
    required String userId,
    required File image,
  }) async {
    final fileExt = _extFromPath(image.path);
    final now = DateTime.now().millisecondsSinceEpoch;
    final safeUserPrefix = userId.length >= 8 ? userId.substring(0, 8) : userId;
    final fileName = '${now}_$safeUserPrefix.$fileExt';
    final filePath = '$userId/$fileName';

    final bytes = await image.readAsBytes();

    await supabase.storage.from(bucket).uploadBinary(
      filePath,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: _contentTypeForExt(fileExt),
      ),
    );

    return supabase.storage.from(bucket).getPublicUrl(filePath);
  }

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
    _clearError();
    try {
      final url = await _uploadImageToBucket(
        bucket: 'avatars',
        userId: userId,
        image: file,
      );

      await supabase.from('profiles').update({
        'avatar_url': url,
      }).eq('id', userId);
      _clearProfileCache();

      return url;
    } catch (e) {
      _setError(e, 'Avatar upload');
      return null;
    }
  }

  Future<String?> uploadCover(String userId, File file) async {
    _clearError();
    try {
      final url = await _uploadImageToBucket(
        bucket: 'covers',
        userId: userId,
        image: file,
      );

      await supabase.from('profiles').update({
        'cover_url': url,
      }).eq('id', userId);
      _clearProfileCache();

      return url;
    } catch (e) {
      _setError(e, 'Cover upload');
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
    _clearError();
    try {
      String? imageUrl;

      if (image != null) {
        imageUrl = await _uploadImageToBucket(
          bucket: 'posts',
          userId: userId,
          image: image,
        );
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
      _setError(e, 'Create post');
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
    _clearError();
    try {
      String? imageUrl;

      if (image != null) {
        imageUrl = await _uploadImageToBucket(
          bucket: 'friends',
          userId: userId,
          image: image,
        );
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
      _setError(e, 'Add friend');
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
    _clearError();
    try {
      String? imageUrl = removePhoto ? null : friend.imageUrl;

      if (image != null) {
        imageUrl = await _uploadImageToBucket(
          bucket: 'friends',
          userId: friend.userId,
          image: image,
        );
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
          imageUrl = await _uploadImageToBucket(
            bucket: 'friends',
            userId: friend.userId,
            image: image,
          );
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
        _setError(fallbackError, 'Update friend');
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
    _clearError();
    try {
      final imageUrl = await _uploadImageToBucket(
        bucket: 'gallery',
        userId: userId,
        image: image,
      );

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
      _setError(e, 'Gallery upload');
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
