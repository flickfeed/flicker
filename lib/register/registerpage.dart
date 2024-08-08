import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flickfeedpro/register/registerviewmodel.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Top-left curve
            Positioned(
              top: 0,
              left: 0,
              child: ClipPath(
                clipper: TopLeftClipper(),
                child: Container(
                  color: Colors.blueAccent.withOpacity(0.6), // Adjust color
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            // Bottom-right curve
            Positioned(
              bottom: 0,
              right: 0,
              child: ClipPath(
                clipper: BottomRightClipper(),
                child: Container(
                  color: Colors.blueAccent.withOpacity(0.6), // Adjust color
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 250.0,
                          height: 250.0,
                          child: Image.asset(
                            'assets/images/signup_illustration.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Text(
                          'FlickFeed Sign Up',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        buildForm(context),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account?'),
                          SizedBox(width: 5.0),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(); // Go back to the login page
                            },
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black, // Light color for text
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
              TextFormField(
                enabled: !viewModel.loading,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person, color: Colors.black), // Black icon
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
                  prefixIcon: Icon(Icons.email, color: Colors.black), // Black icon
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
                  prefixIcon: Icon(Icons.lock, color: Colors.black), // Black icon
                  suffixIcon: IconButton(
                    icon: Icon(viewModel.obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                    onPressed: viewModel.togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: viewModel.obscureText,
                textInputAction: TextInputAction.done,
                validator: (value) => value?.isEmpty ?? true ? "Please enter password" : null,
                onSaved: (value) => viewModel.setPassword(value ?? ''),
                focusNode: viewModel.passFN,
              ),
              SizedBox(height: 30.0),
              Container(
                height: 45.0,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.loading ? null : () => viewModel.register(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.blue, // Blue color for the button
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: viewModel.loading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(
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
