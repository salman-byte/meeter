// To parse this JSON data, do
//
//     final userData = userDataFromMap(jsonString);

import 'dart:convert';

class UserData {
  UserData({
    this.uid,
    this.email,
    this.displayName,
    this.groups,
    this.photoUrl,
  });

  String? uid;
  String? email;
  String? displayName;
  List<Group>? groups;
  String? photoUrl;

  factory UserData.fromJson(String str) => UserData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserData.fromMap(Map<String, dynamic> json) => UserData(
        uid: json["uid"] == null ? null : json["uid"],
        email: json["email"] == null ? null : json["email"],
        displayName: json["displayName"] == null ? null : json["displayName"],
        groups: json["groups"] == null
            ? null
            : List<Group>.from(json["groups"].map((x) => Group.fromMap(x))),
        photoUrl: json["photoUrl"] == null ? null : json["photoUrl"],
      );

  Map<String, dynamic> toMap() => {
        "uid": uid == null ? null : uid,
        "email": email == null ? null : email,
        "displayName": displayName == null ? null : displayName,
        "groups": groups == null
            ? null
            : List<dynamic>.from(groups!.map((x) => x.toMap())),
        "photoUrl": photoUrl == null ? null : photoUrl,
      };
}

class Group {
  Group({
    this.id,
    this.category,
  });

  String? id;
  String? category;

  factory Group.fromJson(String str) => Group.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Group.fromMap(Map<String, dynamic> json) => Group(
        id: json["id"] == null ? null : json["id"],
        category: json["category"] == null ? null : json["category"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "category": category == null ? null : category,
      };
}
