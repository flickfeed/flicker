import 'package:flutter/material.dart';
import 'EditProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String profileName = 'Anargh M';
  String username = 'anarghm_';
  String website = 'Video creator';
  String bio = 'I lifts 🤡';
  String profileImageUrl = 'https://example.com/profile_picture.jpg';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          name: profileName,
          username: username,
          website: website,
          bio: bio,
          imageUrl: profileImageUrl,
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        profileName = result['name']!;
        username = result['username']!;
        website = result['website']!;
        bio = result['bio']!;
        profileImageUrl = result['imageUrl']!;
      });
    }
  }

  void _addNewHighlight() {
    // Implement adding a new highlight
  }

  void _addNewStory() {
    // Implement adding a new story
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(profileImageUrl),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _addNewStory,
                            child: Icon(
                              Icons.add_circle,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('Posts', 5),
                              _buildStatColumn('Followers', 607),
                              _buildStatColumn('Following', 430),
                            ],
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _navigateToEditProfile(context),
                            child: Text('Edit Profile'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildProfileInfo(),
                SizedBox(height: 16),
                Divider(),
                _buildHighlightsSection(),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.grid_on)),
              Tab(icon: Icon(Icons.video_library)),
              Tab(icon: Icon(Icons.person_pin)),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsGrid(),
                _buildReelsSection(),
                _buildTaggedSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profileName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(username),
        SizedBox(height: 4),
        Text(website),
        SizedBox(height: 4),
        Text(bio),
      ],
    );
  }

  Widget _buildHighlightsSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.add, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _addNewHighlight,
                      child: Icon(
                        Icons.add_circle,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text('New'),
            ],
          ),
          _buildHighlight('2024'),
        ],
      ),
    );
  }

  Widget _buildHighlight(String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(
              'https://example.com/highlight_image.jpg'),
        ),
        SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 posts per row
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[300],
          child: Image.network(
            'https://example.com/post_image.jpg',
            fit: BoxFit.cover,
          ),
        );
      },
      itemCount: 6,
    );
  }

  Widget _buildReelsSection() {
    // Replace with your Reels content
    return Center(child: Text('Reels Section'));
  }

  Widget _buildTaggedSection() {
    // Replace with your Tagged content
    return Center(child: Text('Tagged Section'));
  }
}
