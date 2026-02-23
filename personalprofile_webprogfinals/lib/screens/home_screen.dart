import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/friend.dart';
import '../models/gallery_item.dart';
import '../models/post.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _profile;
  List<Post> _posts = [];
  List<Friend> _recentFriends = [];
  List<GalleryItem> _recentPhotos = [];
  bool _isLoading = true;
  final _contentController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoading = true);
    final userId = SupabaseService.instance.currentUserId;

    final postsFuture = SupabaseService.instance.getPosts();
    final profileFuture = userId == null
        ? Future<UserProfile?>.value(null)
        : SupabaseService.instance.getProfile(userId);
    final friendsFuture = userId == null
        ? Future<List<Friend>>.value(const <Friend>[])
        : SupabaseService.instance.getFriends(userId);
    final photosFuture = userId == null
        ? Future<List<GalleryItem>>.value(const <GalleryItem>[])
        : SupabaseService.instance.getGallery(userId);

    final posts = await postsFuture;
    final profile = await profileFuture;
    final friends = await friendsFuture;
    final photos = await photosFuture;
    if (!mounted) return;

    setState(() {
      _posts = posts;
      _profile = profile;
      _recentFriends = friends.take(6).toList();
      _recentPhotos = photos.take(8).toList();
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _selectedImage == null) {
      return;
    }

    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) return;

    final post = await SupabaseService.instance.createPost(
      userId: userId,
      content: _contentController.text.trim(),
      image: _selectedImage,
    );

    if (!mounted) return;

    if (post != null) {
      _contentController.clear();
      setState(() => _selectedImage = null);
      Navigator.pop(context);
      _loadHomeData();
    }
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Post',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => setState(() => _selectedImage = null),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Add Photo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createPost,
                    child: const Text('Post'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = SupabaseService.instance.currentUser;
    final fallbackName =
        (user?.userMetadata?['full_name'] as String?) ??
        user?.email?.split('@').first ??
        'User';
    final fallbackUsername =
        (user?.userMetadata?['username'] as String?) ??
        user?.email?.split('@').first ??
        'user';
    final displayName = _profile?.fullName ?? fallbackName;
    final displayUsername = _profile?.username ?? fallbackUsername;
    final coverProvider = _profile?.coverUrl != null
        ? CachedNetworkImageProvider(_profile!.coverUrl!)
        : const AssetImage('assets/header.gif') as ImageProvider;
    final avatarProvider = _profile?.avatarUrl != null
        ? CachedNetworkImageProvider(_profile!.avatarUrl!)
        : const AssetImage('assets/profile.png') as ImageProvider;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            SizedBox(
              height: 170,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: coverProvider,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: avatarProvider,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            Text(
                              '@$displayUsername',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFriendsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Friends',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          if (_recentFriends.isEmpty)
            const Text('No friends added yet')
          else
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recentFriends.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final friend = _recentFriends[index];
                  return Container(
                    width: 210,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: friend.imageUrl != null
                              ? CachedNetworkImageProvider(friend.imageUrl!)
                                  as ImageProvider<Object>
                              : const AssetImage('assets/No Photo.jpg'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                friend.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (friend.contactInfo != null &&
                                  friend.contactInfo!.isNotEmpty)
                                Text(
                                  friend.contactInfo!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentPhotosSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Gallery Photos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          if (_recentPhotos.isEmpty)
            const Text('No photos in gallery yet')
          else
            SizedBox(
              height: 105,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recentPhotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final photo = _recentPhotos[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: photo.imageUrl,
                      width: 105,
                      height: 105,
                      fit: BoxFit.cover,
                      placeholder: (context, _) => Container(
                        width: 105,
                        height: 105,
                        color: Colors.grey.shade300,
                      ),
                      errorWidget: (context, _, __) => Container(
                        width: 105,
                        height: 105,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('HOME'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHomeData,
              child: ListView(
                children: [
                  _buildProfileHeader(),
                  if (_posts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 96),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No posts yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Tap + to create your first post'),
                        ],
                      ),
                    )
                  else
                    ..._posts.map(
                      (post) => PostCard(
                        post: post,
                        onDelete: _loadHomeData,
                      ),
                    ),
                  _buildRecentFriendsSection(),
                  _buildRecentPhotosSection(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
