import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/friend.dart';
import '../services/supabase_service.dart';

class FriendCard extends StatelessWidget {
  final Friend friend;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FriendCard({
    super.key,
    required this.friend,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: friend.imageUrl != null
              ? CachedNetworkImageProvider(friend.imageUrl!)
                  as ImageProvider<Object>
              : const AssetImage('assets/No Photo.jpg'),
        ),
        title: Text(
          friend.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: friend.contactInfo != null && friend.contactInfo!.isNotEmpty
            ? Text(friend.contactInfo!)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Friend'),
                    content: Text('Remove ${friend.name} from your friends?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await SupabaseService.instance.deleteFriend(friend.id);
                  onDelete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
