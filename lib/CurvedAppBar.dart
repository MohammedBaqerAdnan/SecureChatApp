//defines a custom AppBar with a curved design, gradient background, and two action buttons.

import 'package:flutter/material.dart';
import 'AppBarClipper.dart';

class CurvedAppBar extends StatelessWidget implements PreferredSizeWidget {
  //title of the AppBar
  final String title;
  //constructor for the CurvedAppBar take title as parameter
  CurvedAppBar({required this.title});

//Widget with preferred size
  @override
  //Height of PreferredSize widget
  final Size preferredSize = Size.fromHeight(100.0);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: AppBarClipper(),
      child: Container(
        height: 100.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade400, Colors.lightBlue.shade900],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        //app slide for the app
        child: AppBar(
          backgroundColor: Colors.transparent,
          //no shadow
          elevation: 0,
          title: Text(title, style: TextStyle(fontSize: 24)),
          centerTitle: true,
          //button at the right of the appbar
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Handle app settings
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Handle new icon button press
              },
            ),
          ],
        ),
      ),
    );
  }
}
