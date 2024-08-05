import 'package:flutter/material.dart';
import 'package:flickfeedpro/models/posts.dart';
import 'package:flickfeedpro/screens/usersprofilescreen.dart';
import 'package:flickfeedpro/widgets/commentsectionwidget.dart';
import 'package:ionicons/ionicons.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  PostWidget({required this.post});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      widget.post.likes += isLiked ? 1 : -1;
    });
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About this account'),
              onTap: () {
                Navigator.pop(context);
                _navigateToProfile(context, widget.post.username);
              },
            ),
            ListTile(
              leading: Icon(Icons.report_outlined),
              title: Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // Add report functionality here
              },
            ),
            ListTile(
              leading: Icon(Icons.hide_source_outlined),
              title: Text('Hide this post'),
              onTap: () {
                Navigator.pop(context);
                // Add hide post functionality here
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToProfile(BuildContext context, String username) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UsersProfileScreen(
          username: username,
          avatarUrl: widget.post.avatarUrl,
          postCount: 20,
          followerCount: 200,
          followingCount: 150,
          isFollowing: false,
        ),
      ),
    );
  }

  void _openComments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentSection(post: widget.post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: GestureDetector(
            onTap: () => _navigateToProfile(context, widget.post.username),
            child: CircleAvatar(
              backgroundImage: AssetImage(widget.post.avatarUrl),
            ),
          ),
          title: GestureDetector(
            onTap: () => _navigateToProfile(context, widget.post.username),
            child: Text(widget.post.username),
          ),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ),
        Image.asset(
          widget.post.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                isLiked ? Ionicons.heart : Ionicons.heart_outline,
                color: isLiked ? Colors.red : Colors.black,
              ),
              onPressed: _toggleLike,
            ),
            IconButton(
              icon: Icon(Ionicons.chatbubble_outline),
              onPressed: () => _openComments(context),
            ),
            IconButton(
              icon: Icon(Ionicons.paper_plane_outline),
              onPressed: () {
                // Add share functionality here
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${widget.post.likes} likes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(widget.post.caption),
        ),
        if (widget.post.comments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () => _openComments(context),
              child: Text(
                'View all ${widget.post.comments.length} comments',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        if (widget.post.comments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${widget.post.comments.first.username}: ${widget.post.comments.first.text}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}
