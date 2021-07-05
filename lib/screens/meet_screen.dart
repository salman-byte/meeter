import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:meeter/screens/chat_page.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:meeter/utils/authStatusNotifier.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import 'authUI.dart';

class Meeting extends StatefulWidget {
  final String subject;
  final bool isAudioOnly;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final String id;

  const Meeting(
      {Key? key,
      required this.subject,
      this.isAudioOnly = true,
      this.isAudioMuted = true,
      this.isVideoMuted = true,
      required this.id})
      : super(key: key);
  @override
  _MeetingState createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "plugintestroom");
  final nameText = TextEditingController();
  final emailText = TextEditingController(text: "fake@email.com");
  final iosAppBarRGBAColor =
      TextEditingController(text: "#0080FF80"); //transparent blue
  bool kIsWeb = true;

  @override
  void initState() {
    super.initState();
    print('**********************id: ' + widget.id);
    print('**********************subject: ' + widget.subject);
    Provider.of<AppStateNotifier>(context, listen: false)
        .setCurrentSelectedChatViaGroupId = widget.id;
    Future.delayed(Duration(seconds: 5), () {
      JitsiMeet.addListener(JitsiMeetingListener(
          onConferenceWillJoin: _onConferenceWillJoin,
          onConferenceJoined: _onConferenceJoined,
          onConferenceTerminated: _onConferenceTerminated,
          onError: _onError));
      _joinMeeting();
    });
    // toggleChatBox();
  }

  @override
  void didChangeDependencies() {
    String? name = Provider.of<AuthStatusNotifier>(context, listen: false)
        .currentUser
        ?.displayName;
    nameText.text = name ?? 'anonymous';
    Provider.of<AppStateNotifier>(context, listen: false)
        .setCurrentSelectedChatViaGroupId = widget.id;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        body: Container(
            child: VxDevice(
          mobile: Expanded(
              child: JitsiMeetConferencing(
            extraJS: [
              // extraJs setup example
              '<script>function echo(){console.log("echo!!!")};</script>',
              '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
            ],
          )),
          web: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            ChatScreenSideMenu(groupId: widget.id),
            Expanded(
              child: JitsiMeetConferencing(
                extraJS: [
                  // '<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>'
                  //     '<script src="https://meet.jit.si/libs/lib-jitsi-meet.min.js"></script>'
                  // extraJs setup example
                  '<script>function echo(){console.log("echo!!!")};</script>',
                  '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                ],
              ),
            ),
          ]),
        )),
      ),
    );
  }

  _joinMeeting() async {
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.INVITE_ENABLED: false,
      FeatureFlagEnum.RECORDING_ENABLED: false,
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
      FeatureFlagEnum.CHAT_ENABLED: false,
      FeatureFlagEnum.ADD_PEOPLE_ENABLED: false,
      FeatureFlagEnum.CALENDAR_ENABLED: false
    };
    if (!kIsWeb) {
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
        // featureFlag.callIntegrationEnabled = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
        // featureFlag.pipEnabled = false;
      }
    }
    // Define meetings options here
    var options = JitsiMeetingOptions(room: widget.subject.replaceAll(' ', ''))
      ..serverURL = serverUrl
      ..subject = widget.subject
      ..userDisplayName = nameText.text
      ..userEmail = emailText.text
      ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
      ..audioOnly = widget.isAudioOnly
      ..audioMuted = widget.isAudioMuted
      ..videoMuted = widget.isVideoMuted
      // ..featureFlags = featureFlag.to
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": widget.subject.replaceAll(' ', ''),
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": nameText.text}
      };

    debugPrint("JitsiMeetingOptions: $options");
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                  VxNavigator.of(context).pop();
                }),
          ]),
    );
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}

class ChatScreenSideMenu extends StatefulWidget {
  final String groupId;
  const ChatScreenSideMenu({
    Key? key,
    required this.groupId,
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
  String? noteText;
  @override
  void initState() {
    super.initState();
  }

  updateNote() {
    FirestoreService.instance.getNoteDoc(widget.groupId).then((value) {
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
    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
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
                      : Column(mainAxisSize: MainAxisSize.max, children: [
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
                                    onPressed: () {
                                      if (FirestoreService
                                              .instance.firebaseUser ==
                                          null) {
                                        buildShowAnimatedSignUpDialog(context);
                                      } else {
                                        FirestoreService.instance
                                            .createNoteDoc(
                                                noteText ??
                                                    '' + noteController.text,
                                                widget.groupId)
                                            .then((value) =>
                                                noteController.text = '');
                                      }
                                    },
                                  ),
                                )
                              : Container(),
                        ])),
            ),
            AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: showChatBox ? context.safePercentWidth * 50 : 0,
                height: showChatBox ? context.safePercentHeight * 100 : 0,
                child: Consumer<AppStateNotifier>(
                  builder: (context, appstate, child) => AnimatedSwitcher(
                    duration: Duration(milliseconds: 700),
                    child: !showChatBox
                        ? Container()
                        : appstate.getCurrentSelectedChat == null
                            ? Scaffold(
                                body: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        'You\'re currently signed out, you need to sign in first to access chats...'),
                                    SizedBox(
                                      height: context.safePercentHeight * 10,
                                    ),
                                    CustomButton(
                                      text: 'sign in',
                                      onPressed: () {
                                        buildShowAnimatedSignUpDialog(context);
                                      },
                                    )
                                  ],
                                ),
                              ))
                            : Expanded(child: ChatPage()),
                  ),
                )),
          ],
        ));
  }

  buildShowAnimatedSignUpDialog(BuildContext context) {
    return VxNavigator.of(context).push(Uri.parse('/signup'));
    // return showAnimatedDialog(
    //   duration: Duration(seconds: 1),
    //   context: context,
    //   barrierDismissible: true,
    //   builder: (BuildContext context) {
    //     return Scaffold(
    //         body: SignInSignUpFlow(
    //       inDialogMode: true,
    //     ));
    //   },
    //   animationType: DialogTransitionType.slideFromBottom,
    //   curve: Curves.fastLinearToSlowEaseIn,
    // );
  }
}
