//custom clipper that defines the curved shape of the AppBar

import 'package:flutter/material.dart';

class AppBarClipper extends CustomClipper<Path> {
  @override
  //function that defines the custom shape of your clipper
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  //check the object if its has different information
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
