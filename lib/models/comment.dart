class Comment {
  final String username;
  final String avatarUrl;
  final String text;
  final DateTime timestamp;
  int likes;
  bool isLiked;
  bool isReplying;
  List<Comment> replies;

  Comment({
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
    this.isReplying = false,
    List<Comment>? replies,
  }) : replies = replies ?? [];
}
