import 'package:flutter/material.dart';

class UsersProfileScreen extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isFollowing;

  UsersProfileScreen({
    required this.username,
    required this.avatarUrl,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(avatarUrl),
              radius: 50,
            ),
            SizedBox(height: 10),
            Text(
              username,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Posts: $postCount'),
            Text('Followers: $followerCount'),
            Text('Following: $followingCount'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Follow/Unfollow functionality here
              },
              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
            ),
          ],
        ),
      ),
    );
  }
}
