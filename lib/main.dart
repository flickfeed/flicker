import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flickfeedpro/screens/splash_screen.dart';
import 'package:flickfeedpro/screens/home_screen.dart';
import 'package:flickfeedpro/screens/feed_screen.dart';
import 'package:flickfeedpro/login/login.dart';
import 'package:flickfeedpro/register/registerpage.dart';
import 'package:flickfeedpro/login/loginviewmodel.dart';
import 'package:flickfeedpro/screens/user_profile_screen.dart';
import 'package:flickfeedpro/screens/EditProfileScreen.dart';
import 'providers/theme_provider.dart';
import 'package:flickfeedpro/screens/followers_screen.dart';
import 'package:flickfeedpro/screens/following_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Supabase with your actual credentials
    await Supabase.initialize(
      url: 'https://bvlmfeoikgsayrcelccq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ2bG1mZW9pa2dzYXlyY2VsY2NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMjE4NDcsImV4cCI6MjA0ODY5Nzg0N30.VpHNOpfAa243g9PBHv-Gp5I7ynwvsggSLOPmvSiE9aw',
      debug: true,
    );

    runApp(
      ChangeNotifierProvider(
        create: (_) => LoginViewModel(),
        child: ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: MyApp(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    print('Error in main: $e');
    print('Stack trace: $stackTrace');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FlickFeed',
          theme: themeProvider.themeData,
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
          routes: {
            '/login': (context) => LoginPage(),
            '/register': (context) => RegisterPage(),
            '/home': (context) => HomeScreen(),
            '/feed': (context) => FeedScreen(),
            '/user-profile': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
              return UserProfileScreen(
                userId: args['userId']!,
                username: args['username']!,
              );
            },
            '/edit-profile': (context) => EditProfileScreen(),
            '/followers': (context) => FollowersScreen(
              userId: ModalRoute.of(context)!.settings.arguments as String,
            ),
            '/following': (context) => FollowingScreen(
              userId: ModalRoute.of(context)!.settings.arguments as String,
            ),
          },
          builder: (context, child) {
            return child ?? Container();
          },
          navigatorObservers: [
            // Add a navigator observer to track route changes
            NavigatorObserver(),
          ],
        );
      },
    );
  }
}
