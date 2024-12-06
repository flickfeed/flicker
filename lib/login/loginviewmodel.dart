import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  bool obscureText = true;

  String _email = '';
  String _password = '';

  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      setLoading(true);

      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _email,
          password: _password,
        );

        if (response.session != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          throw Exception('Failed to log in.');
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

  void forgotPassword(BuildContext context) async {
    if (_email.isNotEmpty) {
      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(_email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset link sent to $_email')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
    }
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
