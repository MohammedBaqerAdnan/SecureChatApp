import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'EncryptionUtils.dart';

//
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:contacts_service/contacts_service.dart';
//

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
  final TextEditingController vigenereKeyController = TextEditingController();
  String uniqueId = '';
  late SharedPreferences prefs;

  StreamSubscription? messageSubscription;
  @override
  void initState() {
    _isActive = true;
    super.initState();
    _setupUniqueId().then((_) {
      _storeVigenereKey(vigenereKeyController.text).then((_) {
        _loadState().then((_) {
          print("Unique" + uniqueId);
          initializeWhatsAppClient(); // Now userId = uniqueId should be defined.
          getMessages();
          timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
            getMessages();
          });
        });
      });
    });
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      getQrData();
    });
  }

  //   _setupUniqueId().then((_) {
  //     // It is necessary to complete this before moving onto the next step
  //     _loadState().then((_) {
  //       //print unique id
  //       print("Unique" + uniqueId);
  //       initializeWhatsAppClient(); // Now userId = uniqueId should be defined.
  //       getMessages();
  //       timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
  //         getMessages();
  //       });
  //     });
  //   });
  //   timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
  //     getQrData();
  //   });
  // }

  Future<void> _loadState() async {
    prefs = await SharedPreferences.getInstance();
    uniqueId = prefs.getString('uniqueId') ?? '';
    messages = List<Map<String, dynamic>>.from(
        jsonDecode(prefs.getString('messages') ?? '[]'));
    vigenereKeyController.text =
        prefs.getString('vigenereKey') ?? ''; // Load the saved Vigenere key
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
      // Encrypt the message before sending
      String encryptedMessage =
          vigenere(message, vigenereKeyController.text, 1);
      final response = await http.post(
        Uri.parse('${ipAddressForAPI}/send-message?userId=$uniqueId'),
        headers: <String, String>{
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'num':
              number, // replace this with the WhatsApp number you want to send to
          'message': encryptedMessage,
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
    vigenereKeyController.dispose();
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
            // Decrypt each message
            print("Vigenere key: " + vigenereKeyController.text);
            newMessages.forEach((message) {
              print('Encrypted: ${message['body']}');
              message['body'] =
                  vigenere(message['body'], vigenereKeyController.text, 0);
              print('Decrypted: ${message['body']}');
            });
            print("New messages: " + newMessages.toString());
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

  Future<String> saveImage(String base64Image) async {
    var dir = await getApplicationDocumentsDirectory();
    var imageName = Uuid().v1();
    String imagePath = '${dir.path}/$imageName.png';

    var imageBytes = base64Decode(base64Image.split(",")[1]);
    var result = await FlutterImageCompress.compressWithList(
      imageBytes,
      minWidth: 1080,
      minHeight: 1920,
      quality: 96,
      rotate: 0, // adjust this line, rotate: 0 instead of rotate: 180
    );

    final writeImageCreation = File(imagePath).writeAsBytes(result);
    await writeImageCreation;
    // confirm image write to local storage
    if (await File(imagePath).exists()) {
      return imagePath;
    } else {
      throw Exception('Save image failed.');
    }
  }

  //
  Future<Iterable<Contact>> getDeviceContacts() async {
    final PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      return await ContactsService.getContacts();
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
    return [];
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.limited;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to contact data denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      throw PlatformException(
          code: "PERMISSION_PERMANENTLY_DENIED",
          message: "Contact data not allowed",
          details: null);
    }
  }

  void selectContactAndSendWhatsAppMessage(String message) async {
    Iterable<Contact> contacts = await getDeviceContacts();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Select a Contact'),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            children: contacts.map<Widget>((contact) {
              return ListTile(
                title: Text(contact.displayName!),
                onTap: () {
                  Navigator.pop(context);
                  // Assuming the country code is for Bahrain (973)
                  var countryCode = "973";
                  // Obtaining the phone number, eliminating all spaces and any preceding 973
                  var phoneNumber = contact.phones!.first.value!
                      .replaceAll(" ", "")
                      .replaceFirst("+973", "")
                      .replaceFirst("973", "");

                  // Unconditionally prepend our own 973 since we've just removed any existing ones
                  phoneNumber = countryCode + phoneNumber;

                  print("DODO");
                  print("Selected phone number is " + phoneNumber);

                  // Then pass the updated phone number to the sendWhatsAppMessage method
                  sendWhatsAppMessage(phoneNumber, message);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String selectedContactNumber = '';

  void selectContact() async {
    Iterable<Contact> contacts = await getDeviceContacts();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Select a Contact'),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            children: contacts.map<Widget>((contact) {
              return ListTile(
                title: Text(contact.displayName!),
                onTap: () {
                  var countryCode = "973";
                  var phoneNumber = contact.phones!.first.value!
                      .replaceAll(" ", "")
                      .replaceFirst("+973", "")
                      .replaceFirst("973", "");

                  phoneNumber = countryCode + phoneNumber;

                  selectedContactNumber = phoneNumber;

                  print("Selected contact number is " + selectedContactNumber);

                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  //

// This function will return the local file path if it exists,
// else it will download the image, save it to local storage, and then return the local file path.
  Future<String> getLocalImagePath(String base64Image) async {
    // Create a hash of the base64 image string to use as a unique lookup key
    var base64ImageHash = base64Image.hashCode;

    // Check if the image path is already saved
    String? savedImagePath = prefs.getString(base64ImageHash.toString());
    if (savedImagePath != null && await File(savedImagePath).exists()) {
      // If the image file already exists, then return the saved image path.
      return savedImagePath;
    } else {
      // If the image file does not exist then save the image and return the new path.
      String newImagePath = await saveImage(base64Image);
      // Save the new image path
      await prefs.setString(base64ImageHash.toString(), newImagePath);
      return newImagePath;
    }
  }

  Future<void> _storeVigenereKey(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedKey = prefs.getString('vigenereKey');
    if (storedKey == null || storedKey.isEmpty) {
      if (key.isNotEmpty) {
        // Only store a new key if it is not empty
        prefs.setString('vigenereKey', key);
      }
    }
  }

  void clearMessages() {
    setState(() {
      messages.clear();
      prefs.setString('messages', jsonEncode(messages));
    });
  }

  //

  //

  void sendWhatsAppMediaMessage(String number, String message) async {
    final picker = ImagePicker();
    // final pickedFile = await picker.ImagePicker(source: ImageSource.gallery);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      try {
        final response = await http.post(
          Uri.parse('${ipAddressForAPI}/send-media-message?userId=$uniqueId'),
          headers: <String, String>{
            'Content-Type': 'application/json;charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'num': number,
            'message': message,
            'mediaBase64': base64Image
          }),
        );
        print('Media message sent: ${response.body}');
      } catch (e) {
        print('Error occurred: $e');
      }
    } else {
      print('No image selected.');
    }
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
                  TextFormField(
                    controller: vigenereKeyController,
                    decoration: InputDecoration(
                      labelText: 'Enter a Vigenere key',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Vigenere key';
                      }
                      return null;
                    },
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
                      if (msgController.text.isNotEmpty &&
                          selectedContactNumber.isNotEmpty) {
                        sendWhatsAppMessage(
                            selectedContactNumber, msgController.text);
                      } else {
                        print("No contact selected or message is empty.");
                      }
                    },
                  ),
                  TextButton(
                    child: Text('Upload Image'),
                    onPressed: () async {
                      try {
                        if (selectedContactNumber.isNotEmpty) {
                          try {
                            sendWhatsAppMediaMessage(selectedContactNumber, '');
                          } catch (e) {
                            print('No image selected. $e');
                          }
                        } else {
                          print("No contact selected.");
                        }
                      } catch (e) {
                        print('No image selected. $e');
                      }
                    },
                  ),
                  // Add a 'Select Contact' button in your UI
                  ElevatedButton(
                    onPressed: selectContact,
                    child: Text('Select Contact'),
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
                        return FutureBuilder<List<Widget>>(
                          future: Future.wait(
                            groupedMessages[number]!.map((message) async {
                              String? imagePath;
                              if (message['media'] != null &&
                                  message['media'].contains(',')) {
                                // imagePath = await saveImage(message['media']);
                                imagePath =
                                    await getLocalImagePath(message['media']);
                              }
                              return ListTile(
                                title: message['media'] == null ||
                                        !message['media'].contains(',')
                                    ? Text(message['body'])
                                    : Column(
                                        children: <Widget>[
                                          Text(message['body']),
                                          if (imagePath != null) ...[
                                            Image.file(File(imagePath))
                                          ],
                                        ],
                                      ),
                                subtitle: Text('At: ${message['time']}'),
                              );
                            }).toList(),
                          ),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Widget>> snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            return ExpansionTile(
                              title: Text(number),
                              children: snapshot.data!,
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
