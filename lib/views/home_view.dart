import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanpage/driver.dart';
import 'package:fanpage/views/posts_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _userType = "";
  TextEditingController textFieldController = TextEditingController();
  DateTime dateTime = new DateTime.now();

  @override
  Widget build(BuildContext context) {
    final splashImage = Container(
      padding: EdgeInsets.only(top: 20.0),
      child: Image.asset(
        "assets/profile.png",
        height: 300.0,
      ),
    );

    _getUserRole();
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blueGrey,
            actions: [
              FloatingActionButton(
                backgroundColor: Colors.red.shade400,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            content: Text(
                              'Are you sure you want to log out?',
                              style: TextStyle(fontSize: 20),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                          Colors.red.shade800)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'NO',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  )),
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                          Colors.green.shade800)),
                                  onPressed: () {
                                    _signOut(context);
                                  },
                                  child: Text(
                                    'YES',
                                    style: TextStyle(fontSize: 20),
                                  ))
                            ]);
                      });
                },
                tooltip: 'Log Out',
                child: Icon(
                  Icons.logout,
                ),
              )
            ]),
        body: Column(
          children: [splashImage, Expanded(child: Posts())],
        ),
        floatingActionButton: _userType == "admin"
            ? FloatingActionButton(
                backgroundColor: Colors.blueGrey,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            content:
                                Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              maxLines: 8,
                              controller: textFieldController,
                              decoration: InputDecoration(
                                  hintText: 'What\'s on your mind?',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0))),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueGrey,
                                      textStyle: TextStyle(fontSize: 16)),
                                  child: Text("Post"),
                                  onPressed: () {
                                    setState(
                                      () {
                                        FirebaseFirestore.instance
                                            .collection('posts')
                                            .add({
                                          "content": textFieldController.text,
                                          "date_time": dateTime
                                        });
                                        textFieldController.clear();
                                        Navigator.pop(context);
                                      },
                                    );
                                  })),
                          Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ElevatedButton(
                                child: Text("Cancel"),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    textStyle: TextStyle(fontSize: 16)),
                                onPressed: () {
                                  setState(() {
                                    textFieldController.clear();
                                    Navigator.pop(context);
                                  });
                                },
                              )),
                        ]));
                      });
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 32,
                ))
            : Container());
  }

  Future<void> _getUserRole() async {
    await _db
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        _userType = (documentSnapshot['user_role']);
      } else {}
    });
    setState(() {});
  }

  void _signOut(BuildContext context) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    await _auth.signOut();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('User logged out.')));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (con) => AppDriver()));
  }
}
