import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:meeter/models/userModel.dart';
import 'package:meeter/services/firestoreService.dart';

class EmailAuth {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<String?> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirestoreService.instance.createUserDoc(UserData(
        email: email,
        uid: userCredential.user!.uid,
        displayName: 'Nishit Dixit',
        photoUrl: 'https://i.pravatar.cc/126',
      ));
      // await FirebaseChatCore.instance.createUserInFirestore(
      //   types.User(
      //     firstName: 'Nishit',
      //     id: userCredential.user!.uid, // UID from Firebase Authentication
      //     imageUrl: 'https://i.pravatar.cc/300',
      //     lastName: 'Dixit',
      //   ),
      // );
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
