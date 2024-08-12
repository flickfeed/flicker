import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flickfeedpro/models/posts.dart';
import 'package:flutter/services.dart';

class SharePostScreen extends StatefulWidget {
  final Post post;

  SharePostScreen({required this.post});

  @override
  _SharePostScreenState createState() => _SharePostScreenState();
}

class _SharePostScreenState extends State<SharePostScreen> {
  List<String> selectedFollowers = [];
  List<String> followers = ['Follower 1', 'Follower 2', 'Follower 3', 'Follower 4', 'Follower 5']; // Dummy followers

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: widget.post.imageUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _shareTo() {
    Share.share('Check out this post: ${widget.post.caption}\n${widget.post.imageUrl}');
  }

  void _shareToWhatsApp() {
    Share.share('Check out this post on WhatsApp: ${widget.post.caption}\n${widget.post.imageUrl}');
  }

  void _addToStory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post added to story')),
    );
  }

  void _onFollowerTap(String follower) {
    setState(() {
      if (selectedFollowers.contains(follower)) {
        selectedFollowers.remove(follower);
      } else {
        selectedFollowers.add(follower);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.black.withOpacity(0.4), // Dark semi-transparent background
        child: GestureDetector(
          onTap: () {}, // Prevents tap event from propagating to the outer GestureDetector
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search followers...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                        ),
                        onChanged: (value) {
                          // Implement global search functionality
                        },
                      ),
                    ),
                    Divider(thickness: 1),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Display 3 profiles per row
                          childAspectRatio: 0.75,
                        ),
                        itemCount: followers.length,
                        itemBuilder: (context, index) {
                          final follower = followers[index];
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () => _onFollowerTap(follower),
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage('assets/avatar.png'), // Replace with follower avatar
                                    ),
                                    if (selectedFollowers.contains(follower))
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.blue,
                                          child: Icon(Icons.check, size: 16, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                follower,
                                style: TextStyle(color: Colors.black, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Light grey background
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconOption(context, icon: Icons.copy, text: 'Copy link', onTap: _copyLink),
                          _buildIconOption(context, icon: Icons.send, text: 'Share to...', onTap: _shareTo),
                          _buildIconOption(context, icon: FontAwesomeIcons.whatsapp, text: 'WhatsApp', onTap: _shareToWhatsApp),
                          _buildIconOption(context, icon: Icons.add_circle_outline, text: 'Add to story', onTap: _addToStory),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIconOption(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[300], // Slightly darker grey for the icon background
            child: Icon(icon, color: Colors.black),
          ),
        ),
        SizedBox(height: 4),
        Text(text, style: TextStyle(color: Colors.black, fontSize: 12)),
      ],
    );
  }
}

// To open the SharePostScreen as a popup
void showSharePostScreen(BuildContext context, Post post) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return SharePostScreen(post: post);
    },
  );
}
