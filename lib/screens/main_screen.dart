import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';
import 'feed_screen.dart';
import 'package:flickfeedpro/screens/sharepostscreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    FeedScreen(), // Provide required parameters if needed
    SearchScreen(),
    ActivityScreen(),
    ProfileScreen(), // Replace with actual userId
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleNewPost() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SharePostScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _handleNewPost,
        child: Icon(Ionicons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
            icon: SizedBox.shrink(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.notifications_outline),
            activeIcon: Icon(Ionicons.notifications),
            label: 'Activity',
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
