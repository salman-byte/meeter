import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meeter/models/userModel.dart';
import 'package:meeter/services/firestoreService.dart';

enum AuthenticationStatus { SIGNEDIN, SIGNEDOUT }

///
/// it extends [ChangeNotifier] class is used to listen and maintain which group is selected by user
///
/// uses [AuthenticationStatus] enum to set `SignedIn` and `SignedOut` status,
///
/// [setCurrentUser] takes a Uid and notifies listeners about the current logged in user
///
/// [setCurrentSelectedChatViaGroupId] takes a group id String and notifies listeners about the new selected group
///
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

  /// the method used to set the current loggedIn user in [AuthStatusNotifier], which will be available across the app life cycle.
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

  /// the getter method to get the current Logged in user
  UserData? get currentUser => _currentLoggedInUser;

  void changeAuthStatus({AuthenticationStatus? newStatus}) {
    _currentStatus = newStatus;

    notifyListeners();
  }

  /// the getter to know the authentication status of user
  bool get isUserAuthenticated =>
      _currentStatus == AuthenticationStatus.SIGNEDIN ? true : false;

  /// can be used in the need for rebuilding the widget which is listening to [AuthStatusNotifier]

  rebuildRoot() {
    notifyListeners();
  }
}
