import 'package:flutter/material.dart';

class UserListTile extends StatelessWidget {
  final String userId;
  final String username;
  final String avatarUrl;
  final VoidCallback onTap;

  const UserListTile({
    super.key,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          avatarUrl.isNotEmpty
              ? avatarUrl
              : 'https://via.placeholder.com/150',
        ),
      ),
      title: Text(username),
      onTap: onTap,
    );
  }
} 