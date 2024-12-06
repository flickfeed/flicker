import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:flickfeedpro/models/posts.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final VoidCallback onLike; // Callback for like functionality
  final VoidCallback onComment; // Callback for comment functionality

  PostWidget({
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  String _formatTimestamp(DateTime timestamp) {
    final timeDifference = DateTime.now().difference(timestamp);

    if (timeDifference.inMinutes < 1) return 'Just now';
    if (timeDifference.inHours < 1) return '${timeDifference.inMinutes} minutes ago';
    if (timeDifference.inDays < 1) return '${timeDifference.inHours} hours ago';
    return DateFormat.yMMMd().format(timestamp); // e.g., "Sep 20, 2023"
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.avatarUrl), // Display user's avatar
            ),
            title: Text(post.username),
            subtitle: Text(_formatTimestamp(post.timestamp)), // Format the timestamp
          ),
          Container(
            height: 300,
            width: double.infinity,
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child; // Loaded successfully
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                ); // Placeholder image
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.likedUsers.contains('currentUserId') // Replace with actual user ID
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: post.likedUsers.contains('currentUserId') ? Colors.red : null,
                  ),
                  onPressed: onLike, // Handle like functionality
                ),
                Text('${post.likes} likes'),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: onComment, // Handle comment functionality
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              post.caption,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
