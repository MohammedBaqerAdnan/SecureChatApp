// import 'package:flutter/material.dart';

// class ContactPage extends StatelessWidget {
//   final String contact;
//   final List<Map<String, dynamic>> messages;

//   ContactPage({required this.contact, required this.messages});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with $contact'),
//       ),
//       body: ListView.builder(
//         itemCount: messages.length,
//         itemBuilder: (BuildContext context, int index) {
//           return ListTile(
//             title: Text(messages[index]['body']),
//             subtitle: Text('${messages[index]['timestamp']}'),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'dart:async';

// import 'package:flutter/material.dart';

// class ContactPage extends StatefulWidget {
//   final String contact;
//   final Stream<List<Map<String, dynamic>>> messages;

//   ContactPage({required this.contact, required this.messages});

//   @override
//   _ContactPageState createState() => _ContactPageState();
// }

// class _ContactPageState extends State<ContactPage> {
//   List<Map<String, dynamic>> messages = [];
//   StreamSubscription? _messageStreamSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _messageStreamSubscription = widget.messages.listen((newMessages) {
//       setState(() {
//         messages = newMessages;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _messageStreamSubscription!.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.contact.split('@')[0]} Chat'),
//       ),
//       body: ListView.builder(
//         itemCount: messages.length,
//         itemBuilder: (BuildContext context, int index) {
//           return ListTile(
//             title: Text(messages[index]['body']),
//             subtitle: Text('${messages[index]['timestamp']}'),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ContactPage extends StatefulWidget {
//   final String contact;
//   final Stream<List<Map<String, dynamic>>> messages;

//   ContactPage({required this.contact, required this.messages});

//   @override
//   _ContactPageState createState() => _ContactPageState();
// }

// class _ContactPageState extends State<ContactPage> {
//   List<Map<String, dynamic>> messages = [];
//   StreamSubscription? _messageStreamSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _messageStreamSubscription = widget.messages.listen((newMessages) {
//       setState(() {
//         messages = newMessages.reversed
//             .toList(); // Reverse the messages list so newer messages are displayed at the bottom
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _messageStreamSubscription!.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userFromValue = '${widget.contact.split('@')[0]}@c.us';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.contact.split('@')[0]} Chat'),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: messages.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   final messageData = messages[index];
//                   final isMe = messageData.keys.first == 'from' &&
//                       messageData['from'] == userFromValue;

//                   return Padding(
//                     padding: EdgeInsets.only(
//                         top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
//                     child: Column(
//                       crossAxisAlignment: isMe
//                           ? CrossAxisAlignment.end
//                           : CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Material(
//                           borderRadius: isMe
//                               ? BorderRadius.only(
//                                   topLeft: Radius.circular(30.0),
//                                   bottomLeft: Radius.circular(30.0),
//                                   bottomRight: Radius.circular(30.0))
//                               : BorderRadius.only(
//                                   topRight: Radius.circular(30.0),
//                                   bottomLeft: Radius.circular(30.0),
//                                   bottomRight: Radius.circular(30.0)),
//                           elevation: 5.0,
//                           color: isMe ? Colors.lightBlueAccent : Colors.white,
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(
//                                 vertical: 10.0, horizontal: 20.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 Text(
//                                   messageData['body'],
//                                   style: TextStyle(
//                                       color:
//                                           isMe ? Colors.white : Colors.black54,
//                                       fontSize: 15.0),
//                                 ),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   DateFormat('kk:mm dd/MM/yyyy').format(
//                                       DateTime.parse(messageData[
//                                           'time'])), // format the timestamp
//                                   style: TextStyle(
//                                       fontSize: 10.0, color: Colors.black38),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContactPage extends StatefulWidget {
  final String contact;
  final Stream<List<Map<String, dynamic>>> messages;

  ContactPage({required this.contact, required this.messages});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Map<String, dynamic>> messages = [];
  StreamSubscription? _messageStreamSubscription;

  @override
  void initState() {
    super.initState();
    _messageStreamSubscription = widget.messages.listen((newMessages) {
      newMessages.sort((a, b) =>
          DateTime.parse(a['time']).compareTo(DateTime.parse(b['time'])));
      setState(() {
        messages = newMessages;
      });
    });
  }

  @override
  void dispose() {
    _messageStreamSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userFromValue = '${widget.contact.split('@')[0]}@c.us';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.contact.split('@')[0]} Chat'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final messageData = messages[index];
                  final isMe = messageData.keys.first == 'from' &&
                      messageData['from'] == userFromValue;

                  return Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        Material(
                          borderRadius: isMe
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  bottomLeft: Radius.circular(30.0),
                                  bottomRight: Radius.circular(30.0))
                              : BorderRadius.only(
                                  topRight: Radius.circular(30.0),
                                  bottomLeft: Radius.circular(30.0),
                                  bottomRight: Radius.circular(30.0)),
                          elevation: 5.0,
                          color: isMe ? Colors.lightBlueAccent : Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  messageData['body'],
                                  style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black54,
                                      fontSize: 15.0),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  DateFormat('kk:mm dd/MM/yyyy').format(
                                      DateTime.parse(messageData[
                                          'time'])), // format the timestamp
                                  style: TextStyle(
                                      fontSize: 10.0, color: Colors.black38),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
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
