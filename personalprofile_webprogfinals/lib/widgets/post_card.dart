import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../services/supabase_service.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.onDelete,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = post.userId == SupabaseService.instance.currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.userAvatar != null
                  ? CachedNetworkImageProvider(post.userAvatar!)
                      as ImageProvider<Object>
                  : const AssetImage('assets/profile.png'),
            ),
            title: Text(
              post.userFullName ?? post.username ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_formatTime(post.createdAt)),
            trailing: isOwner
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await SupabaseService.instance.deletePost(post.id);
                      onDelete();
                    },
                  )
                : null,
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(post.content),
          ),

          // Image
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            CachedNetworkImage(
              imageUrl: post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey.shade300,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Colors.grey.shade300,
                child: const Icon(Icons.error),
              ),
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
