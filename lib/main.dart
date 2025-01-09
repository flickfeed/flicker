import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flickfeedpro/screens/splash_screen.dart';
import 'package:flickfeedpro/screens/home_screen.dart';
import 'package:flickfeedpro/screens/feed_screen.dart';
import 'package:flickfeedpro/login/login.dart';
import 'package:flickfeedpro/register/registerpage.dart';
import 'package:flickfeedpro/login/loginviewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your actual credentials
  await Supabase.initialize(
    url: 'https://bvlmfeoikgsayrcelccq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ2bG1mZW9pa2dzYXlyY2VsY2NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMjE4NDcsImV4cCI6MjA0ODY5Nzg0N30.VpHNOpfAa243g9PBHv-Gp5I7ynwvsggSLOPmvSiE9aw',
    debug: true  // Keep this for debugging
  );

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
      debugShowCheckedModeBanner: false,
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
