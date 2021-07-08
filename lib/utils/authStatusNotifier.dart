import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meeter/models/userModel.dart';
import 'package:meeter/services/firestoreService.dart';

enum AuthenticationStatus { SIGNEDIN, SIGNEDOUT }

class AuthStatusNotifier extends ChangeNotifier {
  AuthenticationStatus? _currentStatus = AuthenticationStatus.SIGNEDOUT;
  UserData? _currentLoggedInUser;

  AuthStatusNotifier() {
    // print("surrent status is $_currentStatus");
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        changeAuthStatus(newStatus: AuthenticationStatus.SIGNEDOUT);
      } else {
        print('User is signed in!');
        setCurrentUser(uid: user.uid);
      }
    });
  }

  setCurrentUser({required String uid}) async {
    await FirestoreService.instance
        .getCurrentUserDocData(uid: uid)
        .then((value) {
      if (value != null) {
        _currentLoggedInUser = value;
      }
      changeAuthStatus(newStatus: AuthenticationStatus.SIGNEDIN);
    });
  }

  UserData? get currentUser => _currentLoggedInUser;

  void changeAuthStatus({AuthenticationStatus? newStatus}) {
    _currentStatus = newStatus;

    notifyListeners();
  }

  bool get isUserAuthenticated =>
      _currentStatus == AuthenticationStatus.SIGNEDIN ? true : false;

  rebuildRoot() {
    notifyListeners();
  }
}
