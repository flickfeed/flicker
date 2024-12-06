import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersProfileScreen extends StatelessWidget {
  final String username;
  final String name;
  final String avatarUrl;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final String bio;
  final bool isFollowing;

  UsersProfileScreen({
    required this.username,
    required this.name,
    required this.avatarUrl,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.bio,
    required this.isFollowing,
  });

  // Function to follow or unfollow the user
  Future<void> _followUnfollowUser(BuildContext context, String followedUserId, bool isFollowing) async {
    String currentUserId = Supabase.instance.client.auth.currentUser!.id;

    try {
      if (isFollowing) {
        // Unfollow logic
        await Supabase.instance.client
            .from('following')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('followed_id', followedUserId)
            .execute();

        await Supabase.instance.client
            .from('followers')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('user_id', followedUserId)
            .execute();
      } else {
        // Follow logic
        await Supabase.instance.client
            .from('following')
            .insert({
          'follower_id': currentUserId,
          'followed_id': followedUserId,
          'created_at': DateTime.now().toIso8601String(),
        })
            .execute();

        await Supabase.instance.client
            .from('followers')
            .insert({
          'follower_id': currentUserId,
          'user_id': followedUserId,
          'created_at': DateTime.now().toIso8601String(),
        })
            .execute();
      }

      // Display a message to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFollowing ? 'Unfollowed $username' : 'Followed $username'),
        ),
      );

      // Refresh the state by closing and reopening the page
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(username)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            SizedBox(height: 16),
            Text(name, style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(bio),
            SizedBox(height: 16),
            Text('Posts: $postCount  Followers: $followerCount  Following: $followingCount'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _followUnfollowUser(context, username, isFollowing),
              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
            ),
          ],
        ),
      ),
    );
  }
}
