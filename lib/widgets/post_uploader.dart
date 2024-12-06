import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostUploader {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String userId;
  final String username;
  final String avatarUrl;

  PostUploader({required this.userId, required this.username, required this.avatarUrl});

  Future<void> createPost(String caption) async {
    try {
      // Pick an image from the gallery
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        final imageFile = File(pickedImage.path);

        // Upload image to Supabase storage
        final fileName = DateTime.now().toString();
        final storageRef = _supabase.storage.from('post_images');
        final filePath = 'postImages/$fileName';
        final uploadResponse = await storageRef.upload(filePath, imageFile);

        if (uploadResponse.error != null) {
          print('Failed to upload image: ${uploadResponse.error?.message}');
          return;
        }

        // Get the URL of the uploaded image
        final imageUrl = await storageRef.getPublicUrl(filePath);

        // Insert post data into Supabase database
        final postResponse = await _supabase
            .from('posts')
            .insert({
          'user_id': userId,
          'username': username,
          'avatar_url': avatarUrl,
          'image_url': imageUrl,
          'caption': caption,
          'timestamp': DateTime.now().toIso8601String(),
          'likes': 0,
          'liked_users': [],
          'comments': [],
        })
            .execute();

        if (postResponse.error != null) {
          print('Failed to create post: ${postResponse.error?.message}');
        }
      }
    } catch (e) {
      print('Failed to create post: $e');
    }
  }
}
