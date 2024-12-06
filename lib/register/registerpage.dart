import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'registerviewmodel.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Decorative top-left curve
            Positioned(
              top: 0,
              left: 0,
              child: ClipPath(
                clipper: TopLeftClipper(),
                child: Container(
                  color: Colors.blueAccent.withOpacity(0.6),
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            // Decorative bottom-right curve
            Positioned(
              bottom: 0,
              right: 0,
              child: ClipPath(
                clipper: BottomRightClipper(),
                child: Container(
                  color: Colors.blueAccent.withOpacity(0.6),
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration
                          SizedBox(
                            width: 250.0,
                            height: 250.0,
                            child: Image.asset(
                              'assets/images/Signup_illustration.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          // Page title
                          const Text(
                            'FlickFeed Sign Up',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          // Form section
                          buildForm(context),
                        ],
                      ),
                    ),
                  ),
                  // Navigation to Login
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          const SizedBox(width: 5.0),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue, // Highlighted color
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return Form(
          key: viewModel.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              // Username field
              TextFormField(
                enabled: !viewModel.loading,
                decoration: _inputDecoration(
                  label: 'Username',
                  icon: Icons.person,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => value?.isEmpty ?? true ? "Please enter username" : null,
                onSaved: (value) => viewModel.setUsername(value ?? ''),
                focusNode: viewModel.usernameFN,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(viewModel.emailFN);
                },
              ),
              const SizedBox(height: 15.0),
              // Email field
              TextFormField(
                enabled: !viewModel.loading,
                decoration: _inputDecoration(
                  label: 'Email',
                  icon: Icons.email,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) => viewModel.setEmail(value ?? ''),
                focusNode: viewModel.emailFN,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(viewModel.passFN);
                },
              ),
              const SizedBox(height: 15.0),
              // Password field
              TextFormField(
                enabled: !viewModel.loading,
                decoration: _inputDecoration(
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  obscureText: viewModel.obscureText,
                  toggleVisibility: viewModel.togglePasswordVisibility,
                ),
                obscureText: viewModel.obscureText,
                textInputAction: TextInputAction.done,
                validator: (value) => value?.isEmpty ?? true ? "Please enter password" : null,
                onSaved: (value) => viewModel.setPassword(value ?? ''),
                focusNode: viewModel.passFN,
              ),
              const SizedBox(height: 30.0),
              // Sign-Up button
              SizedBox(
                height: 45.0,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.loading ? null : () => viewModel.register(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: viewModel.loading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text(
                    'SIGN UP',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.black),
      suffixIcon: isPassword
          ? IconButton(
        icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black),
        onPressed: toggleVisibility,
      )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

// Top-left custom clipper
class TopLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Bottom-right custom clipper
class BottomRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.5, 0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
