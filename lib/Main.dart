// import 'package:flutter/material.dart';
// import 'HomePage.dart';
// import 'SettingsPage.dart';
// import 'ChatPage.dart';

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
//       routes: {
//         '/': (context) => HomePage(),
//         '/settings': (context) => SettingsPage(),
//         '/chat': (context) => ChatPage(),
//       },
//       initialRoute: '/',
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'HomePage.dart';
// import 'SettingsPage.dart';
// import 'ChatPage.dart';

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
//       routes: {
//         '/': (context) => HomePage(title: 'Secure Chat App'),
//         '/settings': (context) => SettingsPage(),
//         '/chat': (context) => ChatPage(),
//       },
//       initialRoute: '/',
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'SettingsPage.dart';
import 'ChatPage.dart';

// The main function is the entry point of the application.
void main() {
  runApp(const SecureChatApp());
}

// SecureChatApp is the root widget of the application.
class SecureChatApp extends StatelessWidget {
  const SecureChatApp({Key? key}) : super(key: key);

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
      routes: {
        '/': (context) => HomePage(title: 'Secure Chat App'),
        '/settings': (context) => SettingsPage(),
        '/chat': (context) => ChatPage(),
      },
      initialRoute: '/',
    );
  }
}
