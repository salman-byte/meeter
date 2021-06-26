// To parse this JSON data, do
//
//     final messageModel = messageModelFromMap(jsonString);

import 'dart:convert';

class MessageModel {
  MessageModel({
    this.author,
    this.createdAt,
    this.id,
    this.status,
    this.text,
    this.type,
    this.height,
    this.name,
    this.size,
    this.uri,
    this.width,
    this.mimeType,
  });

  Author? author;
  int? createdAt;
  String? id;
  Status? status;
  String? text;
  Type? type;
  int? height;
  String? name;
  int? size;
  String? uri;
  int? width;
  String? mimeType;

  factory MessageModel.fromJson(String str) =>
      MessageModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MessageModel.fromMap(Map<String, dynamic> json) => MessageModel(
        author: json["author"] == null ? null : Author.fromMap(json["author"]),
        createdAt: json["createdAt"] == null ? null : json["createdAt"],
        id: json["id"] == null ? null : json["id"],
        status:
            json["status"] == null ? null : statusValues.map[json["status"]],
        text: json["text"] == null ? null : json["text"],
        type: json["type"] == null ? null : typeValues.map[json["type"]],
        height: json["height"] == null ? null : json["height"],
        name: json["name"] == null ? null : json["name"],
        size: json["size"] == null ? null : json["size"],
        uri: json["uri"] == null ? null : json["uri"],
        width: json["width"] == null ? null : json["width"],
        mimeType: json["mimeType"] == null ? null : json["mimeType"],
      );

  Map<String, dynamic> toMap() => {
        "author": author == null ? null : author?.toMap(),
        "createdAt": createdAt == null ? null : createdAt,
        "id": id == null ? null : id,
        "status": status == null ? null : statusValues.reverse[status],
        "text": text == null ? null : text,
        "type": type == null ? null : typeValues.reverse[type],
        "height": height == null ? null : height,
        "name": name == null ? null : name,
        "size": size == null ? null : size,
        "uri": uri == null ? null : uri,
        "width": width == null ? null : width,
        "mimeType": mimeType == null ? null : mimeType,
      };
}

class Author {
  Author({
    this.firstName,
    this.id,
    this.imageUrl,
  });

  FirstName? firstName;
  String? id;
  String? imageUrl;

  factory Author.fromJson(String str) => Author.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Author.fromMap(Map<String, dynamic> json) => Author(
        firstName: json["firstName"] == null
            ? null
            : firstNameValues.map[json["firstName"]],
        id: json["id"] == null ? null : json["id"],
        imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
      );

  Map<String, dynamic> toMap() => {
        "firstName":
            firstName == null ? null : firstNameValues.reverse[firstName],
        "id": id == null ? null : id,
        "imageUrl": imageUrl == null ? null : imageUrl,
      };
}

enum FirstName { ALEX, DARIA }

final firstNameValues =
    EnumValues({"Alex": FirstName.ALEX, "Daria": FirstName.DARIA});

enum Status { SEEN }

final statusValues = EnumValues({"seen": Status.SEEN});

enum Type { TEXT, IMAGE, FILE }

final typeValues =
    EnumValues({"file": Type.FILE, "image": Type.IMAGE, "text": Type.TEXT});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap!;
  }
}
