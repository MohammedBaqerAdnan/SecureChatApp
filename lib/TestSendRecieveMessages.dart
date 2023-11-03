import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MessageSender(),
    );
  }
}

class MessageSender extends StatefulWidget {
  @override
  _MessageSenderState createState() => _MessageSenderState();
}

class _MessageSenderState extends State<MessageSender> {
  Future<String> sendMessage() async {
    var phone_number_id = "169999262855512";
    var access_token =
        "EAAFN7IE6TUABO4qp6rFaAzaSaHkKogeJ5TSnW6kR3TSMMTPcZBWg3zDvc0kNCsQevKgzMgJOWZAJwbAsureTBdxEim0ZBV8eVDgklUp18ivHky5Vtd3QJ43Y5WGWKVuRiYZC4CEO5kh2CXGxcrQJTPemBifsGhNuh8iVUgy4Qzczah0JE6JT7TKzvffwhd5ljGJGH53tBOyEnWA6YZBDl";
    var recipient_phone_number = "97333407786";
    var url = "https://graph.facebook.com/v17.0/$phone_number_id/messages";

    var headers = {
      'Authorization': 'Bearer ' + access_token,
      'Content-Type': 'application/json',
    };

    var data = {
      'messaging_product': 'whatsapp',
      'to': recipient_phone_number,
      'type': 'template',
      'template': {
        'name': 'hello_world',
        'language': {
          'code': 'en_US',
        },
      },
    };

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return 'Message sent successfully!';
    } else {
      return 'Failed to send the message.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Message'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                String result = await sendMessage();
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(result)));
              },
              child: Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MessageReceiver(),
//     );
//   }
// }

// String ipAddressForAPI = 'http://192.168.100.7:3000';

// class MessageReceiver extends StatefulWidget {
//   @override
//   _MessageReceiverState createState() => _MessageReceiverState();
// }

// class _MessageReceiverState extends State<MessageReceiver> {
//   late Future<List<Map<String, dynamic>>> messagesFuture;

//   Future<List<Map<String, dynamic>>> fetchData() async {
//     final response = await http.get(Uri.parse(
//         '$ipAddressForAPI/statuses')); // Replace with your server IP and port

//     if (response.statusCode == 200) {
//       return List<Map<String, dynamic>>.from(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load messages');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     messagesFuture = fetchData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Received Messages'),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: messagesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return ListView.builder(
//               itemCount: snapshot.data?.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return ListTile(
//                   title: Text('${snapshot.data?[index]['status']}'),
//                 );
//               },
//             );
//           } else if (snapshot.hasError) {
//             return Text('${snapshot.error}');
//           }
//           return CircularProgressIndicator(); // Show a loading spinner.
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   List<String> messages = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchMessages();
//   }

//   Future<void> fetchMessages() async {
//     final response = await http
//         .get(Uri.parse('https://rebel-quixotic-danthus.glitch.me/webhook'));
//     if (response.statusCode == 200) {
//       setState(() {
//         final decoded = json.decode(response.body);
//         final messagesData =
//             decoded['entry'][0]['changes'][0]['value']['messages'];
//         messages = messagesData
//             .map<String>((message) => message['text']['body'] as String)
//             .toList();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Retrieved Messages'),
//         ),
//         body: ListView.builder(
//           itemCount: messages.length,
//           itemBuilder: (BuildContext context, int index) {
//             return ListTile(
//               title: Text(messages[index]),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
