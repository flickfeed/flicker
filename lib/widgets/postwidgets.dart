import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../models/posts.dart';
import '../screens/comments_screen.dart';
import '../screens/user_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final VoidCallback onPostUpdated;
  final Function(String) onPostDeleted;

  const PostWidget({
    Key? key,
    required this.post,
    required this.onPostUpdated,
    required this.onPostDeleted,
  }) : super(key: key);

  Future<void> _handleLike(BuildContext context) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await post.toggleLike(userId);
      onPostUpdated(); // Refresh the UI after like
    } catch (e) {
      print('Error liking post: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating like')),
        );
      }
    }
  }

  void _navigateToComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => CommentsScreen(
          post: post,
          onCommentAdded: () {
            post.updateCommentCount(post.commentCount + 1);
            onPostUpdated();
          },
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context, String userId, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userId: userId,
          username: username,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePost(context);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;
      
      // First delete the image from storage
      final imageUrl = post.imageUrl;
      final uri = Uri.parse(imageUrl);
      final imagePath = uri.pathSegments.last;
      
      await supabase.storage
          .from('images')
          .remove(['posts/$imagePath']);

      // Then delete the post from the database
      await supabase
          .from('posts')
          .delete()
          .eq('id', post.postId);

      // Call the delete callback with the post ID
      onPostDeleted(post.postId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      print('Error deleting post: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUserPost = post.userId == Supabase.instance.client.auth.currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User header with clickable username
        ListTile(
          leading: GestureDetector(
            onTap: () => _navigateToUserProfile(context, post.userId, post.username),
            child: CircleAvatar(
              backgroundImage: NetworkImage(post.avatarUrl ?? 'default_avatar_url'),
            ),
          ),
          title: GestureDetector(
            onTap: () => _navigateToUserProfile(context, post.userId, post.username),
            child: Text(
              post.username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          subtitle: post.location != null && post.location!.isNotEmpty
              ? Text(post.location!)
              : null,
          trailing: isCurrentUserPost
              ? IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () => _showDeleteDialog(context),
                )
              : null,
        ),
        // Post image
        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        // Post actions
        Row(
          children: [
            IconButton(
              icon: Icon(
                post.likedUsers.contains(Supabase.instance.client.auth.currentUser?.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: post.likedUsers.contains(Supabase.instance.client.auth.currentUser?.id)
                    ? Colors.red
                    : null,
              ),
              onPressed: () => _handleLike(context),
            ),
            IconButton(
              icon: Icon(Icons.comment_outlined),
              onPressed: () => _navigateToComments(context),
            ),
          ],
        ),
        // Likes count
        if (post.likes > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${post.likes} ${post.likes == 1 ? 'like' : 'likes'}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        // Caption
        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: post.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' '),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),
        SizedBox(height: 8),
      ],
    );
  }
}
