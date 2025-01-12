import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/posts.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _userData;
  List<Post> _userPosts = [];
  bool _isLoading = true;
  late TabController _tabController;
  int _postsCount = 0;
  int _followersCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshProfile();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('userdetails')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserPosts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _userPosts = (response as List).map((post) => Post.fromMap(post)).toList();
      });
    } catch (e) {
      print('Error loading user posts: $e');
    }
  }

  Future<void> _loadCounts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get posts count
      final postsResponse = await _supabase
          .from('posts')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', userId);

      // Get followers count
      final followersResponse = await _supabase
          .from('followers')
          .select('follower_id', const FetchOptions(count: CountOption.exact))
          .eq('following_id', userId);

      // Get following count
      final followingResponse = await _supabase
          .from('followers')
          .select('following_id', const FetchOptions(count: CountOption.exact))
          .eq('follower_id', userId);

      setState(() {
        _postsCount = postsResponse.count ?? 0;
        _followersCount = followersResponse.count ?? 0;
        _followingCount = followingResponse.count ?? 0;
      });

    } catch (e) {
      print('Error loading counts: $e');
    }
  }

  Future<void> _refreshProfile() async {
    await Future.wait([
      _loadUserData(),
      _loadUserPosts(),
      _loadCounts(),
    ]);
  }

  Future<void> _updateProfilePicture(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isLoading = true);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Upload to storage
      final file = File(image.path);
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = '$userId/$fileName';

      await _supabase.storage.from('avatars').upload(filePath, file);

      // Get the public URL
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      // Update user profile
      await _supabase
          .from('userdetails')
          .update({'avatar_url': imageUrl})
          .eq('id', userId);

      await _loadUserData();

    } catch (e) {
      print('Error updating profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeProfilePicture() async {
    try {
      setState(() => _isLoading = true);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (_userData?['avatar_url'] != null) {
        // Delete from storage
        final oldPath = _userData!['avatar_url'].split('/').last;
        await _supabase.storage.from('avatars').remove([oldPath]);

        // Update user profile
        await _supabase
            .from('userdetails')
            .update({'avatar_url': null})
            .eq('id', userId);

        await _loadUserData();
      }
    } catch (e) {
      print('Error removing profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing profile picture')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showProfilePictureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _updateProfilePicture(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _updateProfilePicture(ImageSource.gallery);
                },
              ),
              if (_userData?['avatar_url'] != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Remove Current Photo', 
                    style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfilePicture();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _userData?['username'] ?? '',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  // Profile Picture with edit option
                                  GestureDetector(
                                    onTap: _showProfilePictureOptions,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: _userData?['avatar_url'] != null
                                                ? Image.network(
                                                    _userData!['avatar_url'],
                                                    fit: BoxFit.cover,
                                                  )
                                                : Icon(Icons.person,
                                                    size: 40,
                                                    color: Colors.grey[400]),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 32),
                                  // Stats
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildStatColumn(
                                            _postsCount.toString(), 'Posts'),
                                        _buildStatButton(
                                            _followersCount.toString(),
                                            'Followers',
                                            () => _showFollowers()),
                                        _buildStatButton(
                                            _followingCount.toString(),
                                            'Following',
                                            () => _showFollowing()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              // Name and Bio
                              if (_userData?['name'] != null) ...[
                                Text(
                                  _userData!['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                              ],
                              if (_userData?['bio'] != null) ...[
                                Text(
                                  _userData!['bio'],
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 12),
                              ],
                              // Edit Profile Button
                              OutlinedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/edit-profile'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text('Edit Profile'),
                              ),
                            ],
                          ),
                        ),
                        // Tabs
                        TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.black,
                          tabs: [
                            Tab(icon: Icon(Icons.grid_on, color: Colors.black)),
                            Tab(icon: Icon(Icons.list, color: Colors.black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Posts Grid/List
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPostsGrid(),
                        _buildPostsList(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatButton(String count, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.bookmark_border),
            title: Text('Saved'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to saved posts
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await _supabase.auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  void _showFollowers() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    Navigator.pushNamed(context, '/followers', arguments: userId);
  }

  void _showFollowing() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    Navigator.pushNamed(context, '/following', arguments: userId);
  }

  Widget _buildStatColumn(String count, String label) {
    return GestureDetector(
      onTap: () {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) return;

        if (label == 'Followers') {
          Navigator.pushNamed(
            context,
            '/followers',
            arguments: userId,
          ).then((_) => _refreshProfile());
        } else if (label == 'Following') {
          Navigator.pushNamed(
            context,
            '/following',
            arguments: userId,
          ).then((_) => _refreshProfile());
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(1),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return GestureDetector(
          onTap: () {
            // Navigate to post detail view
            Navigator.pushNamed(
              context,
              '/post-detail',
              arguments: post,
            );
          },
          child: Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info header
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: _userData?['avatar_url'] != null
                      ? NetworkImage(_userData!['avatar_url'])
                      : null,
                  child: _userData?['avatar_url'] == null
                      ? Icon(Icons.person, color: Colors.grey[400])
                      : null,
                ),
                title: Text(
                  _userData?['username'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: post.location != null && post.location!.isNotEmpty
                    ? Text(post.location!)
                    : null,
              ),
              // Post image
              Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
              // Post actions
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.red : null,
                    ),
                    onPressed: () {
                      // Handle like
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.comment_outlined),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/comments',
                        arguments: post,
                      );
                    },
                  ),
                ],
              ),
              // Like count
              if (post.likes > 0)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${post.likes} ${post.likes == 1 ? 'like' : 'likes'}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              // Caption
              if (post.caption.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(post.caption),
                ),
            ],
          ),
        );
      },
    );
  }
}
