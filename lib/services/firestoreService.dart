import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeter/constants/constants.dart';
import 'package:meeter/models/eventModel.dart';
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/models/messageModel.dart';
import 'package:meeter/models/userModel.dart';
import 'package:meeter/services/firebaseStorageService.dart';

/// custom class that holds all the fireStore queries required across the app
///
/// its a singleton which holds firebase user as a property inside.
///
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
      if (firebaseUser == null) return;
      await FirebaseFirestore.instance
          .collection(GROUPS_COLLECTION)
          .doc(groupData.id)
          .set(groupData.toMap());
      return;
    } catch (e) {
      print(e);
    }
  }

//update Group document in database for recent message
  Future updateRecentMessageInGroupDoc(
      {required String groupId, required MessageModel message}) async {
    try {
      if (firebaseUser == null) return;

      await FirebaseFirestore.instance
          .collection(GROUPS_COLLECTION)
          .doc(groupId)
          .update({
        MODIFIED_AT_FIELD_IN_GROUP_DOCUMENT: Timestamp.now(),
        RECENT_MESSAGE_FIELD_IN_GROUP_DOCUMENT: RecentMessage(
                sentAt:
                    Timestamp.fromMillisecondsSinceEpoch(message.createdAt!),
                sentBy: message.author!.id,
                readBy: [message.author!.id!],
                messageText: message.type == Type.TEXT
                    ? message.text
                    : message.type.toString().split('.').last)
            .toMap()
      });

      return;
    } catch (e) {
      print(e);
    }
  }

//update Group document in database for marking message as read
  Future markLastMessageAsReadInGroupDoc({required String groupId}) async {
    try {
      if (firebaseUser == null) return;

      await FirebaseFirestore.instance
          .collection(GROUPS_COLLECTION)
          .doc(groupId)
          .update({
        "$RECENT_MESSAGE_FIELD_IN_GROUP_DOCUMENT.readBy":
            FieldValue.arrayUnion([firebaseUser?.uid])
      });

      return;
    } catch (e) {
      print(e);
    }
  }

//create Message document in database
  Future createMessageDoc(MessageModel message, String groupId,
      {bool isNewGroup = false}) async {
    try {
      if (firebaseUser == null) return;
      await FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(groupId)
          .collection(MESSAGES_COLLECTION)
          .doc()
          .set(message.toMap());
      if (!isNewGroup) {
        await updateRecentMessageInGroupDoc(groupId: groupId, message: message);
      }
      return;
    } catch (e) {
      print(e);
    }
  }

//create Notes document in database
  Future createNoteDoc(String note, String groupId) async {
    try {
      if (firebaseUser == null) return;
      await FirebaseFirestore.instance
          .collection(NOTES_COLLECTION)
          .doc(groupId)
          .collection(NOTES_COLLECTION)
          .doc(firebaseUser!.uid)
          .set({'note': note});
      return;
    } catch (e) {
      print(e);
    }
  }

//create Event document in database
  Future createEventDoc(EventModel event) async {
    try {
      if (firebaseUser == null) return;
      await FirebaseFirestore.instance
          .collection(EVENTS_COLLECTION)
          .doc()
          .set(event.toMap());
      return;
    } catch (e) {
      print(e);
    }
  }

//get Notes document from database
  Future<String> getNoteDoc(String groupId) async {
    try {
      if (firebaseUser == null) return '';
      return await FirebaseFirestore.instance
          .collection(NOTES_COLLECTION)
          .doc(groupId)
          .collection(NOTES_COLLECTION)
          .doc(firebaseUser!.uid)
          .get()
          .then((value) => value.data()!['note']);
    } catch (e) {
      print(e);
      return '';
    }
  }

//get Event document from database
  Future<List<EventModel>> getEventDoc() async {
    try {
      if (firebaseUser == null) return [];
      return await FirebaseFirestore.instance
          .collection(EVENTS_COLLECTION)
          .where("members", arrayContains: firebaseUser!.uid)
          .get()
          .then((snapshot) {
        return snapshot.docs.map((e) => EventModel.fromMap(e.data())).toList();
      });
    } catch (e) {
      print(e);
      return [];
    }
  }

//get group document from database
  Future<GroupModel?> getGroupDoc(String groupId) async {
    try {
      if (firebaseUser == null) return null;
      return await FirebaseFirestore.instance
          .collection(GROUPS_COLLECTION)
          .doc(groupId)
          .get()
          .then((document) {
        return GroupModel.fromMap(document.data()!);
      });
    } catch (e) {
      print(e);
      return null;
    }
  }

//get Messages as stream from database
  Stream<List<MessageModel>> getMessagesAsStreamFromDataBase(String groupId) {
    try {
      return FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(groupId)
          .collection(MESSAGES_COLLECTION)
          .orderBy("createdAt")
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
          .orderBy(MODIFIED_AT_FIELD_IN_GROUP_DOCUMENT, descending: true)
          .where("members", arrayContains: firebaseUser!.uid)
          .snapshots()
          .map((snapshot) {
        // final data = snapshot.docs.fold<List<GroupModel>>(
        //     [],
        //     (previousValue, element) => [
        //           ...previousValue,
        //           GroupModel.fromMap(element.data() as Map<String, dynamic>)
        //         ]);
        final data = snapshot.docs.map((e) {
          return GroupModel.fromMap(e.data() as Map<String, dynamic>);
        }).toList();
        print(data.length);
        return data;
      }).handleError((e) {
        print(e);
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

  Future<List<GroupModel>> getAllGroups() {
    try {
      if (firebaseUser == null) return Future.value([]);

      return groupDataCollectionRefrence.get().then((value) => value.docs
          .map((e) => GroupModel.fromMap(e.data() as Map<String, dynamic>))
          .toList());
    } catch (e) {
      print(e);
      return Future.value(<GroupModel>[]);
    }
  }

  Future<List<GroupModel>> getAllGroupsRelatedToCurrentUser() {
    try {
      if (firebaseUser == null) return Future.value([]);

      return groupDataCollectionRefrence
          .orderBy(MODIFIED_AT_FIELD_IN_GROUP_DOCUMENT, descending: true)
          .where("members", arrayContains: firebaseUser!.uid)
          .get()
          .then((value) => value.docs
              .map((e) => GroupModel.fromMap(e.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      print(e);
      return Future.value(<GroupModel>[]);
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
