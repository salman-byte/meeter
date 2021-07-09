import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/models/userModel.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:meeter/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

class PersonNameInputWidget extends StatefulWidget {
  const PersonNameInputWidget({
    Key? key,
  }) : super(key: key);

  @override
  _PersonNameInputWidgetState createState() => _PersonNameInputWidgetState();
}

class _PersonNameInputWidgetState extends State<PersonNameInputWidget> {
  List<UserData> list = [];
  List<UserData> suggestionsList = [];
  List<UserData> selectedList = [];
  String groupName = 'unnamed';
  GroupModel group =
      GroupModel(modifiedAt: Timestamp.now(), createdAt: Timestamp.now());
  FirestoreService _firestoreService = FirestoreService.instance;
  @override
  void initState() {
    // TODO: implement initState
    getListOfUsers();
    super.initState();
  }

  getListOfUsers() async {
    list = await FirestoreService.instance.getAllUsersExcludingCurrentUser();
    setState(() {
      suggestionsList = list;
    });
  }

  createGroup() async {
    if (_firestoreService.firebaseUser == null) {
      print('user not registered');
      return;
    }
    if (selectedList.length == 0) {
      print('no member selected');
      return;
    }
    group.name = groupName;
    group.createdBy = _firestoreService.firebaseUser!.uid;
    group.members = selectedList.fold([_firestoreService.firebaseUser!.uid],
        (previousValue, element) => [...previousValue!, element.uid!]);
    group.type = selectedList.length > 2 ? 1 : 2;
    group.id = const Uuid().v4();
    print('selected members');
    print(group.members);
    // await _firestoreService.createGroupDoc(group);
    context.pop(group);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: CustomTextField(
                  labelText: 'Group name',
                  onChanged: (String? input) {
                    input == null ? groupName = 'unnamed' : groupName = input;
                  },
                ),
              ),
              SizedBox(width: 10),
              selectedList.isEmpty
                  ? Container()
                  : CustomButton(
                      text: 'done',
                      autoSize: true,
                      onPressed: () {
                        createGroup();
                      },
                    )
            ],
          ),
        ),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Select Members:'),
        ),
        Wrap(
          direction: Axis.horizontal,
          children: selectedList.fold(
              [],
              (previousValue, element) => [
                    ...previousValue,
                    Chip(
                      onDeleted: () {
                        // suggestionsList.add(element);
                        selectedList.remove(element);
                        setState(() {});
                      },
                      label: Text(element.displayName!),
                    )
                  ]),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomTextField(
            labelText: 'Member name',
            // decoration: InputDecoration(),
            onChanged: (String query) {
              if (query.length != 0) {
                var lowercaseQuery = query.toLowerCase();
                suggestionsList = list.where((profile) {
                  return profile.displayName!
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      profile.email!
                          .toLowerCase()
                          .contains(query.toLowerCase());
                }).toList(growable: false)
                  ..sort((a, b) => a.displayName!
                      .toLowerCase()
                      .indexOf(lowercaseQuery)
                      .compareTo(b.displayName!
                          .toLowerCase()
                          .indexOf(lowercaseQuery)));
                setState(() {});
              } else {
                suggestionsList = list;
                setState(() {});
              }
            },
          ),
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: suggestionsList.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  try {
                    if (!selectedList.contains(suggestionsList[index]))
                      selectedList.add(suggestionsList[index]);
                    // suggestionsList.remove(suggestionsList[index]);
                  } catch (e) {
                    print(e);
                  }
                  setState(() {});
                },
                title: Text(suggestionsList[index].displayName!),
                subtitle: Text(suggestionsList[index].email!),
              );
            },
          ),
        )
      ],
    );
  }
}
