import 'package:flutter/material.dart';
import 'package:meeter/screens/chat_page.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:meeter/utils/authStatusNotifier.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

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
  Color _color = Color(0xFF6F61E8);
  // Color _color = Colors.amber;
  bool showDrawer = false;
  bool showChatBox = false;
  bool showNotesBox = false;
  TextEditingController noteController = TextEditingController();
  AuthStatusNotifier? _authStatusNotifier;
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
        return Container(
            // duration: Duration(milliseconds: 500),
            child: Row(
          children: [
            Column(
              children: [
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
                              // updateNote();
                              setState(() {
                                showChatBox = false;
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
                                  // updateNote();
                                  setState(() {
                                    showChatBox = false;
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
                                showNotesBox = false;
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
                                    showNotesBox = false;
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
              color: Colors.amber,
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
                                              hintText:
                                                  'Write your thoughts...'),
                                        ),
                                      ],
                                    ),
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
                                                        noteController.text
                                                            .trim(),
                                                        groupId!);
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
