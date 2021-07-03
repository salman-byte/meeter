import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeter/constants/constants.dart';
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/models/messageModel.dart';
import 'package:meeter/models/userModel.dart';
import 'package:meeter/services/firebaseStorageService.dart';

class FirestoreService {
  FirestoreService._privateConstructor() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      firebaseUser = user;
    });
  }

  /// Current logged in user in Firebase. Does not update automatically.
  /// Use [FirebaseAuth.authStateChanges] to listen to the state changes.
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  /// Singleton instance
  static final FirestoreService instance =
      FirestoreService._privateConstructor();

  // final String phoneNo;

  // FirestoreService({this.phoneNo});
  // collection reference
  final CollectionReference userDataCollectionRefrence =
      FirebaseFirestore.instance.collection(USERS_COLLECTION);
  final CollectionReference groupDataCollectionRefrence =
      FirebaseFirestore.instance.collection(GROUPS_COLLECTION);

//create user document in database
  Future createUserDoc(UserData userData) async {
    try {
      await userDataCollectionRefrence.doc(userData.uid).set(userData.toMap());
    } catch (e) {
      print(e);
    }
  }

//create Group document in database
  Future createGroupDoc(GroupModel groupData) async {
    try {
      await FirebaseFirestore.instance
          .collection("GROUPS")
          .doc(groupData.id)
          .set(groupData.toMap());
      return;
    } catch (e) {
      print(e);
    }
  }

//create Message document in database
  Future createMessageDoc(MessageModel message, String groupId) async {
    try {
      if (message.type == Type.IMAGE) {
        // message.uri = await FirebaseStorageService.instance
        //     .uploadImageAndGetUrl(
        //         imgName: message.name ?? '', file: PickedFile(message.uri!));
      }
      if (message.type == Type.FILE) {
        // message.uri = await FirebaseStorageService.instance
        //     .uploadDocumentAndGetUrl(
        //         docName: message.name ?? '', file: PickedFile(message.uri!));
      }
      await FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(groupId)
          .collection(MESSAGES_COLLECTION)
          .doc()
          .set(message.toMap());
      return;
    } catch (e) {
      print(e);
    }
  }

//get Messages as stream from database
  Stream<List<MessageModel>> getMessagesAsStreamFromDataBase(String groupId) {
    try {
      return FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(groupId)
          .collection(MESSAGES_COLLECTION)
          .orderBy("createdAt", descending: true)
          .snapshots()
          .map((event) =>
              event.docs.map((e) => MessageModel.fromMap(e.data())).toList());
      // .set(message.toMap());
    } catch (e) {
      print(e);
      return Stream.empty();
    }
  }

  // get currentUserDataFromDB stream
  // Stream<UserData> get currentUserDocFromDBMappedIntoLocalUserData {
  //   try {
  //     return userDataCollectionRefrence
  //         .doc(phoneNo)
  //         .snapshots()
  //         .map((event) => userDataFromMap(jsonEncode(event.data())));
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<UserData?> getCurrentUserDocData({required String uid}) async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection(USERS_COLLECTION)
          .doc(uid)
          .get();
      print(snap.data());
      return userDataFromMap(jsonEncode(snap.data()));
    } catch (e) {
      print(e);
    }
  }

  /// Returns a stream of all users from Firebase
  Stream<List<UserData>> usersListAsStream() {
    if (firebaseUser == null) return const Stream.empty();
    return userDataCollectionRefrence
        .where("uid", isNotEqualTo: firebaseUser!.uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.fold<List<UserData>>(
            [],
            (previousValue, element) {
              return [
                ...previousValue,
                UserData.fromMap(element.data() as Map<String, dynamic>)
              ];
            },
          ),
        );
  }

  /// Returns a stream of all Groups from Firebase
  Stream<List<GroupModel>> getGroupsListAsStream() {
    try {
      if (firebaseUser == null) return const Stream.empty();

      return groupDataCollectionRefrence
          .where("members", arrayContains: firebaseUser!.uid)
          .snapshots()
          .map((snapshot) {
        final data = snapshot.docs.map((e) {
          return GroupModel.fromMap(e.data() as Map<String, dynamic>);
        }).toList();
        print(data.length);
        return data;
      });
    } catch (e) {
      print(e);
      return Stream.empty();
    }
  }

  Future<List<UserData>> getAllUsers() {
    try {
      if (firebaseUser == null) return Future.value([]);

      return userDataCollectionRefrence.get().then((value) => value.docs
          .map((e) => UserData.fromMap(e.data() as Map<String, dynamic>))
          .toList());
    } catch (e) {
      print(e);
      return Future.value(<UserData>[]);
    }
  }

  Future<List<UserData>> getAllUsersExcludingCurrentUser() {
    try {
      if (firebaseUser == null) return Future.value([]);

      return userDataCollectionRefrence
          .where("uid", isNotEqualTo: firebaseUser!.uid)
          .get()
          .then((value) => value.docs
              .map((e) => UserData.fromMap(e.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      print(e);
      return Future.value(<UserData>[]);
    }
  }
}
