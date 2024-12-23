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
  String? postId;

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

  // Factory constructor for Supabase data
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      username: map['username'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      imageUrl: map['image_url'] ?? '',  // No URL logic here
      caption: map['caption'] ?? '',
      likes: map['likes'] ?? 0,
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((comment) => Comment.fromMap(comment))
          .toList(),
      location: map['location'] ?? '',
      isHidden: map['is_hidden'] ?? false,
      likedUsers: List<String>.from(map['liked_users'] ?? []),
      timestamp: DateTime.parse(map['timestamp']),
      postId: map['id'],
    );
  }

  // Converts Post to a Map
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

  // Like/unlike functionality
  Future<void> toggleLike(String userId) async {
    try {
      if (likedUsers.contains(userId)) {
        likedUsers.remove(userId);
        likes--;
      } else {
        likedUsers.add(userId);
        likes++;
      }

      // Update the post in Supabase
      final response = await Supabase.instance.client
          .from('posts')
          .update({
        'likes': likes,
        'liked_users': likedUsers,
      })
          .eq('id', postId)
          .execute();

      if (response.status == 200) {
        print('Like toggled successfully');
      } else {
        print('Failed to toggle like: ${response.status}');
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  // Adds a new post to Supabase
  Future<void> addPost() async {
    try {
      final response = await Supabase.instance.client
          .from('posts')
          .insert([toMap()])
          .execute();

      if (response.status == 200 && response.data != null) {
        postId = response.data[0]['id']; // Assign the new post's ID
        print('Post added successfully');
      } else {
        print('Failed to add post: ${response.status}');
      }
    } catch (e) {
      print('Failed to add post: $e');
    }
  }
}
