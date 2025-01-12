import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_profile_screen.dart';

class FollowingScreen extends StatefulWidget {
  final String userId;

  const FollowingScreen({super.key, required this.userId});

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _following = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    try {
      final response = await _supabase
          .from('followers')
          .select('following:userdetails(id, username, avatar_url)')
          .eq('follower_id', widget.userId)
          .execute();

      final following = (response.data as List)
          .map((item) => item['following'] as Map<String, dynamic>)
          .toList();

      setState(() {
        _following = following;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading following: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow(String userId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      final isFollowing = await _checkIfFollowing(currentUserId, userId);

      if (isFollowing) {
        // Unfollow
        await _supabase
            .from('followers')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', userId);

        // Update local state to remove the unfollowed user
        setState(() {
          _following = _following.where((user) => user['id'] != userId).toList();
        });
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
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

    } catch (e) {
      print('Error toggling follow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating follow status')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _following.isEmpty
              ? Center(child: Text('Not following anyone'))
              : ListView.builder(
                  itemCount: _following.length,
                  itemBuilder: (context, index) {
                    final user = _following[index];
                    final isCurrentUser = user['id'] == _supabase.auth.currentUser?.id;

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
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text('Following'),
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