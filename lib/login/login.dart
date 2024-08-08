import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flickfeedpro/login/loginviewmodel.dart';
import 'package:flickfeedpro/register/registerpage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    LoginViewModel viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
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
                color: Colors.blueAccent.withOpacity(0.6),
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
                color: Colors.blueAccent.withOpacity(0.6),
                width: 150,
                height: 150,
              ),
            ),
          ),
          // Page content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/login_illustration.png',
                        height: 250.0,
                        width: 250.0,
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        'FlickFeed Login',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      buildForm(context, viewModel),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account?'),
                        SizedBox(width: 5.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
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
    );
  }

  Widget buildForm(BuildContext context, LoginViewModel viewModel) {
    return Form(
      key: viewModel.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            enabled: !viewModel.loading,
            decoration: InputDecoration(
              prefixIcon: Icon(Ionicons.mail_outline, color: Colors.black),
              hintText: "Email",
              hintStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) =>
            value?.isEmpty ?? true ? "Please enter email" : null,
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
              prefixIcon: Icon(Ionicons.lock_closed_outline, color: Colors.black),
              suffixIcon: IconButton(
                icon: Icon(viewModel.obscureText
                    ? Ionicons.eye_off_outline
                    : Ionicons.eye_outline, color: Colors.black),
                onPressed: () {
                  setState(() {
                    viewModel.obscureText = !viewModel.obscureText;
                  });
                },
              ),
              hintText: "Password",
              hintStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            textInputAction: TextInputAction.done,
            validator: (value) =>
            value?.isEmpty ?? true ? "Please enter password" : null,
            obscureText: viewModel.obscureText,
            onSaved: (value) => viewModel.setPassword(value ?? ''),
            focusNode: viewModel.passFN,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: InkWell(
                onTap: () => viewModel.forgotPassword(context),
                child: Container(
                  width: 130,
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            height: 45.0,
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blue,
                ),
              ),
              child: viewModel.loading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Text(
                'Log in'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: viewModel.loading
                  ? null
                  : () => viewModel.login(context),
            ),
          ),
        ],
      ),
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
