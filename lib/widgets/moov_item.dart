// File created by
// Lung Razvan <long1eu>
// on 09/10/2020

import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoovItem extends StatefulWidget {
  const MoovItem({Key key, @required this.course}) : super(key: key);

  final DocumentSnapshot course;

  @override
  _MoovItemState createState() => _MoovItemState();
}

class _MoovItemState extends State<MoovItem> {
  String get id => widget.course.documentID;

  String get title => widget.course['title'];

  String get description => widget.course['description'];

  DateTime get startDate => widget.course['startDate'].toDate();

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final User user = CurrentUserWidget.of(context);
    final bool isLiked = user.liked.contains(id);

    return StreamBuilder<int>(
      stream: Database().likesForMoov(id),
      initialData: 0,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        return Card(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xff000000),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            'lib/assets/chens.jpg',
                            fit: BoxFit.cover,
                            height: 130,
                            width: 50,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Padding(padding: const EdgeInsets.all(8.0)),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              title,
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ),
                          Padding(padding: const EdgeInsets.all(5.0)),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                dateFormat.format(startDate),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.0),
                child: Container(
                  height: 1.0,
                  width: 500.0,
                  color: Colors.grey[300],
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.end,
                children: [
                  FlatButton(
                    textColor: const Color(0xFF6200EE),
                    onPressed: () {
                      // Perform some action
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        "WHO'S GOING?",
                        style: TextStyle(
                          color: Colors.blue[500],
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isLiked) {
                        Database().removeLike(user.id, id);
                      } else {
                        Database().addLike(user.id, id);
                      }
                    },
                    child: Row(
                      children: [
                        Text('${snapshot.data}'),
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 28.0,
                          color: Colors.pink,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
