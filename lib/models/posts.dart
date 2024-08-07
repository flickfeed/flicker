import 'comment.dart';  // Import Comment class

class Post {
  final String username;
  final String avatarUrl;
  final String imageUrl;
  final String caption;
  int likes;
  final List<Comment> comments;
  final String location;

  Post({
    required this.username,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
    this.likes = 0,
    this.comments = const [],
    this.location = '',
  });

  void toggleLike(bool isLiked) {
    if (isLiked) {
      likes++;
    } else {
      likes--;
    }
  }
}
