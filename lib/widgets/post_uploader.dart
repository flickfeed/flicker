import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostUploader extends StatefulWidget {
  final String userId;
  final String username;
  final String avatarUrl;

  const PostUploader({
    Key? key,
    required this.userId,
    required this.username,
    required this.avatarUrl,
  }) : super(key: key);

  @override
  State<PostUploader> createState() => _PostUploaderState();
}

class _PostUploaderState extends State<PostUploader> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _captionController,
            decoration: InputDecoration(
              labelText: 'Caption',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              try {
                await createPost(
                  _captionController.text,
                  location: _locationController.text,
                );
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create post: $e')),
                  );
                }
              }
            },
            child: Text('Create Post'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> createPost(String caption, {String? location}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Pick an image from the gallery
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return;

      final imageFile = File(pickedImage.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'posts/$fileName';

      // Upload image to Supabase Storage
      await _supabase.storage
          .from('images')
          .upload(filePath, imageFile);

      // Get the public URL
      final imageUrl = _supabase.storage
          .from('images')
          .getPublicUrl(filePath);

      // Create the post
      await _supabase
          .from('posts')
          .insert({
            'user_id': userId,
            'image_url': imageUrl,
            'caption': caption,
            'location': location ?? '',
            'created_at': DateTime.now().toIso8601String(),
            'likes': 0,
            'liked_users': [],
            'comments': []
          });

    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }
}
