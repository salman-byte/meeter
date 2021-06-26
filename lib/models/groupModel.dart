// To parse this JSON data, do
//
//     final groupModel = groupModelFromMap(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

GroupModel groupModelFromMap(String str) =>
    GroupModel.fromMap(json.decode(str));

String groupModelToMap(GroupModel data) => json.encode(data.toMap());

class GroupModel {
  GroupModel({
    this.type,
    this.users,
    this.name,
    this.members,
    this.modifiedAt,
    this.createdAt,
    this.recentMessage,
    this.createdBy,
    this.id,
  });

  int? type;
  dynamic? users;
  String? name;
  List<String>? members;
  Timestamp? modifiedAt;
  Timestamp? createdAt;
  RecentMessage? recentMessage;
  String? createdBy;
  String? id;

  factory GroupModel.fromMap(Map<String, dynamic> json) => GroupModel(
        type: json["type"] == null ? null : json["type"],
        users: json["users"],
        name: json["name"] == null ? null : json["name"],
        members: json["members"] == null
            ? null
            : List<String>.from(json["members"].map((x) => x)),
        modifiedAt: json["modifiedAt"] == null ? null : json["modifiedAt"],
        createdAt: json["createdAt"] == null ? null : json["createdAt"],
        recentMessage: json["recentMessage"] == null
            ? null
            : RecentMessage.fromMap(json["recentMessage"]),
        createdBy: json["createdBy"] == null ? null : json["createdBy"],
        id: json["id"] == null ? null : json["id"],
      );

  Map<String, dynamic> toMap() => {
        "type": type == null ? null : type,
        "users": users,
        "name": name == null ? null : name,
        "members":
            members == null ? null : List<dynamic>.from(members!.map((x) => x)),
        "modifiedAt": modifiedAt == null ? null : modifiedAt,
        "createdAt": createdAt == null ? null : createdAt,
        "recentMessage": recentMessage == null ? null : recentMessage!.toMap(),
        "createdBy": createdBy == null ? null : createdBy,
        "id": id == null ? null : id,
      };
}

class RecentMessage {
  RecentMessage({
    this.readBy,
    this.messageText,
    this.sentBy,
    this.sentAt,
  });

  List<String>? readBy;
  String? messageText;
  String? sentBy;
  Timestamp? sentAt;

  factory RecentMessage.fromMap(Map<String, dynamic> json) => RecentMessage(
        readBy: json["readBy"] == null
            ? null
            : List<String>.from(json["readBy"].map((x) => x)),
        messageText: json["messageText"] == null ? null : json["messageText"],
        sentBy: json["sentBy"] == null ? null : json["sentBy"],
        sentAt: json["sentAt"] == null ? null : json["sentAt"],
      );

  Map<String, dynamic> toMap() => {
        "readBy":
            readBy == null ? null : List<dynamic>.from(readBy!.map((x) => x)),
        "messageText": messageText == null ? null : messageText,
        "sentBy": sentBy == null ? null : sentBy,
        "sentAt": sentAt == null ? null : sentAt,
      };
}
