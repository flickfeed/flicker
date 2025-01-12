import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart'; // For Clipboard and ClipboardData

class SharePostScreen extends StatefulWidget {
  final String postId; // Post's unique ID
  final String imageUrl; // URL of the post's image
  final String caption; // Post's caption

  const SharePostScreen({
    super.key,
    required this.postId,
    required this.imageUrl,
    required this.caption,
  });

  @override
  _SharePostScreenState createState() => _SharePostScreenState();
}

class _SharePostScreenState extends State<SharePostScreen> {
  List<String> selectedFollowers = [];
  List<Map<String, dynamic>> followers = [];
  List<Map<String, dynamic>> searchResults = [];
  String searchQuery = "";
  bool isLoading = false;

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchFollowersData();
  }

  Future<void> _fetchFollowersData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('followers')
            .select('follower_username, follower_avatar_url')
            .eq('user_id', user.id);

        if (response.error != null) {
          throw Exception(response.error!.message);
        }

        setState(() {
          followers = List<Map<String, dynamic>>.from(response.data ?? []);
          searchResults = followers;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching followers: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchFollowers(String query) {
    setState(() {
      searchQuery = query;
      searchResults = query.isEmpty
          ? followers
          : followers
          .where((follower) => follower['follower_username']
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: widget.imageUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _shareTo() {
    Share.share('Check out this post: ${widget.caption}\n${widget.imageUrl}');
  }

  void _shareToWhatsApp() {
    Share.share('Check out this post on WhatsApp: ${widget.caption}\n${widget.imageUrl}');
  }

  void _addToStory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post added to story')),
    );
  }

  void _onFollowerTap(String username) {
    setState(() {
      if (selectedFollowers.contains(username)) {
        selectedFollowers.remove(username);
      } else {
        selectedFollowers.add(username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.black.withOpacity(0.4),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                        onChanged: _searchFollowers,
                      ),
                    ),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final follower = searchResults[index];
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () => _onFollowerTap(follower['follower_username']),
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                          follower['follower_avatar_url']),
                                    ),
                                    if (selectedFollowers
                                        .contains(follower['follower_username']))
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
                                follower['follower_username'],
                                style: TextStyle(fontSize: 12, color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    _buildBottomOptions(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconOption(Icons.copy, 'Copy link', _copyLink),
          _buildIconOption(Icons.send, 'Share to...', _shareTo),
          _buildIconOption(FontAwesomeIcons.whatsapp, 'WhatsApp', _shareToWhatsApp),
          _buildIconOption(Icons.add_circle_outline, 'Add to story', _addToStory),
        ],
      ),
    );
  }

  Widget _buildIconOption(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.black),
          SizedBox(height: 5),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }
}
