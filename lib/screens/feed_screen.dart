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
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Post> _posts = [];
  bool _isLoadingPosts = true;
  final ScrollController _scrollController = ScrollController();
  bool _showIcons = true;
  double _iconOpacity = 1.0;

  @override
  void initState() {
    super.initState();
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

  Future<void> _fetchPosts() async {
    try {
      final response = await Supabase.instance.client
          .from('posts')
          .select('*')
          .order('timestamp', ascending: false)
          .execute();

      if (response.status == 200 && response.data != null) {
        final data = response.data as List<dynamic>;

        if (data.isNotEmpty) {
          setState(() {
            _posts = data.map((post) => Post.fromMap(post as Map<String, dynamic>)).toList();
            _isLoadingPosts = false;
          });
        } else {
          print('No posts found.');
          setState(() {
            _isLoadingPosts = false;
          });
        }
      } else {
        print('Error fetching posts: Status code: ${response.status}, Response: ${response.data}');
        setState(() {
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      print('Unexpected error: $e');
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
          TextButton(onPressed: () { print("hii"); }, child: Text("click")),
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
}
