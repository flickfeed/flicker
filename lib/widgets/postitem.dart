import 'package:flutter/material.dart';
import 'package:flickfeedpro/models/posts.dart';
import 'package:flickfeedpro/widgets/commentsectionwidget.dart';
import 'package:ionicons/ionicons.dart';

class PostItem extends StatefulWidget {
  final Post post;

  PostItem({required this.post});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    // Replace 'currentUserId' with the actual user ID
    isLiked = widget.post.likedUsers.contains('currentUserId'); // Check if the post is liked by the current user
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        widget.post.likedUsers.add('currentUserId'); // Add user ID when liked
      } else {
        widget.post.likedUsers.remove('currentUserId'); // Remove user ID when unliked
      }
      widget.post.toggleLike('currentUserId'); // Pass actual user ID here
    });
  }

  void _openComments() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentSection(post: widget.post),
      ),
    );
  }

  void _sharePost() {
    // Implement share functionality
  }

  String _timeAgo(DateTime postTime) {
    final now = DateTime.now();
    final difference = now.difference(postTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.post.avatarUrl),
            ),
            title: Text(widget.post.username),
            subtitle: Text(_timeAgo(widget.post.timestamp.toDate())),
          ),
          Container(
            height: 300,
            width: double.infinity,
            child: Image.network(widget.post.imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Ionicons.heart : Ionicons.heart_outline,
                    color: isLiked ? Colors.red : Colors.black,
                  ),
                  onPressed: _toggleLike,
                ),
                SizedBox(width: 10.0),
                Text('${widget.post.likes} likes'),
                Spacer(),
                IconButton(
                  icon: Icon(Ionicons.chatbubble_outline),
                  onPressed: _openComments,
                ),
                IconButton(
                  icon: Icon(Ionicons.paper_plane_outline),
                  onPressed: _sharePost,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              widget.post.caption,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
