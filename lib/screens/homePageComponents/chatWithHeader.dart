import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:meeter/constants/constants.dart';
import 'package:meeter/models/eventModel.dart';
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/models/messageModel.dart';
import 'package:meeter/res/colors.dart';
import 'package:meeter/screens/chatPageComponents.dart/meetScreenSettings.dart';
import 'package:meeter/screens/chat_page.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/constants.dart';
import 'package:meeter/widgets/create_event_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:meeter/utils/extensions.dart';

class ChatViewWithHeader extends StatefulWidget {
  final GroupModel group;
  const ChatViewWithHeader({
    Key? key,
    required this.group,
  }) : super(key: key);

  @override
  _ChatViewWithHeaderState createState() => _ChatViewWithHeaderState();
}

class _ChatViewWithHeaderState extends State<ChatViewWithHeader> {
  String noteText = 'no data yet';
  bool notesOpen = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChatViewWithHeader oldWidget) {
    print('groupid: ${widget.group.id!}');
    FirestoreService.instance.getNoteDoc(widget.group.id!).then((value) {
      setState(() {
        noteText = value;
      });
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(widget.group.name!),
              ),
              PopupMenuButton(onSelected: (value) async {
                switch (value) {
                  case 1:
                    buildShowAnimatedMeetingDialog(context, widget.group.id!);
                    print('pushing route');
                    break;
                  case 2:
                    final CalendarEventModel? event = await showDialog(
                        context: context,
                        builder: (context) => const CreateEventDialog());
                    if (event != null) {
                      scheduleCalenderEventAndMeetForLater(event);
                    }
                    break;
                  case 3:
                    setState(() {
                      notesOpen = !notesOpen;
                    });
                    break;
                  default:
                }

                // VxNavigator.of(context).push(Uri.parse('/meet'));
              }, itemBuilder: (context) {
                return <PopupMenuItem>[
                  PopupMenuItem(value: 1, child: Text('Start meeting')),
                  PopupMenuItem(value: 2, child: Text('Schedule meeting')),
                  PopupMenuItem(value: 3, child: Text('Notes')),
                ];
              })
            ],
          )),
          Divider(),
          AnimatedContainer(
            duration: Duration(seconds: 1),
            child: notesOpen
                ? LimitedBox(
                    maxHeight: context.safePercentHeight * 30,
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.maxFinite,
                        color: Colors.amber,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(noteText),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ),
          Expanded(child: ChatPage()),
        ]);
  }

  Future buildShowAnimatedMeetingDialog(BuildContext context, String id) async {
    Map<String, dynamic>? params = await showAnimatedDialog(
      duration: Duration(seconds: 1),
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
            child: MeetSettings(
          groupId: id,
        ));
      },
      animationType: DialogTransitionType.slideFromBottom,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    if (params != null) {
      VxNavigator.of(context).push(Uri.parse('/meet'), params: params);
    }
  }

  void scheduleCalenderEventAndMeetForLater(CalendarEventModel event) {
    String meetLink = HOST_URL +
        'meet?id=${widget.group.id!}&sub=${event.name.replaceAll(' ', '+')}';

    final MessageModel message = MessageModel(
        id: const Uuid().v4(),
        type: Type.TEXT,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: '''A meeting is scheduled 
from ${event.begin.format(kDateRangeFormat)} 
to ${event.end.format(kDateRangeFormat)}
                  
on subject : ${event.name}

joining link is: $meetLink ''',
        author: Author(id: FirestoreService.instance.firebaseUser!.uid));
    FirestoreService.instance.createMessageDoc(message, widget.group.id!);
    FirestoreService.instance.createEventDoc(EventModel(
        eventBegin: event.begin.millisecondsSinceEpoch,
        eventEnd: event.end.millisecondsSinceEpoch,
        eventColorCode: eventColors.indexOf(event.eventColor),
        eventMeetLink: meetLink,
        eventSubject: event.name,
        members: widget.group.members));
  }
}
