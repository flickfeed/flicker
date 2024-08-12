import 'package:flutter/material.dart';
import 'userslistscreen.dart';

class UsersProfileScreen extends StatelessWidget {
  final String username;
  final String name;
  final String avatarUrl;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final String bio;
  final bool isFollowing;
  final List<String> mutualFollowers; // Add this line

  UsersProfileScreen({
    required this.username,
    required this.name,
    required this.avatarUrl,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.bio,
    required this.isFollowing,
    required this.mutualFollowers, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
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
            Text(
              name, // Display the name
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text(
              bio, // Display the bio
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCountColumn('Posts', postCount),
                _buildCountColumn('Followers', followerCount, context, 'followers'),
                _buildCountColumn('Following', followingCount, context, 'following'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle follow/unfollow functionality
              },
              child: Text(isFollowing ? 'Following' : 'Follow'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[300] : Theme.of(context).primaryColor, // Fixed the primary parameter issue
              ),
            ),
            SizedBox(height: 20),
            _buildPostsGrid(), // Display user posts grid
          ],
        ),
      ),
    );
  }

  Widget _buildCountColumn(String label, int count, [BuildContext? context, String? screenType]) {
    return GestureDetector(
      onTap: () {
        if (context != null && screenType != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UsersListScreen(
                username: username,
                screenType: screenType,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: postCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          color: Colors.grey[300], // Placeholder for post image
        );
      },
    );
  }
}
