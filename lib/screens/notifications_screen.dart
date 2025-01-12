import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/date_formatter.dart';
import 'user_profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('notifications')
          .select('sender:users(id, username)')
          .eq('recipient_id', userId);

      setState(() {
        _notifications = response;
        _isLoading = false;
      });

      // Mark notifications as read
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', userId)
          .eq('is_read', false);

    } catch (e) {
      print('Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      String message = '';
                      IconData icon;
                      Color iconColor;

                      switch (notification['type']) {
                        case 'like':
                          message = 'liked your post';
                          icon = Icons.favorite;
                          iconColor = Colors.red;
                          break;
                        case 'comment':
                          message = 'commented: ${notification['content']}';
                          icon = Icons.comment;
                          iconColor = Colors.blue;
                          break;
                        case 'follow':
                          message = 'started following you';
                          icon = Icons.person;
                          iconColor = Colors.green;
                          break;
                        default:
                          message = notification['content'];
                          icon = Icons.notifications;
                          iconColor = Colors.grey;
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: notification['sender']['avatar_url'] != null
                              ? NetworkImage(notification['sender']['avatar_url'])
                              : null,
                          child: notification['sender']['avatar_url'] == null
                              ? Icon(Icons.person)
                              : null,
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: notification['sender']['username'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' $message'),
                            ],
                          ),
                        ),
                        subtitle: Text(
                          DateFormatter.formatTimestamp(
                            DateTime.parse(notification['created_at']),
                          ),
                        ),
                        trailing: Icon(icon, color: iconColor),
                        onTap: () {
                          // Navigate based on notification type
                          switch (notification['type']) {
                            case 'like':
                            case 'comment':
                              if (notification['post_id'] != null) {
                                Navigator.pushNamed(
                                  context,
                                  '/post-detail',
                                  arguments: notification['post_id'],
                                );
                              }
                              break;
                            case 'follow':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(
                                    userId: notification['sender_id'],
                                    username: notification['sender']['username'],
                                  ),
                                ),
                              );
                              break;
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
} 