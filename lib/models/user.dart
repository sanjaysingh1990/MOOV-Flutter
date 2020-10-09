import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final List<String> liked;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
    this.liked,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      liked: doc.data.containsKey('liked') ? List<String>.from(doc['liked']) : <String>[],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          photoUrl == other.photoUrl &&
          displayName == other.displayName &&
          bio == other.bio &&
          const ListEquality<String>().equals(liked, other.liked);

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      photoUrl.hashCode ^
      displayName.hashCode ^
      bio.hashCode ^
      const ListEquality<String>().hash(liked);
}
