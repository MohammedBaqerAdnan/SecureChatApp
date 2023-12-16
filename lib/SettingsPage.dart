import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'CurvedAppBar.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final TextEditingController vigenereKeyController = TextEditingController();
  String qrData = 'Loading QR Data...';
  SharedPreferences? prefs;
  int counter = 1;
  Timer? timer;
  Timer? printTimer;
  String uniqueId = '';
  String selectedContactNumber = '';
  String ipAddressForAPI = 'http://192.168.100.10:3000';

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (mounted) {
        // Only run setState() if the widget is still in the tree
        setState(() {
          counter++;
        });
      }
    });

    _setupUniqueId().then((_) {
      _reloadValues();
      _loadVigenereKey();
      _loadSelectedContactNumber();
      _storeVigenereKey(vigenereKeyController.text).then((_) {
        initializeWhatsAppClient();
        // Starts the print timer
        printTimer = Timer.periodic(Duration(seconds: 10), (Timer t) {
          // Get the data from prefs and print
          final storedKey = prefs!.getString('vigenereKey');
          final storedId = prefs!.getString('uniqueId');
          print("Stored Vigenere Key: $storedKey");
          print("Stored Unique Id: $storedId");
          print("Contact Number: $selectedContactNumber");
        });
        timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
          getQrData();
        });
      });
    });
  }

  Future<void> _setupUniqueId() async {
    prefs = await SharedPreferences.getInstance();
    String? storedId = prefs!.getString('uniqueId');
    if (storedId == null) {
      uniqueId = Uuid().v1();
      prefs!.setString('uniqueId', uniqueId);
      prefs!.setBool('whatsappInitialized', false);
    } else {
      uniqueId = storedId;
    }
  }

  // Define reloadValues method
  void _reloadValues() {
    _loadVigenereKey();
    _loadSelectedContactNumber();
  }

  Future<void> _loadVigenereKey() async {
    String? key = prefs!.getString('vigenereKey');
    if (key != null) {
      vigenereKeyController.text = key;
    }
  }

  Future<void> _loadSelectedContactNumber() async {
    selectedContactNumber = prefs!.getString('selectedContactNumber') ?? '';
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initializeWhatsAppClient() async {
    final initialized = prefs!.getBool('whatsappInitialized') ?? false;
    if (!initialized) {
      try {
        final response = await http.get(
          Uri.parse('${ipAddressForAPI}/start-whatsapp?userId=$uniqueId'),
        );
        print('WhatsApp client started: ${response.body}');
        prefs!.setBool('whatsappInitialized', true);
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

    prefs!.setBool('whatsappInitialized', false);

    // No need to restart if it's page-specific
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  Future<void> _storeVigenereKey(String key) async {
    String? storedKey = prefs!.getString('vigenereKey');
    prefs!.setString('vigenereKey', key);

    // if (storedKey == null || storedKey.isEmpty) {
    //   if (key.isNotEmpty) {
    //     prefs!.setString('vigenereKey', key);
    //   }
    // }
  }

  Future<void> getQrData() async {
    try {
      final response = await http.get(
        Uri.parse('${ipAddressForAPI}/get-qr?userId=$uniqueId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          // qrData = response.body;
          qrData = jsonDecode(response.body)['qr'];
        });
      } else {
        print('Failed to load QR Code.');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

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
        permission != PermissionStatus.permanentlyDenied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.limited;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied ||
        permissionStatus == PermissionStatus.permanentlyDenied) {
      showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Icon(
                  Icons.error,
                  size: 60,
                  color: Colors.red,
                ),
                SizedBox(height: 10),
                Text(
                  'Permission Denied',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  permissionStatus == PermissionStatus.denied
                      ? 'You denied the contacts access permission.'
                      : 'Contact permission was denied permanently. Please grant access from App Settings.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => permissionStatus == PermissionStatus.denied
                      ? _getContactPermission()
                      : openAppSettings(),
                  child: Text(
                    'GRANT ACCESS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'DISMISS',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void selectContact() async {
    Iterable<Contact> contacts = await getDeviceContacts();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true, // makes bottom sheet fullscreen
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                20.0)), // gives the top of sheet a rounded look
        builder: (BuildContext context) => Container(
              height: MediaQuery.of(context).size.height *
                  0.7, // makes 70% of screen height
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF30C1FF), Color(0xFF2AA7DC)],
                  )),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Select a Contact',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...contacts.map<Widget>((contact) {
                    return ListTile(
                      title: Text(
                        contact.displayName.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        var countryCode = '973';
                        var phoneNumber = contact.phones!.first.value
                            ?.replaceAll(RegExp(r'\D'), '');
                        phoneNumber =
                            phoneNumber!.replaceFirst(countryCode, '');
                        phoneNumber = countryCode + phoneNumber;
                        selectedContactNumber = phoneNumber;

                        // Store selected contact number in prefs.
                        prefs!.setString(
                            'selectedContactNumber', selectedContactNumber);

                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            ));
  }

  void clearMessages() {
    prefs!.remove('messages');
  }

  @override
  void dispose() {
    vigenereKeyController.dispose();
    timer?.cancel();
    super.dispose();
    printTimer?.cancel();
  }

  String createLoadingDots(int counter) {
    switch (counter % 3) {
      case 0:
        return 'Loading...';
      case 1:
        return 'Loading..';
      case 2:
        return 'Loading.';
    }
    return 'Loading';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CurvedAppBar(title: 'Settings Page'),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: vigenereKeyController,
              decoration: InputDecoration(
                labelText: 'Enter a Vigenere key',
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _storeVigenereKey(value);
                  final sb = ScaffoldMessenger.of(context);
                  sb.hideCurrentSnackBar();
                  sb.showSnackBar(SnackBar(
                    content: Text('Vigenere key has been updated!'),
                    duration: Duration(seconds: 2),
                  ));
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _storeVigenereKey(value);
                  final sb = ScaffoldMessenger.of(context);
                  sb.hideCurrentSnackBar();
                  sb.showSnackBar(SnackBar(
                    content: Text('Vigenere key has been updated!'),
                    duration: Duration(seconds: 2),
                  ));
                }
              },
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: qrData == 'Loading QR Data...'
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          createLoadingDots(counter++),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
          ),
          SizedBox(height: 10),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => selectContact(),
              child: Text('Select Contact', style: TextStyle(fontSize: 18)),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: selectedContactNumber.isEmpty
                ? Container()
                : Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Icon(Icons.contact_phone_outlined,
                              color: Colors.blue[900]),
                          SizedBox(width: 10),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Selected Contact Number: $selectedContactNumber',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => resetInitialization(),
              child: Text('Reset WhatsApp Initialization',
                  style: TextStyle(fontSize: 18)),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => clearMessages(),
              child: Text('Clear Messages', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
