import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:meeter/models/eventModel.dart';
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/models/messageModel.dart';
import 'package:meeter/models/userModel.dart';
import 'package:meeter/res/colors.dart';
import 'package:meeter/utils/extensions.dart';
import 'package:meeter/utils/constants.dart';
import 'package:meeter/widgets/create_event_dialog.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:meeter/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/create_group.dart';
import 'package:meeter/widgets/chat_list_tile.dart';

class CreateMeet extends StatefulWidget {
  const CreateMeet({Key? key}) : super(key: key);

  @override
  _CreateMeetState createState() => _CreateMeetState();
}

class _CreateMeetState extends State<CreateMeet> {
  bool isCreateNewGroupChecked = false;
  List<GroupModel> allAvailableGroups = [];
  GroupModel? selectedGroup;
  MessageModel? _messageModel;
  CalendarEventModel? _event;
  List<UserData> list = [];
  List<UserData> suggestionsList = [];
  List<UserData> selectedList = [];
  String groupName = 'unnamed';
  GroupModel group =
      GroupModel(modifiedAt: Timestamp.now(), createdAt: Timestamp.now());
  FirestoreService _firestoreService = FirestoreService.instance;

  @override
  void initState() {
    getListOfUsers();
    FirestoreService.instance.getAllGroups().then((value) {
      setState(() {
        allAvailableGroups = value;
      });
    });
    super.initState();
  }

  getListOfUsers() async {
    list = await FirestoreService.instance.getAllUsersExcludingCurrentUser();
    setState(() {
      suggestionsList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Schedule new meeting',
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            Divider(),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: context.safePercentWidth * 20),
              child: buildRowForNewGroupCheckBox(),
            ),
            SizedBox(height: 10),
            Divider(),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: !isCreateNewGroupChecked
                  ? buildGroupListToSelect(context)
                  : buildContainerForGroupDataInput(),
            ),
            Divider(),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: context.safePercentWidth * 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add meeting details :',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  CustomButton(
                    text: 'add meeting',
                    autoSize: true,
                    onPressed: () async {
                      final CalendarEventModel? event = await showDialog(
                          context: context,
                          builder: (context) => const CreateEventDialog());
                      if (event != null) {
                        showEventDataOnScreen(event);
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: context.safePercentWidth * 20),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_messageModel?.text ?? ''),
                    SizedBox(height: 10),
                    Text(isCreateNewGroupChecked ? 'members:' : 'group'),
                    (selectedGroup == null && selectedList.length == 0)
                        ? Container()
                        : Wrap(
                            children: isCreateNewGroupChecked
                                ? selectedList.fold(
                                    [],
                                    (previousValue, element) => [
                                          ...previousValue,
                                          Chip(
                                              label: Text(
                                                  element.displayName ?? ''))
                                        ])
                                : [
                                    Chip(label: Text(selectedGroup?.name ?? ''))
                                  ])
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            (selectedGroup == null && selectedList.length == 0)
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: context.safePercentWidth * 20),
                    child: CustomButton(
                      text: 'final submit',
                      onPressed: () async {
                        await createGroup();
                        await scheduleCalenderEventAndMeetForLater(_event!);
                        resetState();
                        context.showToast(msg: 'meeting schedule done');
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }

  resetState() {
    isCreateNewGroupChecked = false;
    allAvailableGroups = [];
    selectedGroup = null;
    _messageModel = null;
    _event = null;
    list = [];
    suggestionsList = [];
    selectedList = [];
    groupName = 'unnamed';
    group = GroupModel(modifiedAt: Timestamp.now(), createdAt: Timestamp.now());
  }

  Column buildContainerForGroupDataInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: context.safePercentWidth * 20),
          child: Text(
            'Enter group details',
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: context.safePercentWidth * 20),
          child: CustomTextField(
            labelText: 'Group name',
            onChanged: (String? input) {
              input == null ? groupName = 'unnamed' : groupName = input;
            },
          ),
        ),
        SizedBox(height: 30),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: context.safePercentWidth * 20),
          child: Text('Select Members:'),
        ),
        SizedBox(height: 10),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: context.safePercentWidth * 20),
          child: Wrap(
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
        ),
        SizedBox(height: 10),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: context.safePercentWidth * 20),
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
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: context.safePercentWidth * 20),
          child: Wrap(
            children: suggestionsList.fold([], (previousValue, element) {
              if (!selectedList.contains(element))
                return [
                  ...previousValue,
                  ListTile(
                    onTap: () {
                      try {
                        if (!selectedList.contains(element))
                          selectedList.add(element);
                        // suggestionsList.remove(suggestionsList[index]);
                      } catch (e) {
                        print(e);
                      }
                      setState(() {});
                    },
                    title: Text(element.displayName!),
                    subtitle: Text(element.email!),
                  )
                ];
              else
                return previousValue;
            }),
          ),
        ),
      ],
    );
  }

  Future createGroup() async {
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
    await _firestoreService.createGroupDoc(group);
    return;
  }

  Future scheduleCalenderEventAndMeetForLater(CalendarEventModel event) async {
    String meetLink =
        'meeter-app-17608.web.app/meet?id=${selectedGroup!.id!}&sub=${event.name.replaceAll(' ', '+')}';
    await FirestoreService.instance.createMessageDoc(_messageModel!, group.id!);
    await FirestoreService.instance.createEventDoc(EventModel(
        eventBegin: event.begin.millisecondsSinceEpoch,
        eventEnd: event.end.millisecondsSinceEpoch,
        eventColorCode: eventColors.indexOf(event.eventColor),
        eventMeetLink: meetLink,
        eventSubject: event.name,
        members: group.members));
    return;
  }

  Padding buildGroupListToSelect(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.safePercentWidth * 20),
      child: Wrap(
        children: allAvailableGroups.fold(
            [],
            (previousValue, element) => [
                  ...previousValue,
                  SizedBox(
                      width: context.safePercentWidth * 20,
                      height: context.safePercentHeight * 10,
                      child: ChatListTile(
                          onTileTap: () {
                            setState(() {
                              selectedGroup = element;
                            });
                          },
                          isSelected: selectedGroup?.id == element.id,
                          title: element.name!,
                          subTitle: element.members?.length.toString() ?? '',
                          avatorUrl: ''))
                ]),
      ),
    );
  }

  Row buildRowForNewGroupCheckBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'create new group',
          style: Theme.of(context).textTheme.headline5,
        ),
        Checkbox(
            value: isCreateNewGroupChecked,
            onChanged: (value) {
              setState(() {
                value! ? selectedList.clear() : selectedGroup = null;
                isCreateNewGroupChecked = value;
              });
            })
      ],
    );
  }

  void showEventDataOnScreen(CalendarEventModel event) {
    String meetLink =
        'meeter-app-17608.web.app/meet?id=${selectedGroup!.id!}&sub=${event.name.replaceAll(' ', '+')}';

    MessageModel messageModel = MessageModel(
        id: const Uuid().v4(),
        type: Type.TEXT,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: '''A meeting is scheduled 
from ${event.begin.format(kDateRangeFormat)} 
to ${event.end.format(kDateRangeFormat)}
                                  
on subject : ${event.name}
                
joining link is: $meetLink ''',
        author: Author(id: FirestoreService.instance.firebaseUser!.uid));

    setState(() {
      _event = event;
      _messageModel = messageModel;
    });
  }
}
