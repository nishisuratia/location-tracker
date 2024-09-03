import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/auth/setdetails.dart';
import 'package:permission_handler/permission_handler.dart';

import '../home.dart';
import 'otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  String? uid;
  String? get_name;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    FirebaseFirestore.instance
        .collection('global_users')
        .doc(uid)
        .snapshots()
        .listen((userData) {
      get_name = userData.data()?['name'];
    });
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (get_name == null) {
              return SetDetails();
            } else {
              return Home();
            }
          } else {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 5,
                    color: Color.fromARGB(255, 86, 96, 100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.all(20),
                            child: const Center(
                              child: Text(
                                'Location Tracker',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(20),
                            child: TextField(
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade400),
                                ),
                                focusColor: Colors.grey.shade400,
                                hintText: 'Phone Number',
                                prefix: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    '+91',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                              maxLength: 10,
                              keyboardType: TextInputType.number,
                              controller: _controller,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(20),
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white24),
                                shape: MaterialStateProperty.all(
                                  StadiumBorder(),
                                ),
                              ),
                              onPressed: () {
                                if (_controller.text.length == 10) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          OTPScreen(_controller.text)));
                                }
                              },
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
