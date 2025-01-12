import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/posts.dart';

class CommentSectionWidget extends StatefulWidget {
  final Post post;
  final Function onCommentAdded;

  const CommentSectionWidget({
    super.key,
    required this.post,
    required this.onCommentAdded,
  });

  @override
  _CommentSectionWidgetState createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  final TextEditingController _commentController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isPostingComment = false;

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isPostingComment = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get user details
      final userResponse = await _supabase
          .from('userdetails')
          .select('username, avatar_url')
          .eq('id', userId)
          .single();

      // Create comment
      final comment = {
        'post_id': widget.post.postId,
        'user_id': userId,
        'text': _commentController.text.trim(),
        'username': userResponse['username'],
        'avatar_url': userResponse['avatar_url'],
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('comments').insert(comment);

      // Create notification for comment
      if (widget.post.userId != userId) {  // Don't notify if user comments on their own post
        await _supabase.from('notifications').insert({
          'recipient_id': widget.post.userId,
          'sender_id': userId,
          'type': 'comment',
          'content': _commentController.text.trim(),
          'post_id': widget.post.postId,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      if (mounted) {
        _commentController.clear();
        widget.onCommentAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPostingComment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              _supabase.auth.currentUser?.userMetadata?['avatar_url'] ??
                  'https://via.placeholder.com/32',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              maxLines: null,
            ),
          ),
          if (_isPostingComment)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _postComment,
              child: Text(
                'Post',
                style: TextStyle(
                  color: _commentController.text.trim().isEmpty
                      ? Colors.blue.withOpacity(0.5)
                      : Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
