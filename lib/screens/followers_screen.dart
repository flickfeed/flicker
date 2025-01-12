import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_profile_screen.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;

  const FollowersScreen({super.key, required this.userId});

  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _followers = [];
  bool _isLoading = true;
  final Map<String, bool> _followingStatus = {};  // Track following status for each user

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    try {
      final response = await _supabase
          .from('followers')
          .select('follower:users(id, username, avatar_url)')
          .eq('following_id', widget.userId)
          .execute();

      final followers = (response as List)
          .map((item) => item['follower'] as Map<String, dynamic>)
          .toList();

      // Check following status for each follower
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != null) {
        for (var follower in followers) {
          final isFollowing = await _checkIfFollowing(currentUserId, follower['id']);
          _followingStatus[follower['id']] = isFollowing;
        }
      }

      setState(() {
        _followers = followers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading followers: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _checkIfFollowing(String currentUserId, String targetUserId) async {
    final response = await _supabase
        .from('followers')
        .select()
        .eq('follower_id', currentUserId)
        .eq('following_id', targetUserId)
        .maybeSingle();
    return response != null;
  }

  Future<void> _toggleFollow(String userId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      final isFollowing = _followingStatus[userId] ?? false;

      if (isFollowing) {
        // Unfollow
        await _supabase
            .from('followers')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', userId);
      } else {
        // Follow
        await _supabase.from('followers').insert({
          'follower_id': currentUserId,
          'following_id': userId,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });

        // Create notification
        await _supabase.from('notifications').insert({
          'recipient_id': userId,
          'sender_id': currentUserId,
          'type': 'follow',
          'message': 'started following you',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      setState(() {
        _followingStatus[userId] = !isFollowing;
      });
    } catch (e) {
      print('Error toggling follow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating follow status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _followers.isEmpty
              ? Center(child: Text('No followers yet'))
              : ListView.builder(
                  itemCount: _followers.length,
                  itemBuilder: (context, index) {
                    final user = _followers[index];
                    final isCurrentUser = user['id'] == _supabase.auth.currentUser?.id;
                    final isFollowing = _followingStatus[user['id']] ?? false;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user['avatar_url'] != null
                            ? NetworkImage(user['avatar_url'])
                            : null,
                        child: user['avatar_url'] == null
                            ? Icon(Icons.person)
                            : null,
                      ),
                      title: Text(user['username'] ?? ''),
                      subtitle: Text(user['name'] ?? ''),
                      trailing: !isCurrentUser ? TextButton(
                        onPressed: () => _toggleFollow(user['id']),
                        style: TextButton.styleFrom(
                          backgroundColor: isFollowing ? Colors.white : Colors.blue,
                          side: BorderSide(
                            color: isFollowing ? Colors.grey[300]! : Colors.blue,
                          ),
                        ),
                        child: Text(
                          isFollowing ? 'Following' : 'Follow',
                          style: TextStyle(
                            color: isFollowing ? Colors.black : Colors.white,
                          ),
                        ),
                      ) : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(
                              userId: user['id'],
                              username: user['username'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
} 