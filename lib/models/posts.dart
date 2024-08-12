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
  final List<String> likedUsers; // Add this property

  Post({
    required this.username,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
    this.likes = 0,
    this.comments = const [],
    this.location = '',
    this.isHidden = false,
    this.likedUsers = const [], // Initialize with an empty list
  });

  void toggleLike(bool isLiked) {
    if (isLiked) {
      likes++;
    } else {
      likes--;
    }
  }
}

