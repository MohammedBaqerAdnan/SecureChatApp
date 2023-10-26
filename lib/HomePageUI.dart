//define the main structure and functionality secure chat and provide UI

import 'package:flutter/material.dart';
import 'CurvedAppBar.dart';

//title for the appbar
class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CurvedAppBar(title: widget.title),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              kToolbarHeight -
              kBottomNavigationBarHeight,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  //gradient for background of app
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.1, 1],
                    colors: [
                      Colors.blueGrey.shade50,
                      Colors.blueGrey.shade200,
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/Yaru-Pink.jpg',
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                      ),
                    ),
                    Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Start Your Secure Chat',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 50),
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.lightBlue.shade400),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 10)),
                              ),
                              onPressed: () {
                                // Functionality to navigate to Encryption page
                              },
                              icon: const Icon(Icons.lock_rounded, size: 30),
                              label: const Text('Encrypt Message',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)),
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 10)),
                                side: MaterialStateProperty.all<BorderSide>(
                                    BorderSide(
                                        color: Colors.lightBlue.shade400,
                                        width: 2)),
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
                            const SizedBox(height: 20),
                            const Icon(Icons.favorite),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
