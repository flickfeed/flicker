import 'package:flutter/material.dart';
import 'package:flickfeedpro/models/posts.dart';
import 'package:flickfeedpro/screens/usersprofilescreen.dart';
import 'package:flickfeedpro/screens/sharepostscreen.dart';
import 'package:flickfeedpro/screens/likesscreen.dart';
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
      widget.post.toggleLike(isLiked);
    });
  }

  void _sharePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SharePostScreen(post: widget.post),
      ),
    );
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
                _reportPost();
              },
            ),
            ListTile(
              leading: Icon(Icons.hide_source_outlined),
              title: Text('Hide this post'),
              onTap: () {
                Navigator.pop(context);
                _hidePost();
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
          name: 'John Doe', // Placeholder name
          bio: 'Lorem ipsum dolor sit amet.', // Placeholder bio
          mutualFollowers: ['user1', 'user2'], // Provide mutual followers here
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

  void _reportPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reported this post')),
    );
  }

  void _hidePost() {
    setState(() {
      widget.post.isHidden = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post hidden')),
    );
  }

  void _showLikes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LikesScreen(likedUsers: widget.post.likedUsers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.post.isHidden) return SizedBox.shrink();

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
          title: Text(widget.post.username),
          subtitle: Text(widget.post.location),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ),
        Image.asset(
          widget.post.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 400,
        ),
        Row(
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
              onPressed: _sharePost,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GestureDetector(
            onTap: () => _showLikes(context),
            child: Text(
              '${widget.post.likes} likes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(widget.post.username, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Expanded(child: Text(widget.post.caption)),
            ],
          ),
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
