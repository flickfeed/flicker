import 'package:flickfeedpro/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flickfeedpro/screens/home_screen.dart';
import 'package:flickfeedpro/screens/feed_screen.dart';
import 'package:flickfeedpro/login/login.dart';
import 'package:flickfeedpro/login/loginviewmodel.dart';
import 'package:flickfeedpro/register/registerpage.dart';
import 'package:flickfeedpro/screens/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlickFeed',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,  // This line hides the debug banner
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomeScreen(),
        '/feed': (context) => FeedScreen(),
      },
    );
  }
}