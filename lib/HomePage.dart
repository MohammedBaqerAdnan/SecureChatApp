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
