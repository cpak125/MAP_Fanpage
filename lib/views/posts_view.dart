import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final Stream<QuerySnapshot> _postsStream = FirebaseFirestore.instance
      .collection('posts')
      .orderBy('date_time', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _postsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return Container(
              alignment: Alignment.center,
              child: ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  return ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    title: Text(
                      data["content"],
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: Text(
                      'Posted on ' +
                          data['date_time'].toDate().toString().substring(0, 11) +
                          'at ' +
                          data['date_time'].toDate().toString().substring(11, 16),
                      textAlign: TextAlign.right,
                    ),
                  );
                }).toList(),
              ));
        });
  }
}
