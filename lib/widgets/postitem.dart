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

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      widget.post.likes += isLiked ? 1 : -1;
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(widget.post.avatarUrl),
            ),
            title: Text(widget.post.username),
            subtitle: Text('2 hours ago'), // Update this to be dynamic if necessary
          ),
          Container(
            height: 300,
            width: double.infinity,
            child: Image.asset(widget.post.imageUrl, fit: BoxFit.cover),
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
