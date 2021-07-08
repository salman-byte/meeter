import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meeter/models/messageModel.dart';
import 'package:meeter/services/firebaseStorageService.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:meeter/utils/theme_notifier.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  bool attachmentBoxOpen = false;
  bool isAttachmentLoading = false;
  String? currentGroupId;
  ThemeProvider? _themeProvider;
  AppStateNotifier? appStateNotifier;
  final _user = types.User(id: FirestoreService.instance.firebaseUser!.uid);
  Stream<List<MessageModel>>? _messageStream;

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    appStateNotifier = Provider.of<AppStateNotifier>(context, listen: false);
    currentGroupId = appStateNotifier?.getCurrentSelectedChat?.id;

    initializeChats();
  }

  initializeChats() {
    currentGroupId = appStateNotifier?.getCurrentSelectedChat?.id;
    _messageStream = FirestoreService.instance.getMessagesAsStreamFromDataBase(
        appStateNotifier!.getCurrentSelectedChat!.id!);
    _loadMessages();
  }

  @override
  void dispose() {
    // _messageStream.s
    _messages.clear();
    super.dispose();
  }

  void _addMessage(types.Message message) {
    // print(message.toJson());
    MessageModel newMessage =
        MessageModel.fromJson(jsonEncode(message.toJson()));
    print(newMessage.toMap());
    FirestoreService.instance.createMessageDoc(
        newMessage, appStateNotifier!.getCurrentSelectedChat!.id!);
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAtachmentPressed() {
    setState(() {
      isAttachmentLoading = isAttachmentLoading ? !isAttachmentLoading : false;
      attachmentBoxOpen = !attachmentBoxOpen;
    });
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        isAttachmentLoading = true;
      });
      final uri = await FirebaseStorageService.instance.uploadImageAndGetUrl(
          imgName: result.files.single.name, data: result.files.single.bytes!);
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        name: result.files.single.name,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path ?? ''),
        size: result.files.single.size,
        uri: uri,
      );
      _handleAtachmentPressed();
      _addMessage(message);
    } else {
      // User canceled the picker
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().getImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.path.split('/').last;
      final uri = await FirebaseStorageService.instance
          .uploadImageAndGetUrl(imgName: name, data: bytes);
      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: name,
        size: bytes.length,
        uri: uri,
        width: image.width.toDouble(),
      );
      print(message.uri);
      print(result.path);
      _handleAtachmentPressed();
      _addMessage(message);
    } else {
      // User canceled the picker
    }
  }

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    _messageStream!.listen((event) {}).onData((data) {
      _messages.clear();
      _messages = data.fold(_messages, (previousValue, element) {
        return [types.Message.fromJson(element.toMap()), ...previousValue];
      });

      appStateNotifier?.rebuildWidget();
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = _themeProvider!.themeData();
    return Consumer<AppStateNotifier>(builder: (context, appstate, child) {
      if (currentGroupId != appstate.getCurrentSelectedChat?.id) {
        appStateNotifier = appstate;
        initializeChats();
      }
      return Column(children: [
        Expanded(
          child: new Chat(
            theme:
                DefaultChatTheme(backgroundColor: currentTheme.backgroundColor),
            isAttachmentUploading: isAttachmentLoading,
            messages: _messages,
            onAttachmentPressed: _handleAtachmentPressed,
            onMessageTap: _handleMessageTap,
            onPreviewDataFetched: _handlePreviewDataFetched,
            onSendPressed: _handleSendPressed,
            user: _user,
          ),
        ),
        AnimatedContainer(
          height: attachmentBoxOpen ? context.safePercentHeight * 15 : 0,
          duration: Duration(milliseconds: 500),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: !attachmentBoxOpen
                ? Container()
                : Wrap(
                    runSpacing: 5,
                    spacing: 5,
                    alignment: WrapAlignment.start,
                    children: [
                        iconCreation(
                          text: 'Photo',
                          icons: Icons.image_outlined,
                          onTap: () {
                            _handleImageSelection();
                          },
                        ),
                        iconCreation(
                            onTap: () {
                              _handleFileSelection();
                            },
                            text: 'File',
                            icons: Icons.attach_file),
                      ]),
          ),
        )
      ]);
    });
  }

  Widget iconCreation(
      {required IconData icons, required String text, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            // backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
          )
        ],
      ),
    );
  }
}

class MeetSettings extends StatefulWidget {
  final String groupId;
  const MeetSettings({Key? key, required this.groupId}) : super(key: key);

  @override
  _MeetSettingsState createState() => _MeetSettingsState();
}

class _MeetSettingsState extends State<MeetSettings> {
  final subjectText = TextEditingController();

  bool? isAudioOnly = true;
  bool? isAudioMuted = true;
  bool? isVideoMuted = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          TextField(
            controller: subjectText,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Subject",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Audio Only"),
            value: isAudioOnly,
            onChanged: _onAudioOnlyChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Audio Muted"),
            value: isAudioMuted,
            onChanged: _onAudioMutedChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Video Muted"),
            value: isVideoMuted,
            onChanged: _onVideoMutedChanged,
          ),
          Divider(
            height: 48.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 64.0,
            // width: double.maxFinite,
            child: CustomButton(
              onPressed: subjectText.text == ''
                  ? null
                  : () {
                      Navigator.of(context).pop({
                        'id': widget.groupId,
                        'am': isAudioMuted,
                        'ao': isAudioOnly,
                        'vm': isVideoMuted,
                        'sub': subjectText.text
                      });
                    },
              text: "Join Meeting",
            ),
          ),
          SizedBox(
            height: 48.0,
          ),
        ],
      ),
    );
  }

  _onAudioOnlyChanged(bool? value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool? value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool? value) {
    setState(() {
      isVideoMuted = value;
    });
  }
}
