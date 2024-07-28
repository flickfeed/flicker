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
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 5),
          Container(
            height: 170.0,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/images/flickfeed.png', // Use an appropriate logo
            ),
          ),
          SizedBox(height: 10.0),
          Center(
            child: Text(
              'FLICKFEED',
              style: TextStyle(
                fontFamily: 'Lobster', // Use the same font as Instagram
                fontSize: 32.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(height: 25.0),
          buildForm(context, viewModel),
          SizedBox(height: 10.0),
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
              prefixIcon: Icon(Ionicons.mail_outline),
              hintText: "Email",
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
              prefixIcon: Icon(Ionicons.lock_closed_outline),
              suffixIcon: IconButton(
                icon: Icon(viewModel.obscureText ? Ionicons.eye_off_outline : Ionicons.eye_outline),
                onPressed: () {
                  setState(() {
                    viewModel.obscureText = !viewModel.obscureText;
                  });
                },
              ),
              hintText: "Password",
            ),
            textInputAction: TextInputAction.done,
            validator: (value) => value?.isEmpty ?? true ? "Please enter password" : null,
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
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            height: 45.0,
            width: 180.0,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: Text(
                'Log in'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => viewModel.login(context),
            ),
          ),
        ],
      ),
    );
  }
}
