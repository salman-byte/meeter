import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeter/models/messageModel.dart';
import 'package:meeter/screens/chatPageComponents.dart/attachmentBox.dart';
import 'package:meeter/services/firebaseStorageService.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:meeter/utils/authStatusNotifier.dart';
import 'package:meeter/utils/theme_notifier.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/src/user.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  bool isAttachmentLoading = false;
  ValueNotifier<bool> attachmentBoxOpen = ValueNotifier<bool>(false);
  String? currentGroupId;
  ThemeProvider? _themeProvider;
  AppStateNotifier? appStateNotifier;
  User? _user;
  Stream<List<MessageModel>>? _messageStream;

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    appStateNotifier = Provider.of<AppStateNotifier>(context, listen: false);
    _user = types.User(
        id: FirestoreService.instance.firebaseUser!.uid,
        firstName: Provider.of<AuthStatusNotifier>(context, listen: false)
            .currentUser
            ?.displayName);

    currentGroupId = appStateNotifier?.getCurrentSelectedChat?.id;

    initializeChats();
  }

  User configureUser() {
    _user = types.User(
        id: FirestoreService.instance.firebaseUser!.uid,
        firstName: Provider.of<AuthStatusNotifier>(context, listen: false)
            .currentUser
            ?.displayName);
    return _user ??
        types.User(
            id: FirestoreService.instance.firebaseUser!.uid,
            firstName: Provider.of<AuthStatusNotifier>(context, listen: false)
                .currentUser
                ?.displayName);
  }

  initializeChats() {
    currentGroupId = appStateNotifier?.getCurrentSelectedChat?.id;
    _messageStream = FirestoreService.instance.getMessagesAsStreamFromDataBase(
        appStateNotifier!.getCurrentSelectedChat!.id!);
    _user = types.User(
        id: FirestoreService.instance.firebaseUser!.uid,
        firstName: Provider.of<AuthStatusNotifier>(context, listen: false)
            .currentUser
            ?.displayName);
    _loadMessages();
  }

  @override
  void dispose() {
    // _messageStream.s
    _messages.clear();
    super.dispose();
  }

  void _addMessage(types.Message message) {
    MessageModel newMessage =
        MessageModel.fromJson(jsonEncode(message.toJson()));
    FirestoreService.instance.createMessageDoc(
        newMessage, appStateNotifier!.getCurrentSelectedChat!.id!);
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAtachmentPressed() {
    attachmentBoxOpen.value = !attachmentBoxOpen.value;
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        isAttachmentLoading = true;
      });
      final uri = await FirebaseStorageService.instance.uploadDocumentAndGetUrl(
          docName: result.files.single.name, data: result.files.single.bytes!);
      final message = types.FileMessage(
        author: _user ?? configureUser(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        name: result.files.single.name,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path ?? ''),
        size: result.files.single.size,
        uri: uri,
      );
      setState(() {
        isAttachmentLoading = false;
      });
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
        author: _user ?? configureUser(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: name,
        size: bytes.length,
        uri: uri,
        width: image.width.toDouble(),
      );
      setState(() {
        isAttachmentLoading = false;
      });
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
      author: _user ?? configureUser(),
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
      return Scaffold(
        body: Column(children: [
          Expanded(
            child: new Chat(
              theme: DefaultChatTheme(
                  backgroundColor: currentTheme.backgroundColor),
              isAttachmentUploading: isAttachmentLoading,
              messages: _messages,
              onAttachmentPressed: _handleAtachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              user: _user ?? configureUser(),
              showUserNames: true,
            ),
          ),
          AttachmentBox(
              attachmentBoxOpen: attachmentBoxOpen,
              handleImageSelection: _handleImageSelection,
              handleFileSelection: _handleFileSelection),
        ]),
      );
    });
  }
}
