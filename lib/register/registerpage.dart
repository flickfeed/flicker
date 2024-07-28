import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flickfeedpro/register/registerviewmodel.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Consumer<RegisterViewModel>(
            builder: (context, viewModel, child) {
              return Form(
                key: viewModel.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  children: [
                    SizedBox(height: 40.0),
                    Center(
                      child: Image.asset(
                        'assets/images/flickfeed.png', // Replace with your logo asset path
                        height: 100.0,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: Text(
                        'FlickFeed Sign Up',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    TextFormField(
                      enabled: !viewModel.loading,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value?.isEmpty ?? true ? "Please enter username" : null,
                      onSaved: (value) => viewModel.setUsername(value ?? ''),
                      focusNode: viewModel.usernameFN,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(viewModel.emailFN);
                      },
                    ),
                    SizedBox(height: 15.0),
                    TextFormField(
                      enabled: !viewModel.loading,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value?.isEmpty ?? true ? "Please enter email" : null,
                      onSaved: (value) => viewModel.setEmail(value ?? ''),
                      focusNode: viewModel.emailFN,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(viewModel.passFN);
                      },
                    ),
                    SizedBox(height: 15.0),
                    TextFormField(
                      enabled: !viewModel.loading,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(viewModel.obscureText ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            viewModel.obscureText = !viewModel.obscureText;
                            viewModel.notifyListeners();
                          },
                        ),
                      ),
                      obscureText: viewModel.obscureText,
                      textInputAction: TextInputAction.done,
                      validator: (value) => value?.isEmpty ?? true ? "Please enter password" : null,
                      onSaved: (value) => viewModel.setPassword(value ?? ''),
                      focusNode: viewModel.passFN,
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: viewModel.loading ? null : () => viewModel.register(context),
                      child: Text('Sign Up'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
