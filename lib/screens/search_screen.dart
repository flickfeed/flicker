import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _recentSearches = [];
  bool _isLoading = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        _searchUsers(_searchController.text);
      } else {
        setState(() {
          _users.clear();
        });
      }
    });
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final recentSearchesJson = _prefs.getStringList('recent_searches') ?? [];
    setState(() {
      _recentSearches = recentSearchesJson
          .map((String jsonStr) => json.decode(jsonStr) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _addToRecentSearches(Map<String, dynamic> user) async {
    // Remove if already exists
    _recentSearches.removeWhere((search) => search['id'] == user['id']);
    
    // Add to beginning of list
    _recentSearches.insert(0, user);
    
    // Keep only last 10 searches
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    // Save to SharedPreferences
    final recentSearchesJson = _recentSearches
        .map((search) => json.encode(search))
        .toList();
    await _prefs.setStringList('recent_searches', recentSearchesJson);

    setState(() {});
  }

  Future<void> _removeFromRecentSearches(String userId) async {
    setState(() {
      _recentSearches.removeWhere((search) => search['id'] == userId);
    });

    // Save updated list to SharedPreferences
    final recentSearchesJson = _recentSearches
        .map((search) => json.encode(search))
        .toList();
    await _prefs.setStringList('recent_searches', recentSearchesJson);
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _users.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _supabase
          .from('userdetails')
          .select()
          .or('username.ilike.%$query%, name.ilike.%$query%')
          .limit(20);

      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching users: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildUserTile(Map<String, dynamic> user, {bool isRecent = false}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user['avatar_url'] != null
            ? NetworkImage(user['avatar_url'])
            : null,
        child: user['avatar_url'] == null
            ? Icon(Icons.person, color: Colors.grey[400])
            : null,
      ),
      title: Text(
        user['username'] ?? '',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: user['name'] != null && user['name'].toString().isNotEmpty
          ? Text(user['name'])
          : null,
      trailing: isRecent
          ? IconButton(
              icon: Icon(Icons.close, size: 18),
              onPressed: () => _removeFromRecentSearches(user['id']),
            )
          : null,
      onTap: () {
        _addToRecentSearches(user);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              userId: user['id'],
              username: user['username'] ?? '',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _users.clear();
                                    });
                                  },
                                )
                              : null,
                        ),
                        onTap: () {
                          setState(() => _isSearching = true);
                        },
                      ),
                    ),
                  ),
                  if (_isSearching)
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: GestureDetector(
                        onTap: () {
                          _focusNode.unfocus();
                          setState(() {
                            _isSearching = false;
                            _searchController.clear();
                            _users.clear();
                          });
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (_searchController.text.isEmpty && _recentSearches.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _prefs.remove('recent_searches');
                            setState(() {
                              _recentSearches.clear();
                            });
                          },
                          child: Text('Clear All'),
                        ),
                      ],
                    ),
                  ),
                if (_searchController.text.isEmpty)
                  ..._recentSearches.map((user) => _buildUserTile(user, isRecent: true)),
                if (_searchController.text.isNotEmpty)
                  ..._users.map((user) => _buildUserTile(user)),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
