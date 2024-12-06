import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'usersprofilescreen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchUsers(_searchController.text.trim());
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .like('username', '$query%')
          .execute();

      if (response.error != null) {
        print("Error fetching users: ${response.error!.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching users")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _filteredUsers = List<Map<String, dynamic>>.from(response.data);
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _isFollowingUser(String userId) async {
    String currentUserId = Supabase.instance.client.auth.currentUser!.id;

    final response = await Supabase.instance.client
        .from('following')
        .select()
        .eq('follower_id', currentUserId)
        .eq('followed_id', userId)
        .single()
        .execute();

    return response.error == null && response.data != null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 120).floor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredUsers.isEmpty && _searchController.text.isNotEmpty
          ? Center(child: Text("No users found"))
          : GridView.builder(
        padding: const EdgeInsets.all(4.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return FutureBuilder<bool>(
            future: _isFollowingUser(user['id']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return SizedBox.shrink(); // Handle error
              }

              bool isFollowing = snapshot.data!;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsersProfileScreen(
                        username: user['username'],
                        name: user['name'] ?? 'User',
                        avatarUrl: user['profile_image_url'] ??
                            'https://example.com/default_profile_image.jpg',
                        postCount: user['post_count'] ?? 0,
                        followerCount: user['follower_count'] ?? 0,
                        followingCount: user['following_count'] ?? 0,
                        bio: user['bio'] ?? '',
                        isFollowing: isFollowing,
                      ),
                    ),
                  );
                },
                child: Container(
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          user['profile_image_url'] ??
                              'https://example.com/default_profile_image.jpg',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(user['username'] ?? 'Unknown'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
