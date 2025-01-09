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

  Future<void> createPost(String caption, {String? location}) async {
    try {
      // Pick an image from the gallery
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage == null) {
        print('No image selected');
        return;
      }

      final imageFile = File(pickedImage.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'posts/$fileName';

      print('Attempting to upload image to path: $filePath');

      // Upload image to Supabase Storage
      try {
        // Make sure 'images' bucket exists in your Supabase storage
        await _supabase.storage
            .from('images')
            .upload(filePath, imageFile, fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ));

        // Get the public URL
        final imageUrl = _supabase.storage
            .from('images')
            .getPublicUrl(filePath);

        print('Image uploaded successfully. URL: $imageUrl');

        // Create the post
        final response = await _supabase
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
              'location': location ?? '',
            })
            .select()
            .single();

        print('Post created successfully with data: $response');
      } catch (e) {
        print('Storage error: $e');
        throw e;
      }
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }
}
