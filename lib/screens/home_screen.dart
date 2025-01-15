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
import '../widgets/upload_progress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  File? _selectedImage;
  final FeedScreen _feedScreen = FeedScreen();

  void _onTabTapped(int index) {
    if (index == 2) {
      _showNewPostModal();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
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
      // Show initial upload progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return UploadProgressDialog(
            progress: 0,
            status: 'Preparing upload...',
          );
        },
      );

      print('Starting image upload...');
      final fileName = path.basename(imageFile.path);
      final byteData = await imageFile.readAsBytes();

      // Update progress for file upload
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return UploadProgressDialog(
              progress: 0.3,
              status: 'Uploading image...',
            );
          },
        );
      }

      final filePath = await Supabase.instance.client.storage
          .from('images')
          .uploadBinary('posts/$fileName', byteData);

      // Example usage
      print('File uploaded to: $filePath');

      // Update progress for post creation
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return UploadProgressDialog(
              progress: 0.6,
              status: 'Creating post...',
            );
          },
        );
      }

      final imageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl('posts/$fileName');

      await _createPost(imageUrl, caption, location);

      // Show success dialog
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                    SizedBox(height: 20),
                    Text(
                      'Post uploaded successfully!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // Auto dismiss success dialog after 1.5 seconds
        Future.delayed(Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop();
            setState(() {
              _selectedImage = null;
              _currentIndex = 0; // Switch to feed tab
            });
            FeedScreen.refreshFeed(); // Refresh the feed
          }
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Upload Failed'),
              content: Text('Failed to upload image: $e'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
      print('Failed to upload image: $e');
    }
  }

  Future<void> _createPost(String imageUrl, String caption, String location) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Get current timestamp in UTC
      final now = DateTime.now().toUtc();
      
      await Supabase.instance.client
          .from('posts')
          .insert({
            'user_id': userId,
            'image_url': imageUrl,
            'caption': caption,
            'location': location,
            'created_at': now.toIso8601String(), // Store UTC timestamp
            'likes': 0,
            'liked_users': [],
          });

      if (mounted) {
        setState(() {
          _selectedImage = null;
          _currentIndex = 0;
        });
        // Refresh feed and profile
        FeedScreen.refreshFeed();
        _refreshAllScreens();
      }
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  void _refreshAllScreens() {
    // Refresh user profile if it's open
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pushReplacementNamed(
        '/user-profile',
        arguments: Supabase.instance.client.auth.currentUser?.id,
      );
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _feedScreen,
          SearchScreen(),
          Container(),
          NotificationsScreen(),
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
            icon: Icon(Ionicons.add_circle_outline, size: 30),
            activeIcon: Icon(Ionicons.add_circle, size: 30),
            label: 'Post',
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
