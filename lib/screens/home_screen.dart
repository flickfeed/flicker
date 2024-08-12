import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'feed_screen.dart';
import 'search_screen.dart';
import 'reels_screen.dart';
import 'profile_screen.dart';
import 'messagingscreen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    FeedScreen(),
    SearchScreen(),
    Container(), // Placeholder for the New Post screen
    ReelsScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      _showNewPostModal();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showNewPostModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Select from gallery'),
                onTap: () {
                  // Handle select from gallery
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  // Handle take a photo
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToMessaging() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessagingScreen()));
  }

  void _navigateToNotifications() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          if (_currentIndex == 0) // Show AppBar only on home screen
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Align icons to the right
                  children: [
                    IconButton(
                      icon: Icon(Ionicons.heart_outline, color: Colors.black),
                      onPressed: _navigateToNotifications,
                    ),
                    IconButton(
                      icon: Icon(Ionicons.paper_plane_outline, color: Colors.black),
                      onPressed: _navigateToMessaging,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.home_outline),
            activeIcon: Icon(Ionicons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.search_outline),
            activeIcon: Icon(Ionicons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Container(
              margin: EdgeInsets.only(top: 8.0),
              child: Icon(Icons.add_circle_outline, size: 30, color: Colors.black),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.videocam_outline),
            activeIcon: Icon(Ionicons.videocam),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person_outline),
            activeIcon: Icon(Ionicons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

