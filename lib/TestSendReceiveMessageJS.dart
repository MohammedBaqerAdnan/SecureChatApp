/*
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
  String userID = 'user1'; // Add user's ID here

  @override
  void initState() {
    super.initState();
    initializeWhatsAppClient();
    getQrData(userID);
    getMessages();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      getMessages();
    });
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      getQrData(userID);
    });
  }

/*
  Future<void> initializeWhatsAppClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('firstTime') ?? true;
    if (firstTime) {
      try {
        final response = await http.post(
          Uri.parse('${ipAddressForAPI}/start-whatsapp'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'userID': userID,
          }),
        );
        print('WhatsApp client started: ${response.body}');
        await prefs.setBool('firstTime', false);
      } catch (e) {
        print('Error occurred: $e');
      }
    }
  }
*/

  Future<void> initializeWhatsAppClient() async {
    try {
      final response = await http.post(
        Uri.parse('${ipAddressForAPI}/start-whatsapp'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userID': userID,
        }),
      );
      print('WhatsApp client started: ${response.body}');
    } catch (e) {
      print('Error occurred: $e');
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
          'userID': userID,
          'num': number,
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

  Future<void> getQrData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ipAddressForAPI}/get-qr?userID=' + userId),
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

/*
Future getQrCode(String userId) async {
    final response = await http.get(
      Uri.parse('http://your_server_address/get-qr?userID=' + userId),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);
    } else {
      // If the server returns an unexpected response,
      // then throw an exception.
      throw Exception('Failed to get QR code');
    }
}

*/

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
                      sendWhatsAppMessage('97333057881', msgController.text);
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

*/

// original solution with single user
/*

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
  String ipAddressForAPI = 'http://192.168.100.11:3000';
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

  // Future<void> initializeWhatsAppClient() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool firstTime = prefs.getBool('firstTime') ?? true;
  //   if (firstTime) {
  //     try {
  //       final response = await http.get(
  //         Uri.parse('${ipAddressForAPI}/start-whatsapp'),
  //       );
  //       print('WhatsApp client started: ${response.body}');
  //       await prefs.setBool('firstTime', false);
  //     } catch (e) {
  //       print('Error occurred: $e');
  //     }
  //   }
  // }

  Future<void> initializeWhatsAppClient() async {
    try {
      final response = await http.get(
        Uri.parse('${ipAddressForAPI}/start-whatsapp'),
      );
      print('WhatsApp client started: ${response.body}');
    } catch (e) {
      print('Error occurred: $e');
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
*/

// with uniqueId solution to achive multiple users
/*
import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
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
  String ipAddressForAPI = 'http://192.168.100.10:3000';
  final TextEditingController msgController =
      TextEditingController(); // use this controller to get the input text
  String uniqueId = '';

  @override
  void initState() {
    super.initState();
    _setupUniqueId().then((_) {
      // It is necessary to complete this before moving onto the next step
      initializeWhatsAppClient(); // Now userId = uniqueId should be defined.
    });
    getQrData();
    getMessages();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      getMessages();
    });
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      getQrData();
    });
  }

// Now _setupUniqueId is an async function and it return a Future
  Future<void> _setupUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uniqueId = prefs.getString('uniqueId') ?? Uuid().v1();
    prefs.setString('uniqueId', uniqueId);
  }

  Future<void> initializeWhatsAppClient() async {
    print('${ipAddressForAPI}/start-whatsapp?userId=$uniqueId');
    try {
      final response = await http.get(
        Uri.parse('${ipAddressForAPI}/start-whatsapp?userId=$uniqueId'),
      );
      print('WhatsApp client started: ${response.body}');
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void sendWhatsAppMessage(String number, String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ipAddressForAPI}/send-message?userId=$uniqueId'),
        headers: <String, String>{
          'Content-Type': 'application/json;charset=UTF-8',
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
        Uri.parse('${ipAddressForAPI}/get-qr?userId=$uniqueId'),
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
        Uri.parse('${ipAddressForAPI}/get-messages?userId=$uniqueId'),
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
*/

