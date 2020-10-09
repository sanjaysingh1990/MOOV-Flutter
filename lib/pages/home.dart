import 'dart:async';

import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/MOOVSPage.dart';
import 'package:MOOV/pages/ProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'create_account.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription<DocumentSnapshot> sub;
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    sub = usersRef.document(user.id).snapshots().listen((doc) async {
      if (!doc.exists) {
        // 2) if the user doesn't exist, then we want to take them to the create account page
        final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));

        // 3) get username from create account, use it to make new user document in users collection
        usersRef.document(user.id).setData({
          "id": user.id,
          "username": username,
          "photoUrl": user.photoUrl,
          "email": user.email,
          "displayName": user.displayName,
          "bio": "",
          "timestamp": timestamp
        });
        doc = await usersRef.document(user.id).get();
      }

      setState(() {
        if (mounted) {
          currentUser = User.fromDocument(doc);
        }
      });
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget buildAuthScreen() {
    // Upload(currentUser: currentUser);
    return CurrentUserWidget(
      user: currentUser,
      child: Scaffold(
        body: PageView(
          children: <Widget>[
            // Timeline(),
            HomePage(),
            MOOVSPage(),
            ProfilePage()
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
        ),
        bottomNavigationBar:
            CupertinoTabBar(currentIndex: pageIndex, onTap: onTap, activeColor: Theme.of(context).primaryColor, items: [
          BottomNavigationBarItem(title: Text("Home"), icon: Icon(Icons.home)),
          BottomNavigationBarItem(title: Text("My MOOVs"), icon: Icon(Icons.directions_run)),
          BottomNavigationBarItem(title: Text("Profile"), icon: Icon(Icons.account_circle)),
        ]),
      ),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        color: TextThemes.ndGold,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'lib/assets/appicon.png',
              scale: .5,
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'lib/assets/google.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}

class CurrentUserWidget extends InheritedWidget {
  const CurrentUserWidget({
    Key key,
    @required Widget child,
    @required this.user,
  })  : assert(child != null),
        super(key: key, child: child);

  final User user;

  static User of(BuildContext context) {
    final CurrentUserWidget widget = context.dependOnInheritedWidgetOfExactType<CurrentUserWidget>();
    return widget.user;
  }

  @override
  bool updateShouldNotify(CurrentUserWidget oldWidget) {
    return user != oldWidget.user;
  }
}
