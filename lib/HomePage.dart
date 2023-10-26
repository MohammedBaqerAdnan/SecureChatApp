import 'package:flutter/material.dart';
import 'HomePageUI.dart';

// The main function is the entry point of the application.
void main() {
  runApp(const SecureChatApp());
}

// SecureChatApp is the root widget of the application.
class SecureChatApp extends StatelessWidget {
  const SecureChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the top-level widget which provides theming.
    return MaterialApp(
      //to remove the debug
      debugShowCheckedModeBanner: false,
      //Title :title for the task manager's app
      title: 'Secure Chat App',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // HomePage is the default route of the application.
      home: const HomePage(title: 'Secure Chat App'),
    );
  }
}
