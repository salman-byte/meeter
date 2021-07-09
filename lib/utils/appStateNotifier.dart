import 'package:flutter/cupertino.dart';
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/services/firestoreService.dart';

///
///its extends [ChangeNotifier] class is used to listen and maintain which group is selected by user
///
/// [setCurrentSelectedChat] takes a group model and notifies listeners about the new selected group
///
/// [setCurrentSelectedChatViaGroupId] takes a group id String and notifies listeners about the new selected group
///
class AppStateNotifier extends ChangeNotifier {
  GroupModel? _currentSelectedChatGroup;

  ///set the current selected group and notifies listeners via group model
  set setCurrentSelectedChat(GroupModel chatGroup) {
    _currentSelectedChatGroup = chatGroup;
    notifyListeners();
  }

  ///set the current selected group and notifies listeners via group id String
  set setCurrentSelectedChatViaGroupId(String groupId) {
    FirestoreService.instance.getGroupDoc(groupId).then((value) {
      _currentSelectedChatGroup = value;
      notifyListeners();
    });
  }

  /// can be used in the need for rebuilding the widget which is listening to [AppStateNotifier]
  rebuildWidget() {
    notifyListeners();
  }

  GroupModel? get getCurrentSelectedChat => _currentSelectedChatGroup;
}
