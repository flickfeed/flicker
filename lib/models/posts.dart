import 'package:supabase_flutter/supabase_flutter.dart';
import 'comment.dart';

class Post {
  final String username;
  final String avatarUrl;
  final String imageUrl;
  final String caption;
  int likes;
  final List<Comment> comments;
  final String location;
  bool isHidden;
  List<String> likedUsers;
  final DateTime timestamp;
  String? postId; // Optional postId field to identify posts

  Post({
    required this.username,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
    this.likes = 0,
    this.comments = const [],
    this.location = '',
    this.isHidden = false,
    this.likedUsers = const [],
    required this.timestamp,
    this.postId,
  });

  // Factory constructor to create a Post instance from Supabase data
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      username: map['username'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      imageUrl: map['image_url'] ?? '',
      caption: map['caption'] ?? '',
      likes: map['likes'] ?? 0,
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((comment) => Comment.fromMap(comment))
          .toList(),
      location: map['location'] ?? '',
      isHidden: map['is_hidden'] ?? false,
      likedUsers: List<String>.from(map['liked_users'] ?? []),
      timestamp: DateTime.parse(map['timestamp']),
      postId: map['id'], // Assign the ID from the Supabase record
    );
  }

  // Converts Post instance to a Map to be stored in Supabase
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'avatar_url': avatarUrl,
      'image_url': imageUrl,
      'caption': caption,
      'likes': likes,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'location': location,
      'is_hidden': isHidden,
      'liked_users': likedUsers,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Method to toggle like/unlike functionality for the current user in Supabase
  Future<void> toggleLike(String userId) async {
    try {
      if (likedUsers.contains(userId)) {
        likedUsers.remove(userId);
        likes--;
      } else {
        likedUsers.add(userId);
        likes++;
      }

      // Update the post data in Supabase
      final response = await Supabase.instance.client
          .from('posts')
          .upsert({
        'id': postId, // Update the post using its ID
        'likes': likes,
        'liked_users': likedUsers,
      })
          .eq('id', postId)
          .execute();

      if (response.error != null) {
        print('Error toggling like: ${response.error?.message}');
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  // Adds a new post to Supabase using the toMap method
  Future<void> addPost() async {
    try {
      final response = await Supabase.instance.client
          .from('posts')
          .insert([toMap()])
          .execute();

      if (response.error == null) {
        postId = response.data[0]['id']; // Set postId to the new record's ID
      } else {
        print('Error adding post: ${response.error?.message}');
      }
    } catch (e) {
      print('Failed to add post: $e');
    }
  }
}
