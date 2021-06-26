// To parse this JSON data, do
//
//     final userData = userDataFromMap(jsonString);

import 'dart:convert';

UserData userDataFromMap(String str) => UserData.fromMap(json.decode(str));

String userDataToMap(UserData data) => json.encode(data.toMap());

class UserData {
  UserData({
    this.email,
    this.groups,
    this.uid,
    this.photoUrl,
    this.displayName,
  });

  String? email;
  List<Group>? groups;
  String? uid;
  String? photoUrl;
  String? displayName;

  factory UserData.fromMap(Map<String, dynamic> json) => UserData(
        email: json["email"] == null ? null : json["email"],
        groups: json["groups"] == null
            ? null
            : List<Group>.from(json["groups"].map((x) => Group.fromMap(x))),
        uid: json["uid"] == null ? null : json["uid"],
        photoUrl: json["photoUrl"] == null ? null : json["photoUrl"],
        displayName: json["displayName"] == null ? null : json["displayName"],
      );

  Map<String, dynamic> toMap() => {
        "email": email == null ? null : email,
        "groups": groups == null
            ? null
            : List<dynamic>.from(groups!.map((x) => x.toMap())),
        "uid": uid == null ? null : uid,
        "photoUrl": photoUrl == null ? null : photoUrl,
        "displayName": displayName == null ? null : displayName,
      };
}

class Group {
  Group({
    this.id,
    this.category,
  });

  String? id;
  String? category;

  factory Group.fromMap(Map<String, dynamic> json) => Group(
        id: json["id"] == null ? null : json["id"],
        category: json["category"] == null ? null : json["category"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "category": category == null ? null : category,
      };
}
