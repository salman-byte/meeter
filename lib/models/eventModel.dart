// To parse this JSON data, do
//
//     final eventModel = eventModelFromMap(jsonString);

import 'dart:convert';

EventModel eventModelFromMap(String str) =>
    EventModel.fromMap(json.decode(str));

String eventModelToMap(EventModel data) => json.encode(data.toMap());

class EventModel {
  EventModel({
    this.eventSubject,
    this.eventEnd,
    this.eventMeetLink,
    this.eventBegin,
    this.eventColorCode,
    this.members,
  });

  String? eventSubject;
  int? eventEnd;
  String? eventMeetLink;
  int? eventBegin;
  int? eventColorCode;
  List<String>? members;

  factory EventModel.fromMap(Map<String, dynamic> json) => EventModel(
        eventSubject:
            json["eventSubject"] == null ? null : json["eventSubject"],
        eventEnd: json["eventEnd"] == null ? null : json["eventEnd"],
        eventMeetLink:
            json["eventMeetLink"] == null ? null : json["eventMeetLink"],
        eventBegin: json["eventBegin"] == null ? null : json["eventBegin"],
        eventColorCode:
            json["eventColorCode"] == null ? null : json["eventColorCode"],
        members: json["members"] == null
            ? null
            : List<String>.from(json["members"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "eventSubject": eventSubject == null ? null : eventSubject,
        "eventEnd": eventEnd == null ? null : eventEnd,
        "eventMeetLink": eventMeetLink == null ? null : eventMeetLink,
        "eventBegin": eventBegin == null ? null : eventBegin,
        "eventColorCode": eventColorCode == null ? null : eventColorCode,
        "members":
            members == null ? null : List<dynamic>.from(members!.map((x) => x)),
      };
}
