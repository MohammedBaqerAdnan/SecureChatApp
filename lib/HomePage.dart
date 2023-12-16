// import 'package:flutter/material.dart';
// import 'HomePageUI.dart';

// // The main function is the entry point of the application.
// void main() {
//   runApp(const SecureChatApp());
// }

// // SecureChatApp is the root widget of the application.
// class SecureChatApp extends StatelessWidget {
//   const SecureChatApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // MaterialApp is the top-level widget which provides theming.
//     return MaterialApp(
//       //to remove the debug
//       debugShowCheckedModeBanner: false,
//       //Title :title for the task manager's app
//       title: 'Secure Chat App',
//       theme: ThemeData(
//         primarySwatch: Colors.lightBlue,
//         brightness: Brightness.light,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       // HomePage is the default route of the application.
//       // home: const HomePageUI(title: 'Secure Chat App'),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'HomePageUI.dart';

// void main() {
//   runApp(const SecureChatApp());
// }

// class SecureChatApp extends StatelessWidget {
//   const SecureChatApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Secure Chat App',
//       theme: ThemeData(
//         primarySwatch: Colors.lightBlue,
//         brightness: Brightness.light,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   final String title;

//   const HomePage({required this.title, Key? key}) : super(key: key);

//   @override
//   // Widget build(BuildContext context) {
//   //   return HomePageUI(title: title);
//   // }
//   Widget build(BuildContext context) {
//     // MaterialApp is the top-level widget which provides theming.
//     return MaterialApp(
//       //to remove the debug
//       debugShowCheckedModeBanner: false,
//       //Title :title for the task manager's app
//       title: 'Secure Chat App',
//       theme: ThemeData(
//         primarySwatch: Colors.lightBlue,
//         brightness: Brightness.light,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       // HomePage is the default route of the application.
//       home: const HomePageUI(title: 'Secure Chat App'),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'HomePageUI.dart';

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomePageUI(title: title);
  }
}
