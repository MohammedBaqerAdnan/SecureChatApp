import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'EncryptionUtils.dart';
import 'ContactPage.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ChatPage extends StatefulWidget {
  ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController msgController = TextEditingController();

  SharedPreferences? _prefs;
  String ipAddressForAPI = 'http://192.168.100.10:3000';
  String _vigenereKey = "";
  String _selectedContactNumber = "";
  String _userId = "";
  Timer? _timer;
  Timer? timer;
  List<Map<String, dynamic>> messages = [];
  StreamController<List<Map<String, dynamic>>> globalMessageStreamController =
      StreamController.broadcast();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    _loadPreferences().then((_) {
      _startTimer();
      getMessages();
      initializeTimezone(); // call the separate function here instead.
      timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
        getMessages();
      });
    });
  }

  void initializeTimezone() async {
    // the separate function can be async
    tz.initializeTimeZones();
    final location = tz.getLocation('Asia/Bahrain');
    tz.setLocalLocation(location);
  }

  @override
  void dispose() {
    _timer?.cancel();
    timer?.cancel();
    super.dispose();
    msgController.dispose();
  }

  void sendWhatsAppMessage(String number, String message) async {
    try {
      // Encrypt the message before sending
      String encryptedMessage = vigenere(message, _vigenereKey, 1);
      final response = await http.post(
        Uri.parse('${ipAddressForAPI}/send-message?userId=$_userId'),
        headers: <String, String>{
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'num':
              number, // replace this with the WhatsApp number you want to send to
          'message': encryptedMessage,
        }),
      );
      setState(() {
        messages.insert(0, {
          'from': _selectedContactNumber +
              '@c.us', // Or replace this with user's number
          'body': message,
          'time': tz.TZDateTime.now(tz.local).toIso8601String()
        });
        _prefs!.setString('messages', jsonEncode(messages));
        globalMessageStreamController.add(messages);
      });
      print('Message sent: ${response.body}');
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  String formatTimestamp(String timestamp) {
    var date = DateTime.parse(timestamp);
    date = date.add(Duration(hours: 3)); // Add 3 hours to the original time
    return DateFormat('MMM d, yyyy - HH:mm').format(date).toString();
  }

  Future<void> getMessages() async {
    try {
      final response = await http.get(
        Uri.parse('${ipAddressForAPI}/get-messages?userId=$_userId'),
      );
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> newMessages =
            List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['messages'],
        );
        print('Decoded messages: $newMessages');
        if (mounted) {
          setState(() {
            newMessages.forEach((message) {
              message['body'] = vigenere(message['body'], _vigenereKey, 0);
            });
            messages.addAll(newMessages.where((i) => !messages.contains(i)));
            globalMessageStreamController
                .add(messages); // Add this line after you update messages
            _prefs!.setString('messages', jsonEncode(messages));
            print('Updated messages list: $messages');
          });
        }
      } else {
        print('Failed to load Messages.');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Map<String, List<Map<String, dynamic>>> groupMessages() {
    return Map.fromEntries(
        messages.fold<List<MapEntry<String, List<Map<String, dynamic>>>>>(
      [],
      (previous, message) {
        var from = message['from'];
        previous.add(MapEntry(
            from,
            previous
                .firstWhere((entry) => entry.key == from,
                    orElse: () => MapEntry(from, []))
                .value
              ..add(message)));
        return previous;
      },
    ));
  }

  // Start timer
  void _startTimer() {
    if (mounted) {
      setState(() {
        _timer = Timer.periodic(Duration(seconds: 10), (timer) {
          print("Vigenere Key: $_vigenereKey");
          print("Contact Number: $_selectedContactNumber");
          print("Message: ${msgController.text}");
          print("ID: ${_userId}");
        });
      });
    }
  }

  // load settings
  _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _vigenereKey = _prefs!.getString("vigenereKey") ?? "";
    _selectedContactNumber = _prefs!.getString("selectedContactNumber") ?? "";

    _userId = _prefs!.getString("uniqueId") ?? "";
    String? savedMessages = _prefs!.getString('messages');
    if (savedMessages != null) {
      // If there are saved messages then load them
      messages = List<Map<String, dynamic>>.from(jsonDecode(savedMessages));
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedMessages = groupMessages();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Page'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              // Add your message clearing logic here
              _prefs!.remove('messages');
              setState(() {
                messages.clear();
                globalMessageStreamController.add(messages);
              });
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              // itemCount: messages.length,
              itemCount: groupedMessages.length,
              itemBuilder: (BuildContext context, int index) {
                String from = groupedMessages.keys.elementAt(index);
                String fromEdit =
                    groupedMessages.keys.elementAt(index).split('@')[0];

                return ListTile(
                  // leading: Icon(Icons.contact_phone),
                  leading: CircleAvatar(
                    child: Icon(Icons.contact_phone),
                  ),
                  title: Text(fromEdit,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      groupedMessages[from] != null &&
                              groupedMessages[from]!.isNotEmpty
                          ? '${groupedMessages[from]!.last['body']}' // Showing the latest message
                          : '', // Show empty string if no message
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  trailing: Text(
                    groupedMessages[from] != null &&
                            groupedMessages[from]!.isNotEmpty
                        ? formatTimestamp(
                            '${groupedMessages[from]!.last['time']}')
                        : '',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w300),
                  ),
                  tileColor: Colors.white,
                  onTap: () {
                    if (groupedMessages[from] != null &&
                        groupedMessages[from]!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactPage(
                            contact: from,
                            // messages: groupedMessages[from]!,
                            messages: globalMessageStreamController.stream,
                          ),
                        ),
                      );
                    } else {
                      print("No messages to display for this contact.");
                    }
                  },
                );
              },
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () async {
                  ImagePicker picker = ImagePicker();
                  XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);

                  if (image != null) {
                    // Add your image sending logic here
                  }
                },
              ),
              Expanded(
                child: TextField(
                  controller: msgController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a message',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (msgController.text.isNotEmpty) {
                    // Add your message sending logic here
                    sendWhatsAppMessage(
                        _selectedContactNumber, msgController.text);
                  } else {
                    print("No message entered.");
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
