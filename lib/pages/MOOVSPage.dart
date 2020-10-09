// import 'package:MOOV/widgets/segmented_control.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/widgets/moov_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MOOVSPage extends StatefulWidget {
  @override
  _MOOVSPageState createState() => _MOOVSPageState();
}

class _MOOVSPageState extends State<MOOVSPage> {
  final String currentUserId = currentUser?.id;
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    isLiked = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TextThemes.ndBlue,
        //pinned: true,
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.all(5.0),
            icon: Icon(Icons.search),
            color: Colors.white,
            splashColor: Color.fromRGBO(220, 180, 57, 1.0),
            onPressed: () {
              // Implement navigation to shopping cart page here...
              print('Click Search');
            },
          ),
          IconButton(
            padding: EdgeInsets.all(5.0),
            icon: Icon(Icons.message),
            color: Colors.white,
            splashColor: Color.fromRGBO(220, 180, 57, 1.0),
            onPressed: () {
              // Implement navigation to shopping cart page here...
              print('Click Message');
            },
          )
        ],
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.all(5),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                'lib/assets/moovheader.png',
                fit: BoxFit.cover,
                height: 45.0,
              ),
              Image.asset(
                'lib/assets/ndlogo.png',
                fit: BoxFit.cover,
                height: 25,
              )
            ],
          ),
        ),
      ),

      body: StreamBuilder(
          stream: Firestore.instance.collection('food').orderBy("startDate").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('Loading data...');
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot course = snapshot.data.documents[index];
                return MoovItem(course: course);
              },
            );
          }),
      // FloatingActionButton.extended(
      //     onPressed: () {
      //       // Add your onPressed code here!
      //     },
      //     label: Text('Find a MOOV',
      //         style: TextStyle(color: Colors.white)),
      //     icon: Icon(Icons.search, color: Colors.white),
      //     backgroundColor: Color.fromRGBO(220, 180, 57, 1.0))
    );
  }
}
