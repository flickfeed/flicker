import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'feed_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  File? _selectedImage;

  void _onTabTapped(int index) {
    if (index == 2) {
      _showNewPostModal();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<Map<String, dynamic>?> _getUserDetails(String userId) async {
    final response = await Supabase.instance.client
        .from('userdetails')
        .select('*')
        .eq('id', userId)
        .single();

    if (response.error != null) {
      print('Error fetching user details: ${response.error!.message}');
      return null;
    }

    return response.data;
  }

  Future<void> _selectImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      final result = await _showPostDetailsDialog();
      if (result != null) {
        final caption = result['caption'] ?? '';
        final location = result['location'] ?? '';
        if (caption.isNotEmpty || location.isNotEmpty) {
          _uploadImage(_selectedImage!, caption, location);
        }
      }
    }
  }

  Future<Map<String, String>?> _showPostDetailsDialog() async {
    String caption = '';
    String location = '';
    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Post Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Caption'),
                onChanged: (value) => caption = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Location'),
                onChanged: (value) => location = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({'caption': caption, 'location': location});
              },
              child: Text('Upload Post'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImage(File imageFile, String caption, String location) async {
    try {
      final fileName = path.basename(imageFile.path);
      final byteData = await imageFile.readAsBytes();

      final storageResponse = await Supabase.instance.client.storage
          .from('posts')
          .uploadBinary('posts/$fileName', byteData);

      if (storageResponse.error != null) {
        throw Exception('Failed to upload image: ${storageResponse.error!.message}');
      }

      final imageUrl = Supabase.instance.client.storage
          .from('posts')
          .getPublicUrl('posts/$fileName');

      await _createPost(imageUrl, caption, location);
    } catch (e) {
      print('Failed to upload image: $e');
    }
  }

  Future<void> _createPost(String imageUrl, String caption, String location) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'defaultUserId';
      final userDetails = await _getUserDetails(userId);

      if (userDetails == null) {
        throw Exception('User details not found.');
      }

      final post = {
        'username': userDetails['username'],
        'avatar_url': userDetails['avatar_url'] ?? 'defaultAvatarUrl',
        'image_url': imageUrl,
        'caption': caption,
        'likes': 0,
        'comments': [],
        'location': location,
        'is_hidden': false,
        'liked_users': [],
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await Supabase.instance.client
          .from('posts')
          .insert(post);

      if (response.error != null) {
        throw Exception('Failed to create post: ${response.error!.message}');
      }

      setState(() {
        _selectedImage = null; // Reset the image after posting
      });
    } catch (e) {
      print('Failed to create post: $e');
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
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 150, width: 150, fit: BoxFit.cover),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Select from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'defaultUserId';

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          FeedScreen(),
          SearchScreen(),
          Container(), // Placeholder for the New Post screen
          NotificationsScreen(), // Add NotificationsScreen here
          ProfileScreen(),
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
            icon: Icon(Icons.add_circle_outline, size: 30, color: Colors.black),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.notifications_outline),  // Notification icon
            activeIcon: Icon(Ionicons.notifications),
            label: 'Notifications',
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
