import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  bool obscureText = true;

  String _name = '', _username = '', _email = '', _password = '';

  FocusNode nameFN = FocusNode();
  FocusNode usernameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();

  String get name => _name;
  String get username => _username;
  String get email => _email;
  String get password => _password;

  void setName(String name) => _name = name;
  void setUsername(String username) => _username = username;

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
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    
    loading = true;
    notifyListeners();

    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _email,
        password: _password,
      );

      if (res.user != null) {
        await Supabase.instance.client.from('userdetails').upsert({
          'id': res.user!.id,
          'name': _name,
          'username': _username,
          'avatar_url': null,
          'bio': null,
        });

        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      print('Registration error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
