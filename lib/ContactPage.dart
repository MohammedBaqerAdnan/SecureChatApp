// import 'dart:async';
// import 'CurvedAppBar.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:timezone/data/latest.dart' as tz; // This is your import
// import 'package:timezone/timezone.dart' as tz; // This is your import

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
//       newMessages.sort((a, b) =>
//           DateTime.parse(a['time']).compareTo(DateTime.parse(b['time'])));
//       setState(() {
//         messages = newMessages;
//       });
//     });
//     initializeTimezone();
//   }

//   @override
//   void dispose() {
//     _messageStreamSubscription!.cancel();
//     super.dispose();
//   }

//   void initializeTimezone() async {
//     tz.initializeTimeZones();
//     var bahrain = tz.getLocation('Asia/Bahrain');
//     tz.setLocalLocation(bahrain);
//   }

//   String formatTimestamp(String timestamp) {
//     var date = tz.TZDateTime.parse(tz.local, timestamp);
//     return DateFormat('MMM d, yyyy - HH:mm').format(date).toString();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userFromValue = '${widget.contact.split('@')[0]}@c.us';

//     return Scaffold(
//       appBar: CurvedAppBar(
//         title: '${widget.contact.split('@')[0]} Chat',
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
//                                   // DateFormat('kk:mm dd/MM/yyyy').format(
//                                   //     DateTime.parse(messageData[
//                                   //         'time'])), // format the timestamp
//                                   formatTimestamp(messageData[
//                                       'time']), // call the new function here
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
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'CurvedAppBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz; // This is your import
import 'package:timezone/timezone.dart' as tz; // This is your import

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
  Map<String, String> _imagePathCache = {}; // new
  Map<String, Future<String>> _imageDecryptionFutures = {};

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
    initializeTimezone();
  }

  @override
  void dispose() {
    _messageStreamSubscription!.cancel();
    super.dispose();
  }

  void initializeTimezone() async {
    tz.initializeTimeZones();
    var bahrain = tz.getLocation('Asia/Bahrain');
    tz.setLocalLocation(bahrain);
  }

  String formatTimestamp(String timestamp) {
    var date = tz.TZDateTime.parse(tz.local, timestamp);
    return DateFormat('MMM d, yyyy - HH:mm').format(date).toString();
  }

  ValueNotifier<Map<String, String>> imageCacheNotifier = ValueNotifier(Map());

  Future<void> decryptImage(String imageData) async {
    if (!imageCacheNotifier.value.containsKey(imageData)) {
      final response = await http.post(
        Uri.parse('http://192.168.100.10:3000/decrypt-file'),
        headers: <String, String>{
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'imageData': imageData,
        }),
      );

      if (response.statusCode == 200) {
        String decryptedImageData = jsonDecode(response.body)['imageData'];
        var bytes = base64Decode(decryptedImageData.split(",")[1]);
        String dir = (await getApplicationDocumentsDirectory()).path;
        String imageName =
            'decrypt_image${DateTime.now().millisecondsSinceEpoch}.png';
        File file = new File('$dir/$imageName');
        await file.writeAsBytes(bytes);
        if (await file.exists()) {
          imageCacheNotifier.value[imageData] = file.path;
          imageCacheNotifier
              .notifyListeners(); // Notifying the listeners in case of a successful decryption
        }
      } else {
        throw Exception('Failed to decrypt image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userFromValue = '${widget.contact.split('@')[0]}@c.us';

    return Scaffold(
      appBar: CurvedAppBar(
        title: '${widget.contact.split('@')[0]} Chat',
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
                  var imageDataFuture = messageData['isMediaMessage'] != null &&
                          messageData['isMediaMessage']
                      ? decryptImage(messageData['media'])
                      : null;

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
                                  formatTimestamp(messageData[
                                      'time']), // call the new function here
                                  style: TextStyle(
                                      fontSize: 10.0, color: Colors.black38),
                                ),
// Check if condition is met, return widget if true, otherwise return empty container
                                ...(imageDataFuture != null
                                    ? [
                                        // FutureBuilder<String>(
                                        //   future: imageDataFuture,
                                        //   builder: (BuildContext context,
                                        //       AsyncSnapshot<String> snapshot) {
                                        //     if (snapshot.connectionState !=
                                        //         ConnectionState.done)
                                        //       return CircularProgressIndicator();
                                        //     if (snapshot.hasData) {
                                        //       return Image.file(
                                        //           File(snapshot.data!));
                                        //     }
                                        //     return Container();
                                        //   },
                                        // ),
                                        ValueListenableBuilder(
                                          valueListenable:
                                              imageCacheNotifier, // Provide our ValueNotifier
                                          builder: (context,
                                              Map<String, String> imageCache,
                                              _) {
                                            // Check if the image data is in the cache.
                                            if (imageCache.containsKey(
                                                messageData['media'])) {
                                              // If it is in the cache, we use the file.
                                              return Image.file(File(imageCache[
                                                  messageData['media']]!));
                                            } else {
                                              // If it's not in the cache, we return a progress indicator and kick off the decryption.
                                              WidgetsBinding.instance!
                                                  .addPostFrameCallback((_) {
                                                decryptImage(
                                                    messageData['media']);
                                              });
                                              return CircularProgressIndicator();
                                            }
                                          },
                                        ),
                                      ]
                                    : []),
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
