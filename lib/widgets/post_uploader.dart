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
      // Check if the user is authenticated
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('User is not authenticated');
        return;
      }

      // Pick an image from the gallery
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage == null) {
        print('No image selected');
        return;
      }

      final imageFile = File(pickedImage.path);

      // Generate a unique file name for the uploaded image
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'posts/$fileName';  // Updated path to 'posts'

      // Reference the correct bucket in Supabase storage
      final storageRef = _supabase.storage.from('images'); // Ensure the bucket is named 'images'

      try {
        // Upload image to Supabase storage
        final uploadResponse = await storageRef.upload(filePath, imageFile);
        print('File uploaded successfully');

        // Get the public URL of the uploaded image
        final imageUrl = storageRef.getPublicUrl(filePath);
        print('Image public URL: $imageUrl');

        // Insert post data into Supabase database
        final postResponse = await _supabase
            .from('posts')
            .insert({
          'user_id': user.id,
          'username': username,
          'avatar_url': avatarUrl,
          'image_url': imageUrl,  // Store the image URL in the database
          'caption': caption,
          'timestamp': DateTime.now().toIso8601String(),
          'likes': 0,
          'liked_users': [],
          'comments': [],
        })
            .select();

        // Check for successful insertion
        if (postResponse is List && postResponse.isNotEmpty) {
          print('Post created successfully!');
        } else {
          print('Failed to create post. Response: $postResponse');
        }
      } catch (error) {
        print('Upload Error: $error');
      }
    } catch (e) {
      print('Failed to create post: $e');
    }
  }
  }
