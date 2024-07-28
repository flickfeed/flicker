import 'package:flutter/material.dart';

class MessagingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Messages', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Add functionality for creating new messages
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 20, // Replace with actual message count
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with actual image URL
            ),
            title: Text('User $index'),
            subtitle: Text('Last message...'),
            onTap: () {
              // Navigate to chat screen
            },
          );
        },
      ),
    );
  }
}
