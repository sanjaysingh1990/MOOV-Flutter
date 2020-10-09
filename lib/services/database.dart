// import 'package:flutter/material.dart';
// import 'package:MOOV/pages/HomePage.dart';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final dbRef = Firestore.instance;

  void createPost(
      {title,
      description,
      type,
      location,
      address,
      Map likes,
      DateTime startDate,
      DateTime endDate,
      String imageUrl}) async {
    // await dbRef.collection("books")
    //     .document("1")
    //     .setData({
    //       'title': 'Mastering Flutter',
    //       'description': 'Programming Guide for Dart'
    //     });
    DocumentReference ref = await dbRef.collection("food").add({
      'title': title,
      'likes': likes,
      'type': type,
      'description': description,
      'location': location,
      'address': address,
      'startDate': startDate,
      'endDate': endDate,
      'image': imageUrl,
    });
    // final String postId = ref.documentID;
    print(ref.documentID);

    Firestore.instance.collection("food").orderBy("startDate", descending: true);
  }

  // void createSportPost(
  //     {title,
  //     description,
  //     type,
  //     location,
  //     address,
  //     DateTime startDate,
  //     DateTime endDate,
  //     String imageUrl}) async {
  //   // await dbRef.collection("books")
  //   //     .document("1")
  //   //     .setData({
  //   //       'title': 'Mastering Flutter',
  //   //       'description': 'Programming Guide for Dart'
  //   //     });
  //   DocumentReference ref = await dbRef.collection("sport").add({
  //     'title': title,
  //     'type': type,
  //     'description': description,
  //     'location': location,
  //     'address': address,
  //     'startDate': startDate,
  //     'endDate': endDate,
  //     'image': imageUrl,
  //   });
  //   print(ref.documentID);

  //   Firestore.instance
  //       .collection("sport")
  //       .orderBy("startDate", descending: true);
  // }

  void getData() {
    dbRef.collection("books").getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => print('${f.data}}'));
    });
  }

  void updateData() {
    try {
      dbRef.collection('books').document('1').updateData({'description': 'Head First Flutter'});
    } catch (e) {
      print(e.toString());
    }
  }

  void deleteData() {
    try {
      dbRef.collection('books').document('1').delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addLike(String uid, String moovId) async {
    return dbRef.runTransaction((transaction) async {
      final int index = Random().nextInt(10);
      final DocumentReference ref = dbRef.document('food/$moovId/likes/shred-$index');
      final DocumentSnapshot snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        transaction.set(ref, {'counter': 1});
      } else {
        transaction.update(ref, {'counter': FieldValue.increment(1)});
      }

      final DocumentReference userRef = dbRef.document('users/$uid');
      transaction.update(userRef, {
        'liked': FieldValue.arrayUnion([moovId])
      });
    });
  }

  Future<void> removeLike(String uid, String moovId) async {
    return dbRef.runTransaction((transaction) async {
      final Random random = Random();

      // todo: remember all the values that were used son we don't use them again
      int index = random.nextInt(10);
      DocumentSnapshot snapshot;
      while (snapshot == null) {
        final DocumentReference ref = dbRef.document('food/$moovId/likes/shred-$index');
        snapshot = await transaction.get(ref);

        if (!snapshot.exists) {
          index = random.nextInt(10);
          snapshot = null;
        }
      }

      transaction.update(snapshot.reference, {'counter': FieldValue.increment(-1)});
      final DocumentReference userRef = dbRef.document('users/$uid');
      transaction.update(userRef, {
        'liked': FieldValue.arrayRemove([moovId])
      });
    });
  }

  Stream<int> likesForMoov(String moovId) {
    return dbRef
        .collection('food/$moovId/likes')
        .snapshots()
        .map((snapshot) => snapshot.documents.fold(0, (sum, item) => sum + item['counter']));
  }
}
