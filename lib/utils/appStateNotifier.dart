import 'package:flutter/cupertino.dart';
import 'package:meeter/models/groupModel.dart';

class AppStateNotifier extends ChangeNotifier {
  GroupModel? _currentSelectedChatGroup;

  set setCurrentSelectedChat(GroupModel chatGroup) {
    _currentSelectedChatGroup = chatGroup;
    notifyListeners();
  }

  GroupModel? get getCurrentSelectedChat => _currentSelectedChatGroup;
}
