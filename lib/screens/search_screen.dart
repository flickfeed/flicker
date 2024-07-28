import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _posts = List.generate(30, (index) => 'https://example.com/post_image_$index.jpg');
  List<String> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _filteredPosts = _posts;
  }

  void _filterPosts(String query) {
    setState(() {
      _filteredPosts = _posts.where((post) => post.contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    // Determine the number of columns based on screen width
    final crossAxisCount = (screenWidth / 120).floor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
          ),
          onChanged: _filterPosts,
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(4.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[300],
            child: Image.network(
              _filteredPosts[index],
              fit: BoxFit.cover,
            ),
          );
        },
        itemCount: _filteredPosts.length,
      ),
    );
  }
}
