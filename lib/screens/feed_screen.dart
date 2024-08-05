import 'package:flutter/material.dart';
import 'package:flickfeedpro/data/dummystories.dart';
import 'package:flickfeedpro/data/dummy_data.dart'; // Ensure this points to the correct path
import 'package:flickfeedpro/models/story.dart';
import 'package:flickfeedpro/widgets/postwidgets.dart'; // Ensure this points to the correct path

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(
              'FLICKFEED',
              style: TextStyle(
                fontFamily: 'Lobster',
                fontSize: 32,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              height: 120, // Increased height to avoid overflow
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
          ),
          SliverToBoxAdapter(
            child: Divider(height: 1.0, color: Colors.grey[300]),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final post = dummyPosts[index];
                return PostWidget(post: post);
              },
              childCount: dummyPosts.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourStory(BuildContext context) {
    return Container(
      width: 70, // Adjust the width as needed
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/your_avatar.jpg'),
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.blue,
                child: Icon(Icons.add, size: 15, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 5),
          Expanded(
            child: Text(
              'Your Story',
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis, // Ensure text does not overflow
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryAvatar(Story story) {
    return Container(
      width: 70, // Adjust the width as needed
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(story.imageUrl),
          ),
          SizedBox(height: 5),
          Expanded(
            child: Text(
              story.username,
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis, // Ensure text does not overflow
            ),
          ),
        ],
      ),
    );
  }
}
