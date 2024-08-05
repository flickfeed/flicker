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
      username: 'CurrentUser', // Replace with the current user's username
      avatarUrl: 'assets/images/your_avatar.jpg', // Replace with the current user's avatar
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      widget.post.comments.add(newComment);
    });

    _commentController.clear();
  }

  void _addReply(String text, int commentIndex) {
    if (text.isEmpty) return;

    final newReply = Comment(
      username: 'CurrentUser', // Replace with the current user's username
      avatarUrl: 'assets/images/your_avatar.jpg', // Replace with the current user's avatar
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      widget.post.comments[commentIndex].replies.add(newReply);
    });

    _replyControllers[commentIndex]?.clear();
  }

  void _toggleCommentLike(Comment comment) {
    setState(() {
      comment.isLiked = !comment.isLiked;
      comment.likes += comment.isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.post.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.post.comments[index];
                _replyControllers[index] = TextEditingController();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(comment.avatarUrl),
                      ),
                      title: Text(comment.username),
                      subtitle: Text(comment.text),
                      trailing: IconButton(
                        icon: Icon(
                          comment.isLiked ? Ionicons.heart : Ionicons.heart_outline,
                          color: comment.isLiked ? Colors.red : Colors.black,
                        ),
                        onPressed: () => _toggleCommentLike(comment),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text('${comment.likes} likes'),
                          Spacer(),
                          IconButton(
                            icon: Icon(Ionicons.chatbubble_outline),
                            onPressed: () {
                              setState(() {
                                comment.isReplying = !comment.isReplying;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (comment.isReplying)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replyControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Add a reply...',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Ionicons.send_outline),
                              onPressed: () => _addReply(_replyControllers[index]!.text, index),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: comment.replies.map((reply) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(reply.avatarUrl),
                            ),
                            title: Text(reply.username),
                            subtitle: Text(reply.text),
                            trailing: IconButton(
                              icon: Icon(
                                reply.isLiked ? Ionicons.heart : Ionicons.heart_outline,
                                color: reply.isLiked ? Colors.red : Colors.black,
                              ),
                              onPressed: () => _toggleCommentLike(reply),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
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
