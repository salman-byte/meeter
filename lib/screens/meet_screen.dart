import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

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
