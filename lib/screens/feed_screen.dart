import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flickfeedpro/data/dummystories.dart';
import 'package:flickfeedpro/data/dummy_data.dart';
import 'package:flickfeedpro/models/story.dart';
import 'package:flickfeedpro/widgets/postwidgets.dart';
import 'package:flutter/rendering.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  ScrollController _scrollController = ScrollController();
  bool _showIcons = true;
  double _iconOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // Check the direction of the scroll
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_showIcons) {
          setState(() {
            _iconOpacity = 0.0; // Fade out the icons
            _showIcons = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_showIcons) {
          setState(() {
            _iconOpacity = 1.0; // Fade in the icons
            _showIcons = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
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
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dummyStories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildYourStory(context);
                      }
                      final story = dummyStories[index - 1];
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _iconOpacity,
              duration: Duration(milliseconds: 300),
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Ionicons.heart_outline, color: Colors.black),
                      onPressed: () {
                        // Navigate to notifications screen
                      },
                    ),
                    IconButton(
                      icon: Icon(Ionicons.paper_plane_outline, color: Colors.black),
                      onPressed: () {
                        // Navigate to messaging screen
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourStory(BuildContext context) {
    return Container(
      width: 70,
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryAvatar(Story story) {
    return Container(
      width: 70,
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
