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
  String? _replyingToCommentId;
  String? _replyingToUsername;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      // First get comments
      final response = await _supabase
          .from('comments')
          .select()
          .eq('post_id', widget.post.postId)
          .is_('parent_id', null)
          .order('created_at', ascending: true);

      final comments = (response as List).map((comment) => Comment.fromMap({
            ...comment,
            // Use the username and avatar_url directly from comments table
            'username': comment['username'],
            'avatar_url': comment['avatar_url'],
          })).toList();

      // Load replies for each comment
      for (var comment in comments) {
        await _loadRepliesRecursively(comment);
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

  Future<void> _loadRepliesRecursively(Comment parentComment) async {
    try {
      final response = await _supabase
          .from('comments')
          .select()
          .eq('parent_id', parentComment.id)
          .order('created_at', ascending: true);

      final replies = (response as List).map((reply) => Comment.fromMap({
            ...reply,
            'username': reply['username'],
            'avatar_url': reply['avatar_url'],
          }, level: parentComment.level + 1)).toList();

      // Load nested replies
      for (var reply in replies) {
        await _loadRepliesRecursively(reply);
      }

      parentComment.replies.addAll(replies);
    } catch (e) {
      print('Error loading replies: $e');
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isPostingComment = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get current user details
      final userResponse = await _supabase
          .from('userdetails')
          .select('username, avatar_url')
          .eq('id', userId)
          .single();

      // Create the comment text
      String commentText = _commentController.text.trim();
      if (_replyingToUsername != null && !commentText.startsWith('@')) {
        commentText = '@$_replyingToUsername $commentText';
      }

      // Create the comment
      final comment = {
        'post_id': widget.post.postId,
        'user_id': userId,
        'text': commentText,
        'username': userResponse['username'],
        'avatar_url': userResponse['avatar_url'],
        'created_at': DateTime.now().toIso8601String(),
        'parent_id': _replyingToCommentId,
        'likes': 0,
        'liked_users': [],
        'is_reply': _replyingToCommentId != null,
      };

      // Insert the comment
      final response = await _supabase
          .from('comments')
          .insert(comment)
          .select()
          .single();

      // If this is a reply, update the parent comment's reply count
      if (_replyingToCommentId != null) {
        // First get current reply count
        final parentComment = await _supabase
            .from('comments')
            .select('reply_count')
            .eq('id', _replyingToCommentId)
            .single();
        
        final currentReplyCount = parentComment['reply_count'] as int? ?? 0;

        // Then update with incremented count
        await _supabase
            .from('comments')
            .update({'reply_count': currentReplyCount + 1})
            .eq('id', _replyingToCommentId);

        // Add the new reply to the parent comment in the UI
        final parentIndex = _comments.indexWhere((c) => c.id == _replyingToCommentId);
        if (parentIndex != -1) {
          setState(() {
            _comments[parentIndex].replies.add(Comment.fromMap(response));
            _showReplies[_replyingToCommentId!] = true; // Show replies after adding new one
          });
        }
      } else {
        // Add new top-level comment to the UI
        setState(() {
          _comments.add(Comment.fromMap(response));
        });
      }

      // Update post comment count
      await widget.post.updateCommentCount(widget.post.commentCount + 1);

      // Create notification
      if (widget.post.userId != userId) {
        await _supabase.from('notifications').insert({
          'recipient_id': widget.post.userId,
          'sender_id': userId,
          'type': 'comment',
          'post_id': widget.post.postId,
          'content': _commentController.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        _commentController.clear();
        setState(() {
          _replyingToCommentId = null;
          _replyingToUsername = null;
        });
        widget.onCommentAdded();
      }
    } catch (e) {
      print('Error posting comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting comment')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPostingComment = false);
      }
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

  void _handleReply(String username, String? commentId) {
    setState(() {
      _replyingToUsername = username;
      _replyingToCommentId = commentId;
      _commentController.text = '@$username ';
    });
    FocusScope.of(context).requestFocus(FocusNode());
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
                        onReply: (username, commentId) => _handleReply(username, commentId),
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
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: _supabase.auth.currentUser?.userMetadata?['avatar_url'] != null
                ? NetworkImage(_supabase.auth.currentUser!.userMetadata!['avatar_url'])
                : null,
            child: _supabase.auth.currentUser?.userMetadata?['avatar_url'] == null
                ? Icon(Icons.person)
                : null,
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: _replyingToUsername != null 
                    ? '@$_replyingToUsername' 
                    : 'Add a comment...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (_replyingToUsername != null && 
                    !value.startsWith('@$_replyingToUsername') &&
                    value.isNotEmpty) {
                  // Only add @username if it's not already there and field is not empty
                  _commentController.text = '@$_replyingToUsername $value';
                  _commentController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _commentController.text.length),
                  );
                }
              },
              maxLines: null,
            ),
          ),
          if (_isPostingComment)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
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
    );
  }
}