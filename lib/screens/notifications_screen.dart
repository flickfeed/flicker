import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'like',
      'username': '@user1',
      'profilePicUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      'time': '2h',
    },
    {
      'type': 'comment',
      'username': '@user2',
      'profilePicUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
      'time': '3h',
      'comment': 'Great post!',
    },
    {
      'type': 'follow',
      'username': '@user3',
      'profilePicUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
      'time': '5h',
    },
    {
      'type': 'mention',
      'username': '@user4',
      'profilePicUrl': 'https://randomuser.me/api/portraits/women/4.jpg',
      'time': '1d',
      'postPicUrl': 'https://via.placeholder.com/150',
    },
    // Add more notifications here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(notification['profilePicUrl']),
            ),
            title: _buildNotificationText(notification),
            subtitle: Text(notification['time']),
            trailing: _buildNotificationTrailing(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationText(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'like':
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: notification['username'],
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: ' liked your post.',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        );
      case 'comment':
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: notification['username'],
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: ' commented: ',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: notification['comment'],
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        );
      case 'follow':
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: notification['username'],
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: ' started following you.',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        );
      case 'mention':
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: notification['username'],
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: ' mentioned you in a comment.',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        );
      default:
        return Text('Unknown notification type.');
    }
  }

  Widget? _buildNotificationTrailing(Map<String, dynamic> notification) {
    if (notification['type'] == 'mention') {
      return Image.network(notification['postPicUrl'], width: 50, height: 50);
    }
    return null;
  }
}
