//define the main structure and functionality secure chat and provide UI

import 'package:flutter/material.dart';
import 'AppBarClipper.dart';
import 'CurvedAppBar.dart';

//title for the appbar
class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CurvedAppBar(title: widget.title),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              //gradient for background of app
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 1],
                colors: [
                  Colors.blueGrey.shade50,
                  Colors.blueGrey.shade200,
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Image.asset(
                    'assets/images/Yaru-Pink.jpg',
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Start Your Secure Chat',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50),
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.lightBlue.shade400),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10)),
                        ),
                        onPressed: () {
                          // Functionality to navigate to Encryption page
                        },
                        icon: Icon(Icons.lock_rounded, size: 30),
                        label: Text('Encrypt Message',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                      SizedBox(height: 20),
                      OutlinedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10)),
                          side: MaterialStateProperty.all<BorderSide>(
                              BorderSide(
                                  color: Colors.lightBlue.shade400, width: 2)),
                        ),
                        onPressed: () {
                          // Functionality to navigate to Decryption page
                        },
                        icon: Icon(Icons.lock_open_rounded,
                            size: 30, color: Colors.lightBlue.shade400),
                        label: Text('Decrypt Message',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.lightBlue.shade400)),
                      ),
                      SizedBox(height: 20),
                      Icon(Icons.favorite),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
