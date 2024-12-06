import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

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
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  final supabase = Supabase.instance.client; // Supabase instance

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _username = widget.username;
    _website = widget.website;
    _bio = widget.bio;
    _imageUrl = widget.imageUrl;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String imageUrl = _imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      // Save updated data to Supabase (assuming you have a table 'userdetails')
      final response = await supabase.from('userdetails').upsert({
        'user_id': supabase.auth.currentUser!.id, // Use current user ID
        'name': _name,
        'username': _username,
        'website': _website,
        'bio': _bio,
        'imageUrl': imageUrl,
      }).execute();

      if (response.error != null) {
        print('Error updating profile: ${response.error?.message}');
        return;
      }

      Navigator.pop(context, {
        'name': _name,
        'username': _username,
        'website': _website,
        'bio': _bio,
        'imageUrl': imageUrl,
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    // Upload the image to Supabase storage
    final fileName = 'profile_images/${DateTime.now().toIso8601String()}.jpg';
    final storageRef = supabase.storage.from('profile_images').upload(fileName, imageFile);
    final fileUrl = await storageRef;

    return fileUrl;
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
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : NetworkImage(_imageUrl) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: _pickImage,
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
