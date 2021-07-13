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
    FirestoreService.instance.getNoteDoc(widget.group.id!).then((value) {
      setState(() {
        noteText = value;
      });
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return VxDevice(
      mobile: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.group.name!,
          ),
          actions: chatActionButtonsList(context),
        ),
        body: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildAnimatedContainerForNotes(context),
              Expanded(child: ChatPage()),
            ]),
      ),
      web: Scaffold(
        body: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildContainerForAppBar(context),
              buildAnimatedContainerForNotes(context),
              Expanded(child: ChatPage()),
            ]),
      ),
    );
  }

  List<Widget> chatActionButtonsList(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.video_call),
          onPressed: () {
            buildShowAnimatedMeetingDialog(context, widget.group.id!);
          }),
      IconButton(
          icon: Icon(Icons.notes_outlined),
          onPressed: () {
            setState(() {
              notesOpen = !notesOpen;
            });
          }),
      IconButton(
          icon: Icon(Icons.access_time),
          onPressed: () async {
            final CalendarEventModel? event = await showDialog(
                context: context,
                builder: (context) => const CreateEventDialog());
            if (event != null) {
              scheduleCalenderEventAndMeetForLater(event);
            }
          }),
    ];
  }

  Container buildContainerForAppBar(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border(
            // top: BorderSide(
            //     width: 16.0, color: Colors.lightBlue.shade600),
            bottom: BorderSide(width: 3, color: Color(0xFF6F61E8)),
            // BorderSide(width: 2, color: Colors.lightBlue.shade900),
          ),
        ),
        height: context.safePercentHeight * 10,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                widget.group.name!,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Row(
                mainAxisSize: MainAxisSize.min,
                children: chatActionButtonsList(context))
            // PopupMenuButton(onSelected: (value) async {
            //   switch (value) {
            //     case 1:
            //       buildShowAnimatedMeetingDialog(context, widget.group.id!);
            //       break;
            //     case 2:
            //       final CalendarEventModel? event = await showDialog(
            //           context: context,
            //           builder: (context) => const CreateEventDialog());
            //       if (event != null) {
            //         scheduleCalenderEventAndMeetForLater(event);
            //       }
            //       break;
            //     case 3:
            //       setState(() {
            //         notesOpen = !notesOpen;
            //       });
            //       break;
            //     default:
            //   }

            //   // VxNavigator.of(context).push(Uri.parse('/meet'));
            // }, itemBuilder: (context) {
            //   return <PopupMenuItem>[
            //     PopupMenuItem(value: 1, child: Text('Start meeting')),
            //     PopupMenuItem(value: 2, child: Text('Schedule meeting')),
            //     PopupMenuItem(value: 3, child: Text('Notes')),
            //   ];
            // })
          ],
        ));
  }

  AnimatedContainer buildAnimatedContainerForNotes(BuildContext context) {
    return AnimatedContainer(
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
    );
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
