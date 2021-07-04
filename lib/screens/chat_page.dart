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
    currentGroupId = appStateNotifier!.getCurrentSelectedChat!.id;
    // _messageStream = FirestoreService.instance.getMessagesAsStreamFromDataBase(
    //     appStateNotifier!.getCurrentSelectedChat!.id!);
    // _loadMessages();
    initializeChats();
  }

  initializeChats() {
    currentGroupId = appStateNotifier!.getCurrentSelectedChat!.id;
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
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
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
    // MessageModel newMessage = MessageModel(
    //   text: textMessage.text,
    //   author: Author(te)
    // );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    List<types.Message> messages = <types.Message>[];
    _messageStream!.listen((event) {}).onData((data) {
      data.forEach((e) {
        if (!messages.contains(types.Message.fromJson(e.toMap())))
          messages.add(types.Message.fromJson(e.toMap()));
      });
      // print(messages);
      _messages = messages;
      // setState(() {
      // });
      appStateNotifier!.rebuildWidget();
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = _themeProvider!.themeData();
    return Consumer<AppStateNotifier>(builder: (context, appstate, child) {
      if (currentGroupId != appstate.getCurrentSelectedChat!.id) {
        appStateNotifier = appstate;
        initializeChats();
      }
      return
          // (appstate.getCurrentSelectedChat!.id != widget.groupId ||
          //         _messages.length == 0)
          //     ?
          //     // _messages.clear()
          //     // _loadMessages();

          //     LinearProgressIndicator()
          //     : Container(),
          Expanded(
        child: new Chat(
          theme: DefaultChatTheme(
              // inputBorderRadius: BorderRadius.circular(30),
              // inputBackgroundColor:
              //     _themeProvider!.themeMode().inputBackgroundColor!,
              backgroundColor: currentTheme.backgroundColor),
          messages: _messages,
          onAttachmentPressed: _handleAtachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          user: _user,
        ),
      );
    });
  }
}

class MeetSettings extends StatefulWidget {
  const MeetSettings({Key? key}) : super(key: key);

  @override
  _MeetSettingsState createState() => _MeetSettingsState();
}

class _MeetSettingsState extends State<MeetSettings> {
  final subjectText = TextEditingController(text: "Subject");

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
            width: double.maxFinite,
            child: CustomButton(
              onPressed: () {
                VxNavigator.of(context).pop();
                Future.delayed(Duration(seconds: 1), () {
                  VxNavigator.of(context).push(Uri.parse('/meet'), params: {
                    'am': isAudioMuted,
                    'ao': isAudioOnly,
                    'vm': isVideoMuted,
                    'sub': subjectText.text
                  });
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
