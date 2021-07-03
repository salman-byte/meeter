import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  FirebaseStorageService._privateConstructor() {
    _firebaseStorage = FirebaseStorage.instance;
  }

  /// Singleton instance
  static final FirebaseStorageService instance =
      FirebaseStorageService._privateConstructor();

  Future<String> uploadDocumentAndGetUrl(
      {required String docName, required Uint8List data}) async {
    try {
      String url = await _firebaseStorage
          .ref("Documents")
          .child('${DateTime.now().toString()}' + '$docName')
          .putData(data)
          .then((TaskSnapshot snapshot) => snapshot.ref.getDownloadURL());
      return url;
    } catch (e) {
      print(e);
      return "";
    }
  }

  Future<String> uploadImageAndGetUrl(
      {required String imgName, required Uint8List data}) async {
    try {
      String url = await _firebaseStorage
          .ref("Pictures")
          .child('${DateTime.now().toString()}' + '$imgName')
          .putData(data)
          // .putFile(File(file.path))
          .then((TaskSnapshot snapshot) => snapshot.ref.getDownloadURL());
      return url;
    } catch (e) {
      print(e);
      return "";
    }
  }
}
