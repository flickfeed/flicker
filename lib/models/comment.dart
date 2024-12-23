import 'package:supabase_flutter/supabase_flutter.dart';

class Comment {
  final String username;
  final String avatarUrl;
  final String text;
  final DateTime timestamp;
  int likes;
  bool isLiked;
  bool isReplying;
  List<Comment> replies;
  bool areRepliesVisible;
  String? commentId; // The unique identifier for the comment

  Comment({
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
    this.isReplying = false,
    List<Comment>? replies,
    this.areRepliesVisible = false,
    this.commentId,
  }) : replies = replies ?? [];

  // Factory constructor to create a Comment from a map (Supabase data)
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      username: map['username'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      likes: map['likes'] ?? 0,
      isLiked: map['is_liked'] ?? false,
      isReplying: map['is_replying'] ?? false,
      replies: (map['replies'] as List<dynamic>? ?? [])
          .map((reply) => Comment.fromMap(reply))
          .toList(),
      areRepliesVisible: map['are_replies_visible'] ?? false,
      commentId: map['id'], // The comment's unique ID
    );
  }

  // Method to convert a Comment object to a map (for saving to Supabase)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'avatar_url': avatarUrl,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'is_liked': isLiked,
      'is_replying': isReplying,
      'are_replies_visible': areRepliesVisible,
      // Don't store replies directly here as they are handled in a separate table
    };
  }

  // Future method to add a comment to Supabase
  Future<void> addComment(String postId) async {
    try {
      final response = await Supabase.instance.client
          .from('comments')
          .insert({
        'username': username,
        'avatar_url': avatarUrl,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'likes': likes,
        'is_liked': isLiked,
        'is_replying': isReplying,
        'post_id': postId,
        'are_replies_visible': areRepliesVisible,
      })
          .execute();

      // No error check; only check if data is returned
      if (response.data != null) {
        print('Comment added successfully');
      } else {
        print('Failed to add comment: ${response.status}');
      }
    } catch (e) {
      print('Failed to add comment: $e');
    }
  }

  // Future method to retrieve comments for a specific post from Supabase
  static Future<List<Comment>> getComments(String postId) async {
    try {
      final response = await Supabase.instance.client
          .from('comments')
          .select('*')
          .eq('post_id', postId)
          .order('timestamp', ascending: false)
          .execute();

      // Directly check the response status
      if (response.status == 200 && response.data != null) {
        return List<Comment>.from(response.data
            .map<Comment>((data) => Comment.fromMap(data)));
      } else {
        print('No comments found or failed to fetch comments');
        return [];
      }
    } catch (e) {
      print('Failed to get comments: $e');
      return [];
    }
  }

  // Future method to delete a comment from Supabase
  Future<void> deleteComment() async {
    if (commentId == null) {
      print('Comment ID is null');
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('comments')
          .delete()
          .eq('id', commentId)
          .execute();

      // Directly check if the deletion was successful
      if (response.status == 200) {
        print('Comment deleted successfully');
      } else {
        print('Failed to delete comment: ${response.status}');
      }
    } catch (e) {
      print('Failed to delete comment: $e');
    }
  }

  // Future method to update a comment's like status
  Future<void> toggleLike(String userId) async {
    try {
      isLiked = !isLiked;
      if (isLiked) {
        likes++;
      } else {
        likes--;
      }

      final response = await Supabase.instance.client
          .from('comments')
          .update({'likes': likes, 'is_liked': isLiked})
          .eq('id', commentId)
          .execute();

      // Check if like update was successful based on status
      if (response.status == 200) {
        print('Comment like status updated successfully');
      } else {
        print('Failed to toggle like: ${response.status}');
      }
    } catch (e) {
      print('Failed to toggle like: $e');
    }
  }
}
