import 'package:supabase_flutter/supabase_flutter.dart';

class Post {
  final String postId;
  final String userId;
  final String imageUrl;
  final String caption;
  final String? location;
  final DateTime createdAt;
  int likes;
  List<String> likedUsers;
  final String username;
  final String? avatarUrl;
  int commentCount;

  Post({
    required this.postId,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    this.location,
    required this.createdAt,
    required this.likes,
    required this.likedUsers,
    required this.username,
    this.avatarUrl,
    this.commentCount = 0,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      imageUrl: map['image_url'] ?? '',
      caption: map['caption'] ?? '',
      location: map['location'],
      createdAt: DateTime.parse(map['created_at']),
      likes: map['likes'] ?? 0,
      likedUsers: List<String>.from(map['liked_users'] ?? []),
      username: map['username'] ?? '',
      avatarUrl: map['avatar_url'],
      commentCount: map['comment_count'] ?? 0,
    );
  }

  bool get isLiked => likedUsers.contains(Supabase.instance.client.auth.currentUser?.id);

  Future<void> toggleLike(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      
      if (likedUsers.contains(userId)) {
        likedUsers.remove(userId);
        likes--;
      } else {
        likedUsers.add(userId);
        likes++;
      }

      await supabase
          .from('posts')
          .update({
            'likes': likes,
            'liked_users': likedUsers,
          })
          .eq('id', postId);

    } catch (e) {
      print('Error updating like: $e');
      // Revert on error
      if (likedUsers.contains(userId)) {
        likedUsers.remove(userId);
        likes--;
      } else {
        likedUsers.add(userId);
        likes++;
      }
      throw e;
    }
  }

  Future<void> updateCommentCount(int newCount) async {
    try {
      await Supabase.instance.client
          .from('posts')
          .update({'comment_count': newCount})
          .eq('id', postId);
      
      commentCount = newCount;  // Update local state after successful DB update
    } catch (e) {
      print('Error updating comment count: $e');
      throw e;  // Rethrow to handle in UI
    }
  }
}
