import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String qrData = 'Loading QR Data...';
  List<Map<String, dynamic>> messages = [];
  Timer? timer;
  String ipAddressForAPI = 'http://192.168.100.7:3000';
  final TextEditingController msgController =
      TextEditingController(); // use this controller to get the input text

  @override
  void initState() {
    super.initState();
    initializeWhatsAppClient();
    getQrData();
    getMessages();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      getMessages();
    });
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      getQrData();
    });
  }

  Future<void> initializeWhatsAppClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('firstTime') ?? true;
    if (firstTime) {
      try {
        final response = await http.get(
          Uri.parse('${ipAddressForAPI}/start-whatsapp'),
        );
        print('WhatsApp client started: ${response.body}');
        await prefs.setBool('firstTime', false);
      } catch (e) {
        print('Error occurred: $e');
      }
    }
  }

  void sendWhatsAppMessage(String number, String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ipAddressForAPI}/send-message'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'num':
              number, // replace this with the WhatsApp number you want to send to
          'message': message,
        }),
      );
      print('Message sent: ${response.body}');
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  void dispose() {
    msgController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> getQrData() async {
    try {
      final response = await http.get(
        Uri.parse('${ipAddressForAPI}/get-qr'),
      );
      if (response.statusCode == 200) {
        setState(() {
          qrData = jsonDecode(response.body)['qr'];
        });
      } else {
        print('Failed to load QR Code.');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> getMessages() async {
    try {
      final response = await http.get(
        Uri.parse('${ipAddressForAPI}/get-messages'),
      );
      if (response.statusCode == 200) {
        setState(() {
          messages.addAll(List<Map<String, dynamic>>.from(
            jsonDecode(response.body)['messages'],
          ));
        });
      } else {
        print('Failed to load Messages.');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('WhatsApp QR Demo'),
        ),
        body: qrData == 'Loading QR Data...'
            ? CircularProgressIndicator()
            : Column(
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  TextField(
                    controller:
                        msgController, // use this controller to get the input text
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter message',
                    ),
                  ),
                  TextButton(
                    child: Text('Send'),
                    onPressed: () {
                      sendWhatsAppMessage('97336064978', msgController.text);
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(messages[index]['body']),
                          subtitle: Text(
                              'From: ${messages[index]['from']}\nTime: ${messages[index]['time']}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
