import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:meeter/utils/authStatusNotifier.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chat_page.dart';
import 'meetScreenComponents/embededWebPage.dart';
import 'meetScreenComponents/sideMenu.dart';

class Meeting extends StatefulWidget {
  final String subject;
  final String id;

  const Meeting({Key? key, required this.subject, required this.id})
      : super(key: key);
  @override
  _MeetingState createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> {
  User? firebaseUser;

  bool kIsWeb = true;

  @override
  void initState() {
    super.initState();
    intializeUserData();
  }

  intializeUserData() async {
    firebaseUser = FirestoreService.instance.firebaseUser;
    Provider.of<AppStateNotifier>(context, listen: false)
        .setCurrentSelectedChatViaGroupId = widget.id;

    if (firebaseUser != null)
      await FirestoreService.instance
          .getCurrentUserDocData(uid: firebaseUser!.uid)
          .then((value) {});
  }

  @override
  void dispose() {
    super.dispose();
    // JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double height = context.safePercentHeight * 100;
    return Scaffold(
      body: Consumer<AuthStatusNotifier>(
        builder: (context, authStatus, child) {
          if (authStatus.isUserAuthenticated && firebaseUser == null) {
            intializeUserData();
          }
          return Container(
              child: VxDevice(
            mobile: MeetScreenMobileView(widget: widget, height: height),
            web: Row(children: [
              ChatScreenSideMenu(),
              Flexible(
                child: WebViewForMeetIntegration(
                    subject: widget.subject, height: height),
              ),
            ]),
          ));
        },
      ),
    );
  }
}

class MeetScreenMobileView extends StatefulWidget {
  const MeetScreenMobileView({
    Key? key,
    required this.widget,
    required this.height,
  }) : super(key: key);

  final Meeting widget;
  final double height;

  @override
  _MeetScreenMobileViewState createState() => _MeetScreenMobileViewState();
}

class _MeetScreenMobileViewState extends State<MeetScreenMobileView> {
  PageController _pageController =
      PageController(initialPage: 1, keepPage: true);

  TextEditingController noteController = TextEditingController();
  AuthStatusNotifier? _authStatusNotifier;
  ValueNotifier<int> currentPageIndex = ValueNotifier<int>(0);
  String? groupId;
  @override
  void initState() {
    _authStatusNotifier =
        Provider.of<AuthStatusNotifier>(context, listen: false);
    groupId = Provider.of<AppStateNotifier>(context, listen: false)
        .getCurrentSelectedChat
        ?.id;
    updateNote();
    super.initState();
  }

  updateNote() {
    if (groupId != null)
      FirestoreService.instance.getNoteDoc(groupId!).then((value) {
        setState(() {
          noteController.text = value.trim();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    _authStatusNotifier = Provider.of<AuthStatusNotifier>(context);
    return Consumer<AppStateNotifier>(builder: (context, appstate, child) {
      groupId = appstate.getCurrentSelectedChat?.id ?? groupId;
      return Scaffold(
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: currentPageIndex,
          builder: (context, pageIndex, child) => BottomNavigationBar(
              currentIndex: pageIndex,
              onTap: (int buttonIndex) {
                currentPageIndex.value = buttonIndex;
                _pageController.animateToPage(buttonIndex,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.decelerate);
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.note_add), label: 'notes'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.video_label), label: 'call'),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'chat')
              ]),
        ),
        body: PageView(
          controller: _pageController,
          children: <Widget>[
            Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.amber,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OverflowBox(
                          child: Column(
                            children: [
                              // noteText != null
                              //     ? Text(noteText!)
                              //     : Container(),
                              TextField(
                                enableInteractiveSelection: true,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                controller: noteController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: 'Write your thoughts...'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  noteController.text != ''
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomButton(
                            text: 'save note',
                            onPressed: (FirestoreService
                                            .instance.firebaseUser ==
                                        null ||
                                    groupId == null)
                                ? null
                                : () {
                                    FirestoreService.instance.createNoteDoc(
                                        noteController.text.trim(), groupId!);
                                  },
                          ),
                        )
                      : Container(),
                  (FirestoreService.instance.firebaseUser == null ||
                          groupId == null)
                      ? Wrap(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                'join the meet from group chat in order to save notes for later.'),
                          ),
                        ])
                      : Container(),
                ]),
            WebViewForMeetIntegration(
                subject: widget.widget.subject, height: widget.height),
            (FirestoreService.instance.firebaseUser == null || groupId == null)
                ? Scaffold(
                    body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                              'You\'re currently signed out, you need to sign in first to access chats...'),
                        ),
                        SizedBox(
                          height: context.safePercentHeight * 10,
                        ),
                      ],
                    ),
                  ))
                : ChatPage(),
          ],
        ),
      );
    });
  }
}