///////

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';

void main() {
  runApp(AppController(child: MyApp()));
}

class AppController extends StatefulWidget {
  final Widget child;

  AppController({Key? key, required this.child}) : super(key: key);

  static _AppControllerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AppControllerState>();
  }

  @override
  _AppControllerState createState() => _AppControllerState();
}

///

// class KeepAliveExpansionTile extends StatefulWidget {
//   final String number;
//   final List<Map<String, dynamic>> messages;

//   KeepAliveExpansionTile({required this.number, required this.messages});

//   @override
//   _KeepAliveExpansionTileState createState() => _KeepAliveExpansionTileState();
// }

// class _KeepAliveExpansionTileState extends State<KeepAliveExpansionTile>
//     with AutomaticKeepAliveClientMixin {
//   final cacheManager = DefaultCacheManager();

//   @override
//   bool get wantKeepAlive => true;

//   Future<File> _loadImage(int index, [String? base64String]) async {
//     if (base64String == null) {
//       // If the base64String is null, return a placeholder image
//       return File('assets/images/placeholder.jpg');
//     }

//     final filename = '$index.jpg';
//     Directory tempDir = await getTemporaryDirectory();
//     String tempPath = tempDir.path;
//     File file = File('$tempPath/$filename');

//     bool fileExists = await file.exists();

//     if (!fileExists) {
//       final bytes = base64Decode(base64String);
//       file = await file.writeAsBytes(bytes);
//     }

//     return file;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // This is required if wantKeepAlive is overridden.
//     return ExpansionTile(
//       key: PageStorageKey<String>(widget.number),
//       title: Text(widget.number),
//       children: widget.messages.asMap().entries.map((entry) {
//         int index = entry.key;
//         Map<String, dynamic> message = entry.value;
//         return FutureBuilder<File>(
//           future: _loadImage(
//               index,
//               message['media']?.contains(',') == true
//                   ? message['media'].split(",")[1]
//                   : null),
//           builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               if (snapshot.hasError)
//                 return Icon(Icons.error);
//               else
//                 return ListTile(
//                   title: Text(message['body']),
//                   subtitle: Text('At: ${message['time']}'),
//                   trailing: Image.file(snapshot.data!),
//                 );
//             } else {
//               return CircularProgressIndicator(); // Placeholder image or a loader until the image is decoded
//             }
//           },
//         );
//       }).toList(),
//     );
//   }
// }

///

class _AppControllerState extends State<AppController> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: key,
      home: widget.child,
    );
  }
}

class MessageList extends StatefulWidget {
  final List<Map<String, dynamic>> messages;

  MessageList({required this.messages});

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList>
    with AutomaticKeepAliveClientMixin<MessageList> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Map<String, List<Map<String, dynamic>>> groupedMessages = {};

    widget.messages.forEach((message) {
      String from = message['from'];
      if (groupedMessages.containsKey(from)) {
        groupedMessages[from]!.add(message);
      } else {
        groupedMessages[from] = [message];
      }
    });

