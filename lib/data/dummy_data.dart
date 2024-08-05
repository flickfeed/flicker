import 'package:flickfeedpro/models/posts.dart';
import 'package:flickfeedpro/models/comment.dart';

List<Post> dummyPosts = [
  Post(
    imageUrl: 'assets/images/post1.jpg',
    username: 'ANARGH',
    caption: 'Great game!',
    likes: 12000,
    avatarUrl: 'assets/images/avatar1.jpg',
    comments: [
      Comment(
        username: 'user1',
        avatarUrl: 'assets/images/avatar2.jpg',
        text: 'Amazing!',
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
      ),
      Comment(
        username: 'user2',
        avatarUrl: 'assets/images/avatar3.jpg',
        text: 'Looks fun!',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
      ),
    ],
  ),
  Post(
    imageUrl: 'assets/images/post2.jpg',
    username: 'PRATHYUSH',
    caption: 'I love this!',
    likes: 15000,
    avatarUrl: 'assets/images/avatar2.jpg',
    comments: [
      Comment(
        username: 'user3',
        avatarUrl: 'assets/images/avatar4.jpg',
        text: 'Nice shot!',
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      ),
    ],
  ),
];
