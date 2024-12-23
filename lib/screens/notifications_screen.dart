import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client; // Supabase instance
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _getNotifications('currentUserId'); // Replace with actual user ID
  }

  // Fetch notifications from Supabase for a specific user
  Future<List<Map<String, dynamic>>> _getNotifications(String userId) async {
    try {
      final response = await supabase
          .from('notifications') // Replace with your notifications table in Supabase
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      if (response != null) {
        return List<Map<String, dynamic>>.from(response as List);
      } else {
        print('Failed to fetch notifications: Response is null.');
        return [];
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications.'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(notification['profilePicUrl'] ?? ''),
                ),
                title: _buildNotificationText(notification),
                subtitle: Text(_formatTime(notification['timestamp'])),
                trailing: _buildNotificationTrailing(notification),
              );
            },
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
                text: notification['username'] ?? 'Unknown',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: ' liked your post.',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        );
    // Handle other notification types (comment, follow, mention)
      default:
        return Text('Unknown notification type.');
    }
  }

  // Format timestamp
  String _formatTime(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      Duration difference = DateTime.now().difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else {
        return '${difference.inDays}d';
      }
    } catch (e) {
      print('Error formatting time: $e');
      return 'Unknown time';
    }
  }

  Widget? _buildNotificationTrailing(Map<String, dynamic> notification) {
    if (notification['type'] == 'mention' && notification['postPicUrl'] != null) {
      return Image.network(notification['postPicUrl'], width: 50, height: 50);
    }
    return null;
  }
}
