import 'package:flickfeedpro/models/comment.dart';

class Post {
  final String imageUrl;
  final String username;
  final String caption;
  int likes;
  final String avatarUrl;
  final List<Comment> comments;

  Post({
    required this.imageUrl,
    required this.username,
    required this.caption,
    required this.likes,
    required this.avatarUrl,
    required this.comments,
  });
}
