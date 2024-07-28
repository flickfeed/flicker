import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String username;
  final String website;
  final String bio;
  final String imageUrl;

  EditProfileScreen({
    required this.name,
    required this.username,
    required this.website,
    required this.bio,
    required this.imageUrl,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _username;
  late String _website;
  late String _bio;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _username = widget.username;
    _website = widget.website;
    _bio = widget.bio;
    _imageUrl = widget.imageUrl;
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'name': _name,
        'username': _username,
        'website': _website,
        'bio': _bio,
        'imageUrl': _imageUrl,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_imageUrl),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          // Implement image picker
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _username,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onSaved: (value) => _username = value!,
              ),
              TextFormField(
                initialValue: _website,
                decoration: InputDecoration(labelText: 'Website'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your website';
                  }
                  return null;
                },
                onSaved: (value) => _website = value!,
              ),
              TextFormField(
                initialValue: _bio,
                decoration: InputDecoration(labelText: 'Bio'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your bio';
                  }
                  return null;
                },
                onSaved: (value) => _bio = value!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
