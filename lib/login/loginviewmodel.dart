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
        // Attempt to log in with Supabase Auth
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _email,
          password: _password,
        );

        if (response.session != null) {
          // Fetch user details after successful login
          final userId = response.user!.id;

          // Query user details from 'userdetails' table, limiting to one row
          final userDetailsResponse = await Supabase.instance.client
              .from('userdetails')
              .select()
              .eq('id', userId)
              .limit(1) // Ensure only one row is returned
              .execute();

          // If no user details are found, insert them into the 'userdetails' table
          if (userDetailsResponse.data == null || userDetailsResponse.data.isEmpty) {
            // Insert user details into the 'userdetails' table
            final insertResponse = await Supabase.instance.client.from('userdetails').insert({
              'id': userId,
              'username': 'New User', // You can set a default or prompt for the username
            }).execute();

            // Check if there's any error in the response (via status or data)
            if (insertResponse.status != 200) {
              throw Exception('Failed to insert user details: ${insertResponse.status}');
            }

            print('User details inserted: $userId');
          }

          // Use the first item if found (since we limited the query to 1 row)
          final userData = userDetailsResponse.data?.isNotEmpty == true ? userDetailsResponse.data![0] : null;
          print('User Details: $userData'); // Debugging purpose

          // Navigate to the home screen after successful login
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