    return ListView.builder(
      itemCount: groupedMessages.keys.length,
      itemBuilder: (context, index) {
        String number = groupedMessages.keys.elementAt(index);
        return ExpansionTile(
          title: Text(number),
          children: groupedMessages[number]!.map((message) {
            return ListTile(
              title: message['media'] == null || !message['media'].contains(',')
                  ? Text(message['body'])
                  : Column(
                      children: <Widget>[
                        Text(message['body']),
                        Image.memory(
                            base64Decode(message['media'].split(",")[1])),
                      ],
                    ),
              subtitle: Text('At: ${message['time']}'),
            );
          }).toList(),
        );
      },
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isActive = true;
  String qrData = 'Loading QR Data...';
  List<Map<String, dynamic>> messages = [];
  Timer? timer;
  String ipAddressForAPI = 'http://192.168.100.10:3000';
  final TextEditingController msgController =
      TextEditingController(); // use this controller to get the input text
  String uniqueId = '';
  late SharedPreferences prefs;

  StreamSubscription? messageSubscription;
  @override
  void initState() {
    _isActive = true;
    super.initState();

    _setupUniqueId().then((_) {
      // It is necessary to complete this before moving onto the next step
      _loadState().then((_) {
        //print unique id
        print("Unique" + uniqueId);
        initializeWhatsAppClient(); // Now userId = uniqueId should be defined.
        getMessages();
        timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
          getMessages();
        });
        // messageSubscription = getMessages().listen((newMessages) {
        //   setState(() {
        //     messages.addAll(newMessages);
        //     prefs.setString('messages', jsonEncode(messages));
        //   });
        // });
      });
    });
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      getQrData();
    });
  }

  Future<void> _loadState() async {
    prefs = await SharedPreferences.getInstance();
    uniqueId = prefs.getString('uniqueId') ?? '';
    messages = List<Map<String, dynamic>>.from(
        jsonDecode(prefs.getString('messages') ?? '[]'));
  }

  Future<void> _setupUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uniqueId');
    if (storedId == null) {
      uniqueId = Uuid().v1();
      prefs.setString('uniqueId', uniqueId);
      prefs.setBool('whatsappInitialized', false);
    } else {
      uniqueId = storedId;
    }
  }

  Future<void> initializeWhatsAppClient() async {
    final initialized = prefs.getBool('whatsappInitialized') ?? false;
    if (!initialized) {
      print('${ipAddressForAPI}/start-whatsapp?userId=$uniqueId');
      try {
        final response = await http.get(
          Uri.parse('${ipAddressForAPI}/start-whatsapp?userId=$uniqueId'),
        );
        print('WhatsApp client started: ${response.body}');
        prefs.setBool('whatsappInitialized', true);
      } catch (e) {
        print('Error occurred: $e');
      }
    }
  }

  Future<void> resetInitialization() async {
    // prefs.setBool('whatsappInitialized', false);
    // print('WhatsApp initialization reset.');
    // AppController.of(context)?.restartApp();
    // Call the reset endpoint
    final response = await http
        .get(Uri.parse('${ipAddressForAPI}/reset-whatsapp?userId=$uniqueId'));
    print('WhatsApp client reset: ${response.body}');

    prefs.setBool('whatsappInitialized', false);
    print('WhatsApp initialization reset.');

    AppController.of(context)?.restartApp();
  }

  void sendWhatsAppMessage(String number, String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ipAddressForAPI}/send-message?userId=$uniqueId'),
        headers: <String, String>{
          'Content-Type': 'application/json;charset=UTF-8',
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
    _isActive = false;
    msgController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> getQrData() async {
    try {
      final response = await http.get(
        Uri.parse('${ipAddressForAPI}/get-qr?userId=$uniqueId'),
      );
      if (response.statusCode == 200) {
        if (_isActive && mounted) {
          setState(() {
            qrData = jsonDecode(response.body)['qr'];
          });
        }
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
        Uri.parse('${ipAddressForAPI}/get-messages?userId=$uniqueId'),
      );
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> newMessages =
            List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['messages'],
        );
        if (_isActive && mounted) {
          setState(() {
            messages.addAll(newMessages.where((i) => !messages.contains(i)));
            prefs.setString('messages', jsonEncode(messages));
          });
        }
      } else {
        print('Failed to load Messages.');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void clearMessages() {
    setState(() {
      messages.clear();
      prefs.setString('messages', jsonEncode(messages));
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedMessages = {};

    messages.forEach((message) {
      String from = message['from'];
      if (groupedMessages.containsKey(from)) {
        groupedMessages[from]!.add(message);
      } else {
        groupedMessages[from] = [message];
      }
    });
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
                  ElevatedButton(
                    onPressed: resetInitialization,
                    child: Text('Reset WhatsApp Initialization'),
                  ),
                  ElevatedButton(
                    onPressed: clearMessages,
                    child: Text('Clear Messages'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: groupedMessages.keys.length,
                      itemBuilder: (context, index) {
                        String number = groupedMessages.keys.elementAt(index);
                        return ExpansionTile(
                          title: Text(number),
                          children: groupedMessages[number]!.map((message) {
                            return ListTile(
                              title: message['media'] == null ||
                                      !message['media'].contains(',')
                                  ? Text(message['body'])
                                  : Column(
                                      children: <Widget>[
                                        Text(message['body']),
                                        Image.memory(base64Decode(
                                            message['media'].split(",")[1])),
                                      ],
                                    ),
                              subtitle: Text('At: ${message['time']}'),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    // child: ListView.builder(
                    //   itemCount: groupedMessages.keys.length,
                    //   itemBuilder: (context, index) {
                    //     String number = groupedMessages.keys.elementAt(index);
                    //     return KeepAliveExpansionTile(
                    //       number: number,
                    //       messages: groupedMessages[number]!,
                    //     );
                    //   },
                    // ),
                  )
                ],
              ),
      ),
    );
  }
}










































///// 2nd solution modified

/*

import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
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
  String ipAddressForAPI = 'http://192.168.100.46:3000';
  final TextEditingController msgController =
      TextEditingController(); // use this controller to get the input text
  String uniqueId = '';
  late SharedPreferences prefs;

  bool qrScanned = false; // add a boolean to track QR scanning status

  @override
  void initState() {
    super.initState();
    _setupUniqueId().then((_) {
      // It is necessary to complete this before moving onto the next step
      _loadState().then((_) {
        //print unique id
        print("Unique" + uniqueId);
        if (uniqueId != '' && qrScanned) {
          // check for successful QR scanning here
          initializeWithRetry(); // Now userId = uniqueId should be defined.
          getMessages();
          timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
            getMessages();
          });
        }
      });
    });
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      getQrData();
    });
  }

  Future<void> _loadState() async {
    prefs = await SharedPreferences.getInstance();
    uniqueId = prefs.getString('uniqueId') ?? '';
    messages = List<Map<String, dynamic>>.from(
        jsonDecode(prefs.getString('messages') ?? '[]'));
  }

// Now _setupUniqueId is an async function and it return a Future
  Future<void> _setupUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uniqueId = prefs.getString('uniqueId') ?? Uuid().v1();
    prefs.setString('uniqueId', uniqueId);
  }

  Future<bool> initializeWhatsAppClient() async {
    final initialized = prefs.getBool('whatsappInitialized') ?? false;
    if (!initialized) {
      print('${ipAddressForAPI}/start-whatsapp?userId=$uniqueId');
      try {
        final response = await http.get(
          Uri.parse('${ipAddressForAPI}/start-whatsapp?userId=$uniqueId'),
        );
        if (response.statusCode == 200) {
          print('WhatsApp client started: ${response.body}');
          prefs.setBool('whatsappInitialized', true);
          return true;
        } else {
          print('Failed to initialize WhatsApp client');
          return false;
        }
      } catch (e) {
        print('Error occurred: $e');
        return false;
      }
    }
    return true;
  }

  void initializeWithRetry() {
    initializeWhatsAppClient().then((initSuccess) {
      if (initSuccess) {
        getMessages();
        timer?.cancel(); // Cancel the QR fetching timer
        timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
          getMessages();
        });
      } else {
        print('Failed to initialize WhatsApp client, retrying in 10 seconds');
        Timer(Duration(seconds: 10), initializeWithRetry);
      }
    });
  }

  void sendWhatsAppMessage(String number, String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ipAddressForAPI}/send-message?userId=$uniqueId'),
        headers: <String, String>{
          'Content-Type': 'application/json;charset=UTF-8',
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
        Uri.parse('${ipAddressForAPI}/get-qr?userId=$uniqueId'),
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
        Uri.parse('${ipAddressForAPI}/get-messages?userId=$uniqueId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          messages.addAll(List<Map<String, dynamic>>.from(
            jsonDecode(response.body)['messages'],
          ));
          prefs.setString('messages', jsonEncode(messages));
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
                      sendWhatsAppMessage('97335669580', msgController.text);
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

*/
