import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment.dart';
import '../models/posts.dart';
import '../widgets/comment_tile.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  final VoidCallback onCommentAdded;
  final Function(String)? onCommentDeleted;
  final ScrollController scrollController;

  const CommentsScreen({
    super.key,
    required this.post,
    required this.onCommentAdded,
    this.onCommentDeleted,
    required this.scrollController,
  });

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final _supabase = Supabase.instance.client;
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isPostingComment = false;
  final Map<String, bool> _showReplies = {};
  String? _replyingTo;
  String? _highlightedCommentId;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final response = await Supabase.instance.client
          .from('comments')
          .select()
          .eq('post_id', widget.post.postId)
          .eq('is_reply', false)
          .order('created_at', ascending: true);

      final comments = (response as List<dynamic>)
          .map((comment) => Comment.fromMap(comment))
          .toList();

      // Load replies for comments with reply_count > 0
      for (var comment in comments) {
        if (comment.replyCount > 0) {
          final replies = await _loadReplies(comment.id);
          comment.replies.addAll(replies);
        }
      }

      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading comments: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<List<Comment>> _loadReplies(String parentId) async {
    try {
      final response = await Supabase.instance.client
          .from('comments')
          .select()
          .eq('parent_id', parentId)
          .order('created_at', ascending: true);

      return (response as List<dynamic>)
          .map((reply) => Comment.fromMap(reply))
          .toList();
    } catch (e) {
      print('Error loading replies: $e');
      return [];
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isPostingComment = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get user details
      final userResponse = await _supabase
          .from('userdetails')
          .select('username, avatar_url')
          .eq('id', userId)
          .single();

      // Use the userResponse to extract username and avatar_url
      final username = userResponse['username'];
      final avatarUrl = userResponse['avatar_url'];

      // Create comment
      final comment = {
        'post_id': widget.post.postId,
        'user_id': userId,
        'text': _commentController.text.trim(),
        'username': username,
        'avatar_url': avatarUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('comments').insert(comment);

      // Create notification for comment
      if (widget.post.userId != userId) {  // Don't notify if user comments on their own post
        await _supabase.from('notifications').insert({
          'recipient_id': widget.post.userId,
          'sender_id': userId,
          'type': 'comment',
          'content': _commentController.text.trim(),
          'post_id': widget.post.postId,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      if (mounted) {
        widget.onCommentAdded();  // Call the callback to update the post
        setState(() {
          _comments.add(Comment.fromMap(comment));
          _commentController.clear();
        });
      }

    } catch (e) {
      print('Error posting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting comment')),
      );
    } finally {
      setState(() => _isPostingComment = false);
    }
  }

  Future<int> _getReplyCount(String commentId) async {
    try {
      final response = await Supabase.instance.client
          .from('comments')
          .select()
          .eq('parent_id', commentId);

      // Count the replies manually
      return (response as List).length;
    } catch (e) {
      print('Error getting reply count: $e');
      return 0;
    }
  }

  Future<void> _likeComment(Comment comment) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final isLiked = comment.likedUsers.contains(userId);
      final newLikes = isLiked ? comment.likes - 1 : comment.likes + 1;
      final newLikedUsers = List<String>.from(comment.likedUsers);
      
      if (isLiked) {
        newLikedUsers.remove(userId);
      } else {
        newLikedUsers.add(userId);
      }

      await Supabase.instance.client
          .from('comments')
          .update({
            'likes': newLikes,
            'liked_users': newLikedUsers,
          })
          .eq('id', comment.id);

      await _loadComments();
    } catch (e) {
      print('Error liking comment: $e');
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _supabase
          .from('comments')
          .delete()
          .eq('id', commentId);
    } catch (e) {
      print('Error deleting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting comment')),
      );
    }
  }

  void _showCommentOptions(BuildContext context, Comment comment) {
    final currentUserId = _supabase.auth.currentUser?.id;
    final isPostOwner = widget.post.userId == currentUserId;
    final isCommentOwner = comment.userId == currentUserId;

    if (isPostOwner || isCommentOwner) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteComment(comment.id);
                  setState(() {
                    _comments.removeWhere((c) => c.id == comment.id);
                  });
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _toggleLikeComment(Comment comment) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      if (comment.likedUsers.contains(userId)) {
        comment.likedUsers.remove(userId);
        comment.likes--;
      } else {
        comment.likedUsers.add(userId);
        comment.likes++;
      }
    });

    try {
      await _supabase
          .from('comments')
          .update({
            'likes': comment.likes,
            'liked_users': comment.likedUsers,
          })
          .eq('id', comment.id);
    } catch (e) {
      // Revert on error
      setState(() {
        if (comment.likedUsers.contains(userId)) {
          comment.likedUsers.remove(userId);
          comment.likes--;
        } else {
          comment.likedUsers.add(userId);
          comment.likes++;
        }
      });
      print('Error updating comment like: $e');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _supabase.auth.currentUser;
    final avatarUrl = currentUser?.userMetadata?['avatar_url'];

    return Column(
      children: [
        // Handle bar at the top
        Container(
          height: 4,
          width: 40,
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Comments header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Comments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(),
        // Comments list
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return GestureDetector(
                      onLongPress: () {
                        final currentUserId = _supabase.auth.currentUser?.id;
                        if (currentUserId == widget.post.userId || // Post owner
                            currentUserId == comment.userId) { // Comment owner
                          _showCommentOptions(context, comment);
                        }
                      },
                      child: CommentTile(
                        comment: comment,
                        onLike: () => _toggleLikeComment(comment),
                        onReply: (username) {
                          setState(() => _replyingTo = comment.id);
                          _commentController.text = '@$username ';
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        onDelete: () async {
                          await _deleteComment(comment.id);
                          setState(() {
                            _comments.removeWhere((c) => c.id == comment.id);
                          });
                        },
                        showReplies: _showReplies[comment.id] ?? false,
                        onToggleReplies: () {
                          setState(() {
                            _showReplies[comment.id] = !(_showReplies[comment.id] ?? false);
                          });
                        },
                      ),
                    );
                  },
                ),
        ),
        // Comment input
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Icon(Icons.person)
                    : null,
                radius: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),
              if (_isPostingComment)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                TextButton(
                  onPressed: _postComment,
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: _commentController.text.trim().isEmpty
                          ? Colors.blue.withOpacity(0.5)
                          : Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}