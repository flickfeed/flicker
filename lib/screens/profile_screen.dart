import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'EditProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  String profileName = 'Username';
  String username = 'username';
  String website = '';
  String bio = '';
  String profileImageUrl = '';
  int postsCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool isLoading = true;

  late TabController _tabController;

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchProfileData();
  }

  // Fetch user profile data from Supabase
  Future<void> _fetchProfileData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('users') // Assuming your users are stored in a table named 'users'
            .select()
            .eq('id', user.id)
            .single()
            .execute();

        if (response.error != null) {
          print('Error fetching profile: ${response.error!.message}');
        } else {
          final userData = response.data as Map<String, dynamic>;
          setState(() {
            profileName = userData['profile_name'] ?? 'No Name';
            username = userData['username'] ?? 'username';
            website = userData['website'] ?? '';
            bio = userData['bio'] ?? '';
            profileImageUrl = userData['profile_image_url'] ?? '';
            postsCount = userData['posts_count'] ?? 0;
            followersCount = userData['followers_count'] ?? 0;
            followingCount = userData['following_count'] ?? 0;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('No user is logged in');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching profile data: $e');
    }
  }

  void _navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          name: profileName,
          username: username,
          website: website,
          bio: bio,
          imageUrl: profileImageUrl,
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        profileName = result['name']!;
        username = result['username']!;
        website = result['website']!;
        bio = result['bio']!;
        profileImageUrl = result['imageUrl']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? 'Loading...' : username),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    ),
                    SizedBox(width: 16),
                    Column(
                      children: [
                        Text(postsCount.toString()),
                        Text('Posts'),
                      ],
                    ),
                    SizedBox(width: 16),
                    Column(
                      children: [
                        Text(followersCount.toString()),
                        Text('Followers'),
                      ],
                    ),
                    SizedBox(width: 16),
                    Column(
                      children: [
                        Text(followingCount.toString()),
                        Text('Following'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(profileName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(bio),
                SizedBox(height: 5),
                Text(website, style: TextStyle(color: Colors.blue)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _navigateToEditProfile(context),
                  child: Text('Edit Profile'),
                ),
              ],
            ),
          ),
          Divider(),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.grid_on)),
              Tab(icon: Icon(Icons.list)),
            ],
          ),
          Container(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGridPosts(),
                _buildListPosts(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fetch user's posts in grid layout
  Widget _buildGridPosts() {
    final userId = supabase.auth.currentUser?.id ?? '';
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('posts') // Assuming posts are stored in 'posts' table
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .stream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;

        return GridView.builder(
          itemCount: posts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            final post = posts[index];
            final imageUrl = post['image_url'] ?? 'https://example.com/default_image.jpg';
            return Image.network(imageUrl, fit: BoxFit.cover);
          },
        );
      },
    );
  }

  // Fetch user's posts in list layout
  Widget _buildListPosts() {
    final userId = supabase.auth.currentUser?.id ?? '';
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .stream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final imageUrl = post['image_url'] ?? 'https://example.com/default_image.jpg';
            final caption = post['caption'] ?? '';
            return Column(
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
                SizedBox(height: 8),
                Text(caption),
              ],
            );
          },
        );
      },
    );
  }
}
