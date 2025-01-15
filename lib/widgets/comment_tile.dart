import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment.dart';
import '../utils/date_formatter.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback onLike;
  final Function(String, String?) onReply;
  final VoidCallback onDelete;
  final bool isReply;
  final bool showReplies;
  final VoidCallback onToggleReplies;
  final int nestLevel;
  final String? parentUsername;

  const CommentTile({
    Key? key,
    required this.comment,
    required this.onLike,
    required this.onReply,
    required this.onDelete,
    this.isReply = false,
    this.showReplies = false,
    required this.onToggleReplies,
    this.nestLevel = 0,
    this.parentUsername,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate left padding based on nesting level (max 3 levels)
    final leftPadding = 16.0 + (nestLevel > 3 ? 3 : nestLevel) * 24.0;
    final bool hasReplies = comment.replies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onLongPress: () => _showCommentOptions(context),
          child: Padding(
            padding: EdgeInsets.only(
              left: leftPadding,
              right: 16.0,
              top: 8.0,
              bottom: 4.0,
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
                      // Username and comment
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: comment.username,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' '),
                            TextSpan(
                              text: comment.text,
                              style: TextStyle(height: 1.4),
                            ),
                            TextSpan(text: ' • '),
                            TextSpan(
                              text: DateFormatter.getTimeAgo(comment.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      // Action buttons row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => onReply(comment.username, comment.id),
                            child: Text(
                              'Reply',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Like button with count
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        comment.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: comment.isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: onLike,
                      constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    if (comment.likes > 0)
                      Text(
                        comment.likes.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Show replies toggle
        if (hasReplies)
          Padding(
            padding: EdgeInsets.only(left: leftPadding + 40),
            child: TextButton(
              onPressed: onToggleReplies,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    showReplies 
                        ? Icons.keyboard_arrow_up 
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4),
                  Text(
                    showReplies
                        ? 'Hide replies'
                        : 'View ${comment.replies.length} ${comment.replies.length == 1 ? 'reply' : 'replies'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Replies
        if (showReplies)
          ...comment.replies.map((reply) => CommentTile(
                comment: reply,
                onLike: () {},
                onReply: onReply,
                onDelete: () {},
                isReply: true,
                showReplies: false,
                onToggleReplies: () {},
                nestLevel: nestLevel + 1,
                parentUsername: comment.username,
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