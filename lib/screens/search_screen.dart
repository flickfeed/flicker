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

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchUsers(_searchController.text.trim());
    });
  }

  // Search for users by username
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
      final response = await supabase
          .from('users') // Assuming your users are stored in a table named 'users'
          .select()
          .ilike('username', '%$query%') // Perform case-insensitive search
          .execute();

      if (response.error != null) {
        throw Exception(response.error!.message);
      }

      setState(() {
        _filteredUsers = List<Map<String, dynamic>>.from(response.data ?? []);
      });
    } catch (e) {
      print("Error fetching users: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching users")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Check if the user is following the searched user
  Future<bool> _isFollowing(String userId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    final response = await supabase
        .from('followers') // Assuming the followers are stored in a 'followers' table
        .select()
        .eq('follower_id', user.id)
        .eq('followed_id', userId)
        .single()
        .execute();

    return response.data != null;
  }

  @override
  Widget build(BuildContext context) {
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
          : ListView.builder(
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          String userId = user['id'];

          return FutureBuilder<bool>(
            future: _isFollowing(userId),
            builder: (context, snapshot) {
              bool isFollowing = snapshot.data ?? false;

              return ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    user['profile_image_url'] ??
                        'https://example.com/default_profile_image.jpg',
                  ),
                ),
                title: Text(user['username'] ?? 'Unknown'),
                trailing: ElevatedButton(
                  onPressed: () {
                    if (isFollowing) {
                      _unfollowUser(userId);
                    } else {
                      _followUser(userId);
                    }
                  },
                  child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                ),
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
              );
            },
          );
        },
      ),
    );
  }

  // Follow a user
  void _followUser(String followedUserId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final currentUserId = user.id;

    // Add the followed user to the current user's "following" list
    await supabase.from('followers').insert([
      {'follower_id': currentUserId, 'followed_id': followedUserId}
    ]).execute();

    // Add the current user to the followed user's "followers" list
    await supabase.from('followers').insert([
      {'follower_id': followedUserId, 'followed_id': currentUserId}
    ]).execute();

    setState(() {});
  }

  // Unfollow a user
  void _unfollowUser(String followedUserId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final currentUserId = user.id;

    // Remove the followed user from the current user's "following" list
    await supabase
        .from('followers')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('followed_id', followedUserId)
        .execute();

    // Remove the current user from the followed user's "followers" list
    await supabase
        .from('followers')
        .delete()
        .eq('follower_id', followedUserId)
        .eq('followed_id', currentUserId)
        .execute();

    setState(() {});
  }
}
