import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AuthenticationStatus { SIGNEDIN, SIGNEDOUT }

class AuthStatusNotifier extends ChangeNotifier {
  AuthenticationStatus? _currentStatus = AuthenticationStatus.SIGNEDOUT;

  AuthStatusNotifier() {
    // print("surrent status is $_currentStatus");
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        changeAuthStatus(newStatus: AuthenticationStatus.SIGNEDOUT);
      } else {
        print('User is signed in!');
        changeAuthStatus(newStatus: AuthenticationStatus.SIGNEDIN);
      }
    });
  }

  void changeAuthStatus({AuthenticationStatus? newStatus}) {
    _currentStatus = newStatus;

    notifyListeners();
  }

  bool get isUserAuthenticated =>
      _currentStatus == AuthenticationStatus.SIGNEDIN ? true : false;

  // rebuildRoot() {
  //   notifyListeners();
  // }
}
