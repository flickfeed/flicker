import 'package:flutter/material.dart';
import 'package:flickfeedpro/data/dummy_data.dart';
import 'package:flickfeedpro/models/posts.dart';
import 'package:flickfeedpro/models/story.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FLICKFEED',
          style: TextStyle(
            fontFamily: 'Lobster',
            fontSize: 32,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dummyStories.length + 1, // +1 for "Your Story"
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildYourStory(context);
                }
                final story = dummyStories[index - 1]; // Adjust for "Your Story"
                return _buildStoryAvatar(story);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dummyPosts.length,
              itemBuilder: (context, index) {
                final post = dummyPosts[index];
                return PostItem(post: post);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourStory(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 25, // Reduced the radius to avoid overflow
                backgroundImage: AssetImage('assets/images/your_avatar.jpg'), // Your avatar image
              ),
              CircleAvatar(
                radius: 8, // Reduced the radius to avoid overflow
                backgroundColor: Colors.blue,
                child: Icon(Icons.add, size: 12, color: Colors.white), // Adjusted icon size
              ),
            ],
          ),
          SizedBox(height: 5),
          Text('Your Story', style: TextStyle(fontSize: 12)), // Adjusted text size
        ],
      ),
    );
  }

  Widget _buildStoryAvatar(Story story) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25, // Reduced the radius to avoid overflow
            backgroundImage: AssetImage(story.imageUrl), // Story avatar image
          ),
          SizedBox(height: 5),
          Text(story.username, style: TextStyle(fontSize: 12)), // Adjusted text size
        ],
      ),
    );
  }
}

class PostItem extends StatelessWidget {
  final Post post;

  PostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(post.avatarUrl), // Use avatar URL
            ),
            title: Text(post.username),
            subtitle: Text('2 hours ago'),
          ),
          Container(
            height: 300, // Set a fixed height for the image container
            width: double.infinity, // Make sure the container takes full width
            child: AspectRatio(
              aspectRatio: 1, // 1:1 aspect ratio for square image
              child: Image.asset(post.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                SizedBox(width: 10.0),
                Text('${post.likes} likes'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              post.caption,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
