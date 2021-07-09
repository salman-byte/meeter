import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meeter/screens/chat_page.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:meeter/utils/authStatusNotifier.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:webviewx/webviewx.dart';

import 'authUI.dart';

class Meeting extends StatefulWidget {
  final String subject;
  final String id;

  const Meeting({Key? key, required this.subject, required this.id})
      : super(key: key);
  @override
  _MeetingState createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> {
  final nameText = TextEditingController();
  User? firebaseUser = FirestoreService.instance.firebaseUser;

  bool kIsWeb = true;

  @override
  void initState() {
    super.initState();
    print('**********************id: ' + widget.id);
    print('**********************subject: ' + widget.subject);
    Provider.of<AppStateNotifier>(context, listen: false)
        .setCurrentSelectedChatViaGroupId = widget.id;
    intializeUserData();
  }

  intializeUserData() async {
    String name = 'anonymous';
    print('name is: $name');
    nameText.text = name;
    if (firebaseUser != null)
      await FirestoreService.instance
          .getCurrentUserDocData(uid: firebaseUser!.uid)
          .then((value) {
        print('display is: ${value?.displayName}');
        setState(() {
          nameText.text = value?.displayName ?? 'anonymous';
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    // JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    // nameText.text =
    //     Provider.of<AuthStatusNotifier>(context).currentUser?.displayName ??
    //         'anonymous';
    print('name in build method is: ${nameText.text}');

    double height = context.safePercentHeight * 100;
    return MaterialApp(
      home: Scaffold(
        body: Consumer<AppStateNotifier>(
          builder: (context, appstate, child) => Container(
              child: VxDevice(
            mobile: Expanded(child: Container()
                // child: JitsiMeetConferencing(
                //   extraJS: [
                //     // extraJs setup example
                //     '<script>function echo(){console.log("echo!!!")};</script>',
                //     '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                //   ],
                // ),
                ),
            web: Row(children: [
              ChatScreenSideMenu(),
              Flexible(
                child: WebViewForMeetIntegration(
                    subject: widget.subject,
                    nameText: nameText,
                    height: height),
              ),
            ]),
          )),
        ),
      ),
    );
  }
}

class WebViewForMeetIntegration extends StatelessWidget {
  const WebViewForMeetIntegration({
    Key? key,
    required this.subject,
    required this.nameText,
    required this.height,
  }) : super(key: key);

  final TextEditingController nameText;
  final double height;
  final String subject;

  @override
  Widget build(BuildContext context) {
    return WebViewX(
      onWebResourceError: (error) {
        print(error.toString());
      },
      initialContent: """
    <!DOCTYPE html>
    <body style="margin: 0;">
        <div id="meet"></div>
        <script src='https://meet.jit.si/external_api.js'></script>
        <script>
              const domain = 'meet.jit.si';
              const options = {
                  roomName: '${subject.replaceAll(' ', '')}',
                  userInfo: {
                    displayName: '${nameText.text}'
                  },
                  configOverwrite: {
                    requireDisplayName: false,
                    enableWelcomePage: false,
                    toolbarButtons: [
       'microphone', 'camera', 'desktop', 'fullscreen', 'hangup', 'raisehand',
       
       'tileview'
    ],
                     startWithAudioMuted: true },
                  interfaceConfigOverwrite: { 
                      SHOW_CHROME_EXTENSION_BANNER: false,

    SHOW_DEEP_LINKING_IMAGE: false,
    SHOW_JITSI_WATERMARK: false,
    SHOW_POWERED_BY: false,
    SHOW_PROMOTIONAL_CLOSE_PAGE: false,
                    DISABLE_DOMINANT_SPEAKER_INDICATOR: true },
                  width: '100%',
                  height: $height,
                  parentNode: document.querySelector('#meet')
              };
              const api = new JitsiMeetExternalAPI(domain, options);
        </script>
    </body>
    </html>""",
      initialSourceType: SourceType.HTML,
    );
  }
}

class ChatScreenSideMenu extends StatefulWidget {
  const ChatScreenSideMenu({
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenSideMenuState createState() => _ChatScreenSideMenuState();
}

class _ChatScreenSideMenuState extends State<ChatScreenSideMenu> {
  late double chatWidth = 25;
  late double chatheight = 25;
  Color _color = Colors.amber;
  bool showDrawer = false;
  bool showChatBox = false;
  bool showNotesBox = false;
  TextEditingController noteController = TextEditingController();
  AuthStatusNotifier? _authStatusNotifier;
  String? noteText;
  String? groupId;
  @override
  void initState() {
    _authStatusNotifier =
        Provider.of<AuthStatusNotifier>(context, listen: false);
    groupId = Provider.of<AppStateNotifier>(context, listen: false)
        .getCurrentSelectedChat
        ?.id;
    super.initState();
  }

  updateNote() {
    if (groupId != null)
      FirestoreService.instance.getNoteDoc(groupId!).then((value) {
        setState(() {
          noteText = value;
        });
      });
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _authStatusNotifier = Provider.of<AuthStatusNotifier>(context);
    return Consumer<AppStateNotifier>(
      builder: (context, appstate, child) {
        groupId = appstate.getCurrentSelectedChat?.id ?? groupId;
        print('groupId in build method is: $groupId');
        return Container(
            // duration: Duration(milliseconds: 500),
            child: Row(
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  // height: context.safePercentHeight * 100,
                  color: Colors.blue,
                  child: RotatedBox(
                    quarterTurns: showDrawer ? 1 : 3,
                    child: IconButton(
                      icon: Icon(Icons.expand_more),
                      onPressed: () {
                        setState(() {
                          showDrawer = !showDrawer;
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: !showDrawer
                        ? IconButton(
                            icon: !showNotesBox
                                ? Icon(Icons.notes)
                                : Icon(Icons.close),
                            onPressed: () {
                              updateNote();
                              setState(() {
                                showNotesBox = !showNotesBox;
                              });
                            },
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Notes'),
                              IconButton(
                                icon: showNotesBox
                                    ? Icon(Icons.expand_less)
                                    : Icon(Icons.expand_more),
                                onPressed: () {
                                  updateNote();
                                  setState(() {
                                    showNotesBox = !showNotesBox;
                                  });
                                },
                              ),
                            ],
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: !showDrawer
                        ? IconButton(
                            icon: !showChatBox
                                ? Icon(Icons.chat_bubble)
                                : Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                showChatBox = !showChatBox;
                              });
                            },
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Chats'),
                              IconButton(
                                icon: showChatBox
                                    ? Icon(Icons.expand_less)
                                    : Icon(Icons.expand_more),
                                onPressed: () {
                                  setState(() {
                                    showChatBox = !showChatBox;
                                  });
                                },
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              color: _color,
              width: showNotesBox ? context.safePercentWidth * 25 : 0,
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: !showNotesBox
                      ? Container()
                      : Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      noteText != null
                                          ? Text(noteText!)
                                          : Container(),
                                      TextField(
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        controller: noteController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Write your thoughts...'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              noteController.text != ''
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomButton(
                                        text: 'save note',
                                        onPressed: (FirestoreService.instance
                                                        .firebaseUser ==
                                                    null ||
                                                groupId == null)
                                            ? null
                                            : () {
                                                FirestoreService.instance
                                                    .createNoteDoc(
                                                        noteText ??
                                                            '' +
                                                                noteController
                                                                    .text,
                                                        groupId!)
                                                    .then((value) =>
                                                        noteController.text =
                                                            '');
                                              },
                                      ),
                                    )
                                  : Container(),
                              (FirestoreService.instance.firebaseUser == null ||
                                      groupId == null)
                                  ? Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            'join the meet from group chat in order to save notes for later.'),
                                      ),
                                    )
                                  : Container(),
                            ])),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              width: showChatBox
                  ? (FirestoreService.instance.firebaseUser == null ||
                          groupId == null)
                      ? context.safePercentHeight * 20
                      : context.safePercentWidth * 50
                  : 0,
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: !showChatBox
                      ? Container()
                      : (FirestoreService.instance.firebaseUser == null ||
                              groupId == null)
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
                          : OverflowBox(
                              maxHeight: context.safePercentHeight * 100,
                              maxWidth: context.safePercentWidth * 50,
                              child: ChatPage())),
            )
          ],
        ));
      },
    );
  }
}
