import 'package:flutter/cupertino.dart';
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/services/firestoreService.dart';

class AppStateNotifier extends ChangeNotifier {
  GroupModel? _currentSelectedChatGroup;

  set setCurrentSelectedChat(GroupModel chatGroup) {
    _currentSelectedChatGroup = chatGroup;
    notifyListeners();
  }

  set setCurrentSelectedChatViaGroupId(String groupId) {
    FirestoreService.instance.getGroupDoc(groupId).then((value) {
      _currentSelectedChatGroup = value;
      notifyListeners();
    });
  }

  rebuildWidget() {
    notifyListeners();
  }

  GroupModel? get getCurrentSelectedChat => _currentSelectedChatGroup;
}
