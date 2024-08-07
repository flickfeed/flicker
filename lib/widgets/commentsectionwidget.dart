import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flickfeedpro/models/comment.dart';
import 'package:flickfeedpro/models/posts.dart';

class CommentSection extends StatefulWidget {
  final Post post;

  CommentSection({required this.post});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final Map<int, TextEditingController> _replyControllers = {};

  void _addComment(String text) {
    if (text.isEmpty) return;

    final newComment = Comment(
      username: 'CurrentUser',
      avatarUrl: 'assets/images/your_avatar.jpg',
      text: text,
      timestamp: DateTime.now(),
      replies: [],
    );

    setState(() {
      widget.post.comments.add(newComment);
    });

    _commentController.clear();
  }

  void _addReply(String text, List<Comment> replies) {
    if (text.isEmpty) return;

    final newReply = Comment(
      username: 'CurrentUser',
      avatarUrl: 'assets/images/your_avatar.jpg',
      text: text,
      timestamp: DateTime.now(),
      replies: [],
    );

    setState(() {
      replies.add(newReply);
    });
  }

  void _toggleCommentLike(Comment comment) {
    setState(() {
      comment.isLiked = !comment.isLiked;
      comment.likes += comment.isLiked ? 1 : -1;
    });
  }

  void _toggleRepliesVisibility(Comment comment) {
    setState(() {
      comment.areRepliesVisible = !comment.areRepliesVisible;
    });
  }

  void _handleSwipeAction(Comment comment, String action) {
    setState(() {
      if (action == 'Delete') {
        widget.post.comments.remove(comment);
      }
    });
  }

  Widget _buildCommentTile(Comment comment, int parentIndex, List<Comment> parentReplies, {int depth = 0}) {
    int replyIndex = depth * 1000 + parentReplies.indexOf(comment);
    _replyControllers[replyIndex] ??= TextEditingController();

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0), // Adjust padding based on depth
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Dismissible(
            key: Key(comment.text),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.blue,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.report, color: Colors.white),
                  SizedBox(width: 10),
                  Icon(Icons.person, color: Colors.white),
                ],
              ),
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                _handleSwipeAction(comment, 'Delete');
              } else if (direction == DismissDirection.endToStart) {
                _handleSwipeAction(comment, 'Report');
              }
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(comment.avatarUrl),
              ),
              title: Row(
                children: [
                  Text(comment.username),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      comment.text,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(
                    '${comment.timestamp.hour}:${comment.timestamp.minute}',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        comment.isReplying = !comment.isReplying;
                      });
                    },
                    child: Text(
                      'Reply',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${comment.likes}'),
                  IconButton(
                    icon: Icon(
                      comment.isLiked ? Ionicons.heart : Ionicons.heart_outline,
                      color: comment.isLiked ? Colors.red : Colors.black,
                    ),
                    onPressed: () => _toggleCommentLike(comment),
                  ),
                ],
              ),
            ),
          ),
          if (comment.replies.isNotEmpty)
            GestureDetector(
              onTap: () => _toggleRepliesVisibility(comment),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  comment.areRepliesVisible ? 'Hide replies' : 'View replies',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
          if (comment.areRepliesVisible)
            Padding(
              padding: EdgeInsets.only(left: 16.0), // Adjust padding for replies
              child: Column(
                children: comment.replies.map((reply) {
                  return _buildCommentTile(reply, parentIndex, comment.replies, depth: depth + 1);
                }).toList(),
              ),
            ),
          if (comment.isReplying)
            Padding(
              padding: EdgeInsets.only(left: 32.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyControllers[replyIndex],
                      decoration: InputDecoration(
                        hintText: 'Reply to @${comment.username}',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Ionicons.send_outline),
                    onPressed: () {
                      _addReply(_replyControllers[replyIndex]!.text, comment.replies);
                      _replyControllers[replyIndex]?.clear();
                      setState(() {
                        comment.isReplying = false;
                      });
                    },
                  ),
                ],
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
        title: Text('Comments', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.post.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.post.comments[index];
                return _buildCommentTile(comment, index, widget.post.comments);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Ionicons.send_outline),
                  onPressed: () => _addComment(_commentController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
