import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('WhatsApp Message Sender'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              launchWhatsapp('+97333332291', 'Hello from Flutter!');
            },
            child: Text(
              'Message the Buyer ',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  launchWhatsapp(String number, String text) async {
    var whatsappUrl = "https://wa.me/$number?text=${Uri.encodeComponent(text)}";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      print('Could not launch $whatsappUrl');
    }
  }
}
