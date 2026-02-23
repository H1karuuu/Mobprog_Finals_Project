import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import '../widgets/post_card.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const ProfileScreen({super.key, required this.onThemeToggle});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    final profileFuture = SupabaseService.instance.getProfile(
      userId,
      forceRefresh: forceRefresh,
    );
    final postsFuture = SupabaseService.instance.getUserPosts(userId);
    final profile = await profileFuture;
    final posts = await postsFuture;
    if (!mounted) return;

    setState(() {
      _profile = profile;
      _posts = posts;
      _isLoading = false;
    });
  }

  Future<void> _openEditProfile() async {
    if (_profile == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: _profile!),
      ),
    );
    if (saved == true) {
      _loadProfile(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('PROFILE'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => _loadProfile(forceRefresh: true),
            child: const Text('Retry'),
          ),
        ),
      );
    }

    final coverProvider = _profile!.coverUrl != null
        ? CachedNetworkImageProvider(_profile!.coverUrl!)
        : const AssetImage('assets/header.gif') as ImageProvider;
    final avatarProvider = _profile!.avatarUrl != null
        ? CachedNetworkImageProvider(_profile!.avatarUrl!)
            as ImageProvider<Object>
        : const AssetImage('assets/profile.png');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 240,
            pinned: true,
            title: const Text('PROFILE'),
            actions: [
              IconButton(
                onPressed: widget.onThemeToggle,
                icon: const Icon(Icons.brightness_6),
              ),
              IconButton(
                onPressed: _openEditProfile,
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Profile',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image(image: coverProvider, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 18,
                    child: Row(
                      children: [
                        CircleAvatar(radius: 48, backgroundImage: avatarProvider),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profile!.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '@${_profile!.username}',
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Me',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).cardColor,
                    ),
                    child: Text(
                      (_profile!.bio != null && _profile!.bio!.trim().isNotEmpty)
                          ? _profile!.bio!
                          : 'No bio yet. Tap edit to add your about me.',
                    ),
                  ),
                  if (_profile!.skillsList.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _profile!.skillsList.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor:
                              Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'My Posts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          _posts.isEmpty
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Text('No posts yet'),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => PostCard(
                      post: _posts[index],
                      onDelete: () => _loadProfile(forceRefresh: true),
                    ),
                    childCount: _posts.length,
                  ),
                ),
        ],
      ),
    );
  }
}
