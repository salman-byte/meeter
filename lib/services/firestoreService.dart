import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meeter/constants/constants.dart';
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/models/userModel.dart';

class FirestoreService {
  // final String phoneNo;

  // FirestoreService({this.phoneNo});
  // collection reference
  final CollectionReference userDataCollectionRefrence =
      FirebaseFirestore.instance.collection(USERS_COLLECTION);
  // final CollectionReference natureWallpaperCollectionRefrence =
  //     FirebaseFirestore.instance.collection(NATURE_WALLPAPER_COLLECTION);
  // final CollectionReference wallpaperCollectionReference =
  //     FirebaseFirestore.instance.collection(WALLPAPERS_COLLECTION);

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
          .doc()
          .set(groupData.toMap());
    } catch (e) {
      print(e);
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

  Future<UserData?> getGroupData() async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection("GROUPS")
          .doc("6h1tbS26hPoGXNjcI7sn")
          .get();
      print((snap.data() as Map)['createdAt'].toString());
      // print(jsonEncode(snap.data(), toEncodable: (object) {
      //   return timestampToMap(timestampFromMap(object.toString()));
      // }));
      // groupModelFromMap(json.encode(snap.data()));
      GroupModel groupData =
          GroupModel.fromMap(snap.data() as Map<String, dynamic>);
      print(groupData.id);
    } catch (e) {
      print(e);
    }
  }

  // Future<DocumentWithCountModel> natureWallpaperData({int docNumber}) async {
  //   try {
  //     DocumentWithCountModel completeDocData;
  //     UrLdocument document = await natureWallpaperCollectionRefrence
  //         .doc('stack$docNumber')
  //         .get()
  //         .then((value) => UrLdocument.fromMap(value.data()));
  //     int count = await wallpaperCollectionReference
  //         .doc('category_count')
  //         .get()
  //         .then((snap) => snap.data()['nature_wallpaper']);
  //     completeDocData = DocumentWithCountModel(document, count);
  //     return completeDocData;
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Future<void> uploadImageToStorageAndAddUrlToDocumentWithCountIncrement(
  //     FirebaseStorageService storageService, PickedFile imageFile) async {
  //   int count = await wallpaperCollectionReference
  //       .doc('category_count')
  //       .get()
  //       .then((snap) => snap.data()['nature_wallpaper']);
  //   int stackNumberFilled = (count / 10).floor();
  //   int urlNumberFilled = (count % 10);
  //   String imageUrl =
  //       await storageService.uploadWallpaperAndGetUrl(file: imageFile);
  //   await natureWallpaperCollectionRefrence
  //       .doc('stack${stackNumberFilled + 1}')
  //       .update({'url${urlNumberFilled + 1}': imageUrl});
  //   await wallpaperCollectionReference
  //       .doc('category_count')
  //       .update({'nature_wallpaper': FieldValue.increment(1)});
  //   return;
  // }
}
