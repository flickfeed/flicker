import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/posts.dart';
import '../widgets/postwidgets.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String username;

  const UserProfileScreen({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  List<Post> _userPosts = [];
  Map<String, dynamic>? _userProfile;
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isFollowing = false;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadAllData();

    // Add focus listener to refresh data when screen regains focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).addListener(_onFocusChange);
    });
  }

  @override
  void dispose() {
    FocusScope.of(context).removeListener(_onFocusChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (FocusScope.of(context).hasFocus) {
      _loadAllData();
    }
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    await Future.wait([
      _loadUserProfile(),
      _loadUserPosts(),
      _checkFollowStatus(),
      _loadFollowCounts(),
    ]);

    setState(() => _isLoading = false);
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await _supabase
          .from('userdetails')
          .select()
          .eq('id', widget.userId)
          .single();
      
      setState(() {
        _userProfile = response;
      });
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _loadUserPosts() async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);

      setState(() {
        _userPosts = (response as List)
            .map((post) => Post.fromMap(post))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user posts: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFollowCounts() async {
    try {
      // Get followers count
      final followersResponse = await _supabase
          .from('followers')
          .select('follower_id')
          .eq('following_id', widget.userId);
      
      // Get following count
      final followingResponse = await _supabase
          .from('followers')
          .select('following_id')
          .eq('follower_id', widget.userId);

      setState(() {
        _followersCount = (followersResponse as List).length;
        _followingCount = (followingResponse as List).length;
      });
    } catch (e) {
      print('Error loading follow counts: $e');
    }
  }

  Future<void> _checkFollowStatus() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      final response = await _supabase
          .from('followers')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', widget.userId)
          .maybeSingle();

      setState(() {
        _isFollowing = response != null;
      });
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      if (_isFollowing) {
        await _supabase
            .from('followers')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', widget.userId);
      } else {
        await _supabase.from('followers').insert({
          'follower_id': currentUserId,
          'following_id': widget.userId,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      // Refresh follow counts after toggling
      await _loadFollowCounts();
      await _checkFollowStatus();
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }

  Future<void> _showDeleteDialog(Post post) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePost(post);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(Post post) async {
    try {
      // First delete the image from storage
      final imageUrl = post.imageUrl;
      final uri = Uri.parse(imageUrl);
      final imagePath = uri.pathSegments.last;
      
      await _supabase.storage
          .from('images')
          .remove(['posts/$imagePath']);

      // Then delete the post from the database
      await _supabase
          .from('posts')
          .delete()
          .eq('id', post.postId);

      // Update the UI
      setState(() {
        _userPosts.removeWhere((p) => p.postId == post.postId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      print('Error deleting post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = widget.userId == _supabase.auth.currentUser?.id;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: _userProfile?['avatar_url'] != null
                                    ? NetworkImage(_userProfile!['avatar_url'])
                                    : null,
                                child: _userProfile?['avatar_url'] == null
                                    ? Icon(Icons.person, size: 40, 
                                        color: theme.iconTheme.color)
                                    : null,
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatColumn(_userPosts.length, 'Posts'),
                                    _buildStatColumn(_followersCount, 'Followers'),
                                    _buildStatColumn(_followingCount, 'Following'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userProfile?['name'] ?? '',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_userProfile?['bio'] != null)
                                Text(
                                  _userProfile!['bio'],
                                  style: theme.textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        if (!isCurrentUser)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton(
                              onPressed: _toggleFollow,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 36),
                                backgroundColor: _isFollowing 
                                    ? theme.scaffoldBackgroundColor
                                    : theme.colorScheme.primary,
                                side: BorderSide(
                                  color: _isFollowing 
                                      ? theme.dividerColor
                                      : theme.colorScheme.primary,
                                ),
                              ),
                              child: Text(
                                _isFollowing ? 'Following' : 'Follow',
                                style: TextStyle(
                                  color: _isFollowing 
                                      ? theme.textTheme.bodyLarge?.color
                                      : theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(
                              icon: Icon(Icons.grid_on),
                            ),
                          ],
                          indicatorColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: _userPosts.length,
                    itemBuilder: (context, index) {
                      final post = _userPosts[index];
                      final isCurrentUserPost = post.userId == _supabase.auth.currentUser?.id;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostWidget(
                                post: post,
                                onPostUpdated: () {
                                  setState(() {});
                                },
                                onPostDeleted: (String postId) {
                                  setState(() {
                                    _userPosts.removeWhere((p) => p.postId == postId);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        onLongPress: isCurrentUserPost ? () => _showDeleteDialog(post) : null,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              post.imageUrl,
                              fit: BoxFit.cover,
                            ),
                            if (isCurrentUserPost)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatColumn(int count, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Followers') {
          Navigator.pushNamed(
            context,
            '/followers',
            arguments: widget.userId,
          ).then((_) => _loadAllData()); // Refresh when returning
        } else if (label == 'Following') {
          Navigator.pushNamed(
            context,
            '/following',
            arguments: widget.userId,
          ).then((_) => _loadAllData()); // Refresh when returning
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
} 