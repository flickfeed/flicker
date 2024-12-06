import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  bool obscureText = true;

  String _profileName = '', _username = '', _email = '', _password = '';

  FocusNode profileNameFN = FocusNode();
  FocusNode usernameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();

  String get profileName => _profileName;
  String get username => _username;
  String get email => _email;
  String get password => _password;

  void setProfileName(String profileName) {
    _profileName = profileName;
    notifyListeners();
  }

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscureText = !obscureText;
    notifyListeners();
  }

  Future<void> register(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      setLoading(true);

      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: _email,
          password: _password,
          data: {
            'profileName': _profileName,
            'username': _username,
          },
        );

        if (response.user != null) {
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          throw Exception('Registration failed.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setLoading(false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in the form correctly')),
      );
    }
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
