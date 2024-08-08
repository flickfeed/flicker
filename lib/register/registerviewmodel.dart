import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  bool obscureText = true;

  String _username = '', _email = '', _password = '';

  FocusNode usernameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();

  // Getters for input values
  String get username => _username;
  String get email => _email;
  String get password => _password;

  // Setters to update values and notify UI for changes
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

  // Toggle visibility of the password field
  void togglePasswordVisibility() {
    obscureText = !obscureText;
    notifyListeners();
  }

  // Simulate a registration process
  Future<void> register(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      setLoading(true);
      await Future.delayed(Duration(seconds: 2)); // Simulating network request
      setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registered successfully')),
      );
      Navigator.of(context).pushReplacementNamed('/main');  // Adjust the route as per your navigation setup
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in the form correctly')),
      );
    }
  }

  // Set loading status
  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
