import 'package:supabase_flutter/supabase_flutter.dart';

class Comment {
  final String id;
  final String userId;
  final String postId;
  final String text;
  final DateTime createdAt;
  int likes;
  List<String> likedUsers;
  final String username;
  final String? avatarUrl;
  final String? parentId;
  final List<Comment> replies;
  int replyCount;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.text,
    required this.createdAt,
    required this.likes,
    required this.likedUsers,
    required this.username,
    this.avatarUrl,
    this.parentId,
    List<Comment>? replies,
    this.replyCount = 0,
  }) : replies = replies ?? [];

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id']?.toString() ?? '',
      postId: map['post_id']?.toString() ?? '',
      userId: map['user_id'] ?? '',
      parentId: map['parent_id']?.toString(),
      username: map['username'] ?? '',
      avatarUrl: map['avatar_url'],
      text: map['text'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      likes: map['likes']?.toInt() ?? 0,
      likedUsers: List<String>.from(map['liked_users'] ?? []),
      replyCount: map['reply_count']?.toInt() ?? 0,
    );
  }

  bool get isLiked => likedUsers.contains(Supabase.instance.client.auth.currentUser?.id);
}
