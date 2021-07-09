import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:meeter/models/userModel.dart';
import 'package:meeter/services/firestoreService.dart';

/// the class responsible for authentication requests
/// [createUserWithEmailAndPassword] method is used to create new user. it returns exception message if any.
/// after creating the user it runs a request to create a document for user details in firestore database.
///
/// [signInWithEmailAndPassword] method is used to signIn an existing user. it returns exception message if any.
class EmailAuth {
  FirebaseAuth auth = FirebaseAuth.instance;

  ///used to create new user. it returns exception message if any
  Future<String?> createUserWithEmailAndPassword(
      {required String email,
      required String password,
      required String name}) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirestoreService.instance.createUserDoc(UserData(
        email: email,
        uid: userCredential.user!.uid,
        displayName: name,
        photoUrl: 'https://i.pravatar.cc/126',
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return e.code;
    } catch (e) {
      print(e);
    }
  }

  ///used to signIn an existing user. it returns exception message if any.
  Future<String?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return e.code;
    }
  }
}
