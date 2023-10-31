import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

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
  String ipAddrssForAPI = 'http://192.168.100.7:3000';

  @override
  void initState() {
    super.initState();
    getQrData();
    getMessages();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      getMessages();
    });
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      getQrData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> getQrData() async {
    try {
      final response = await http.get(
        Uri.parse('${ipAddrssForAPI}/get-qr'),
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
        Uri.parse('${ipAddrssForAPI}/get-messages'),
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
