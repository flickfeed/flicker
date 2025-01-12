import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class LikesScreen extends StatelessWidget {
  final List<String> likedUsers;

  const LikesScreen({super.key, required this.likedUsers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,  // Center the title
        title: Column(
          children: [
            Text(
              'Likes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 4),  // Add some space between the title and the likes count
            Row(
              mainAxisSize: MainAxisSize.min,  // Center align the content
              children: [
                Icon(
                  Ionicons.heart,  // Heart icon
                  color: Colors.red,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  '${likedUsers.length}',  // Display the number of likes
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Ionicons.search_outline),
            onPressed: () {
              // Handle search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: likedUsers.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/default_avatar.png'),
            ),
            title: Text(likedUsers[index]),
            onTap: () {

            },
          );
        },
      ),
    );
  }
}
