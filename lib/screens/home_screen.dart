import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'feed_screen.dart';
import 'search_screen.dart';
import 'reels_screen.dart';
import 'profile_screen.dart';
import 'messagingscreen.dart';
import 'notifications_screen.dart'; // Keep this import for the AppBar navigation

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    FeedScreen(),
    SearchScreen(),
    ReelsScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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