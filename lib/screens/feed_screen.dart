import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flickfeedpro/widgets/postwidgets.dart';
import 'package:flickfeedpro/models/posts.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> _stories = [];
  List<Post> _posts = [];
  bool _isLoadingStories = true;
  bool _isLoadingPosts = true;
  final ScrollController _scrollController = ScrollController();
  bool _showIcons = true;
  double _iconOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _fetchStories();
    _fetchPosts();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse && _showIcons) {
        setState(() {
          _iconOpacity = 0.0;
          _showIcons = false;
        });
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward && !_showIcons) {
        setState(() {
          _iconOpacity = 1.0;
          _showIcons = true;
        });
      }
    });
  }

  Future<void> _fetchStories() async {
    try {
      final response = await Supabase.instance.client
          .from('stories')
          .select('*')
          .order('timestamp', ascending: false)
          .execute();

      if (response.error == null) {
        setState(() {
          _stories = List<Map<String, dynamic>>.from(response.data);
          _isLoadingStories = false;
        });
      } else {
        throw response.error!;
      }
    } catch (e) {
      print('Error fetching stories: $e');
      setState(() {
        _isLoadingStories = false;
      });
    }
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await Supabase.instance.client
          .from('posts')
          .select('*')
          .order('timestamp', ascending: false)
          .execute();

      if (response.error == null) {
        setState(() {
          _posts = (response.data as List<dynamic>)
              .map((post) => Post.fromMap(post as Map<String, dynamic>))
              .toList();
          _isLoadingPosts = false;
        });
      } else {
        throw response.error!;
      }
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: true,
                title: Text(
                  'FLICKFEED',
                  style: TextStyle(
                    fontFamily: 'Lobster',
                    fontSize: 32,
                  ),
                ),
              ),
              _buildStoriesSection(),
              SliverToBoxAdapter(
                child: Divider(height: 1.0, color: Colors.grey[300]),
              ),
              _buildPostsSection(),
            ],
          ),
          if (_isLoadingPosts) Center(child: CircularProgressIndicator()),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _iconOpacity,
              duration: Duration(milliseconds: 300),
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  right: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Icons can be added here
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        height: 120,
        child: _isLoadingStories
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _stories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildYourStory();
            }
            final story = _stories[index - 1];
            return _buildStoryAvatar(story);
          },
        ),
      ),
    );
  }

  Widget _buildPostsSection() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index >= _posts.length) {
            return null;
          }
          final post = _posts[index];
          return PostWidget(
            post: post,
            onLike: () {
              setState(() {
                post.toggleLike('currentUserId');
              });
            },
            onComment: () {
              // Handle comment action
            },
          );
        },
        childCount: _posts.length,
      ),
    );
  }

  Widget _buildYourStory() {
    return Container(
      width: 70,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/your_avatar.jpg'),
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.blue,
                child: Icon(Icons.add, size: 15, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 5),
          Expanded(
            child: Text(
              'Your Story',
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryAvatar(Map<String, dynamic> story) {
    final imageUrl = story['imageUrl'] ?? 'https://example.com/default_story_image.jpg';
    return Container(
      width: 70,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(height: 5),
          Expanded(
            child: Text(
              story['username'] ?? 'Unknown',
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
