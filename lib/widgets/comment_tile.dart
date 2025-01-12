import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment.dart';
import '../utils/date_formatter.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback onLike;
  final Function(String) onReply;
  final VoidCallback onDelete;
  final bool isReply;
  final bool showReplies;
  final VoidCallback onToggleReplies;

  const CommentTile({
    Key? key,
    required this.comment,
    required this.onLike,
    required this.onReply,
    required this.onDelete,
    this.isReply = false,
    this.showReplies = false,
    required this.onToggleReplies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onLongPress: () => _showCommentOptions(context),
          child: Padding(
            padding: EdgeInsets.only(
              left: isReply ? 48.0 : 16.0,
              right: 16.0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: comment.avatarUrl != null
                      ? NetworkImage(comment.avatarUrl!)
                      : null,
                  child: comment.avatarUrl == null ? Icon(Icons.person) : null,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: comment.username,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' '),
                            TextSpan(text: comment.text),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            DateFormatter.getTimeAgo(comment.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => onLike(),
                            child: Text(
                              'Like',
                              style: TextStyle(
                                color: comment.isLiked ? Colors.blue : Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => onReply(comment.username),
                            child: Text(
                              'Reply',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (comment.likes > 0)
                  Container(
                    padding: EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, size: 12, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          comment.likes.toString(),
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: isReply ? 64.0 : 32.0),
            child: TextButton(
              onPressed: onToggleReplies,
              child: Text(
                showReplies
                    ? 'Hide replies'
                    : 'View ${comment.replies.length} replies',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        if (showReplies)
          ...comment.replies.map((reply) => CommentTile(
                comment: reply,
                onLike: () {},
                onReply: onReply,
                onDelete: () {},
                isReply: true,
                showReplies: false,
                onToggleReplies: () {},
              )),
      ],
    );
  }

  void _showCommentOptions(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == comment.userId) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Delete comment'),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      );
    }
  }
} 