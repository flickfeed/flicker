import 'package:flutter/material.dart';
import 'package:flickfeedpro/widgets/postwidgets.dart';
import 'package:flickfeedpro/models/posts.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:flickfeedpro/screens/comments_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class FeedScreen extends StatefulWidget {
  static void refreshFeed() {
    _feedScreenKey.currentState?.refreshFeed();
  }

  static final GlobalKey<_FeedScreenState> _feedScreenKey = GlobalKey();

  FeedScreen() : super(key: _feedScreenKey);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> _posts = [];
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Hide title when scrolling down, show when scrolling up
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showTitle) {
        setState(() => _showTitle = false);
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showTitle) {
        setState(() => _showTitle = true);
      }
    }
  }

  Future<void> refreshFeed() async {
    await _loadFeed();
  }

  void _handlePostDeleted(String postId) {
    setState(() {
      _posts.removeWhere((post) => post.postId == postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FlickFeed',
          style: TextStyle(
            fontFamily: 'Lobster',
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: _isLoading && _posts.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return PostWidget(
                    post: _posts[index],
                    onPostUpdated: () {
                      setState(() {});
                    },
                    onPostDeleted: _handlePostDeleted,
                  );
                },
              ),
      ),
    );
  }

  Future<void> _loadFeed() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      // Get IDs of users that the current user follows
      final followingResponse = await _supabase
          .from('followers')
          .select('following_id')
          .eq('follower_id', currentUserId);

      // Create a list of user IDs including current user and followed users
      List<String> userIds = [currentUserId];
      if (followingResponse != null) {
        userIds.addAll(
          (followingResponse as List).map((f) => f['following_id'] as String),
        );
      }

      // Fetch posts only from followed users and current user
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            userdetails!inner (
              username,
              avatar_url
            )
          ''')
          .in_('user_id', userIds)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _posts = (response as List)
              .map((post) => Post.fromMap({
                    ...post,
                    'username': post['userdetails']['username'],
                    'avatar_url': post['userdetails']['avatar_url'],
                  }))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading feed: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _likePost(Post post) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await post.toggleLike(userId);
      setState(() {
        // Update post in the list
        final index = _posts.indexWhere((p) => p.postId == post.postId);
        if (index != -1) {
          _posts[index] = post;
        }
      });
    } catch (e) {
      print('Error liking post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like')),
      );
    }
  }

  void _navigateToComments(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          post: post,
          onCommentAdded: () {
            setState(() {});
          },
          scrollController: ScrollController(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
