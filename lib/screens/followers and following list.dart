import 'package:flutter/material.dart';

class UsersListScreen extends StatelessWidget {
  final String username;
  final String screenType;

  UsersListScreen({
    required this.username,
    required this.screenType,
  });

  final List<Map<String, String>> dummyUsers = [
    {'username': 'user1', 'avatarUrl': 'assets/images/user1_avatar.png'},
    {'username': 'user2', 'avatarUrl': 'assets/images/user2_avatar.png'},
    // Add more dummy users here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenType == 'followers' ? 'Followers' : 'Following'),
      ),
      body: ListView.builder(
        itemCount: dummyUsers.length,
        itemBuilder: (context, index) {
          final user = dummyUsers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(user['avatarUrl']!),
            ),
            title: Text(user['username']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersProfileScreen(
                    username: user['username']!,
                    avatarUrl: user['avatarUrl']!,
                    postCount: 10, // Placeholder value
                    followerCount: 100, // Placeholder value
                    followingCount: 50, // Placeholder value
                    isFollowing: false, // Placeholder value
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
