import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';
import 'package:meeter/constants/constants.dart';
import 'package:meeter/models/eventModel.dart';
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/models/messageModel.dart';
import 'package:meeter/models/userModel.dart';
import 'package:meeter/res/colors.dart';
import 'package:meeter/utils/extensions.dart';
import 'package:meeter/utils/constants.dart';
import 'package:meeter/utils/theme_notifier.dart';
import 'package:meeter/widgets/create_event_dialog.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:meeter/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/widgets/chat_list_tile.dart';

class CreateMeet extends StatefulWidget {
  const CreateMeet({Key? key}) : super(key: key);

  @override
  _CreateMeetState createState() => _CreateMeetState();
}

class _CreateMeetState extends State<CreateMeet> {
  GlobalKey<FormState> _formkey = GlobalKey();

  bool isCreateNewGroupChecked = false;
  bool isStep1Complete = false;
  bool isStep2Complete = false;
  List<GroupModel> allAvailableGroups = [];
  ThemeProvider? _themeProvider;
  GroupModel? selectedGroup;
  MessageModel? _messageModel;
  CalendarEventModel? _event;
  List<UserData> list = [];
  List<UserData> suggestionsList = [];
  List<UserData> selectedList = [];
  String groupName = 'unnamed';
  String newGroupId = const Uuid().v4();
  GroupModel group =
      GroupModel(modifiedAt: Timestamp.now(), createdAt: Timestamp.now());
  FirestoreService _firestoreService = FirestoreService.instance;

  @override
  void initState() {
    getListOfUsers();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    FirestoreService.instance.getAllGroupsRelatedToCurrentUser().then((value) {
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
      appBar: !(context.mdDeviceType == MobileDeviceType.handset)
          ? null
          : AppBar(
              title: Text(
                'Start chat/ Schedule meeting',
              ),
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: (context.mdDeviceType == MobileDeviceType.handset)
                  ? Container()
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Start chat/ Schedule new meeting',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
            ),
            Divider(),
            SizedBox(height: 15),
            Text(
              'Step 1:',
              style: Theme.of(context).textTheme.headline5,
            ),
            Divider(),
            buildStep1form(context),
            buildAnimatedContainerForForm1Summary(),
            Divider(),
            SizedBox(height: 15),
            Text(
              'Step 2:',
              style: Theme.of(context).textTheme.headline5,
            ),
            Divider(),
            buildStep2Form(context),
            SizedBox(height: 10),
            buildStep2FormSummary(context),
            SizedBox(height: 20),
            (!isStep1Complete || !isStep2Complete)
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: context.safePercentWidth * 20),
                    child: CustomButton(
                      text: 'final submit',
                      onPressed: () async {
                        if (selectedGroup == null) {
                          await createGroup();
                        }
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

  Padding buildStep2FormSummary(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.safePercentWidth * 20),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: !isStep2Complete
            ? Container()
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Step 2 summary',
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 10),
                Text(_messageModel?.text ?? ''),
                Divider()
              ]),
      ),
    );
  }

  Padding buildStep2Form(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.safePercentWidth * 10),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: isStep2Complete
            ? Container()
            : VxDevice(
                mobile: buildRowForStep2FormMobileView(context),
                web: buildRowForStep2FormWebView(context),
              ),
      ),
    );
  }

  Wrap buildRowForStep2FormMobileView(BuildContext context) {
    return Wrap(
      spacing: double.maxFinite,
      direction: Axis.horizontal, alignment: WrapAlignment.spaceBetween,
      // mainAxisSize: MainAxisSize.max,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Add meeting details',
              style: Theme.of(context).textTheme.headline5,
            )),
        Align(
          alignment: Alignment.topRight,
          child: CustomButton(
            text: 'add meeting',
            autoSize: true,
            onPressed: !isStep1Complete
                ? null
                : () async {
                    final CalendarEventModel? event = await showDialog(
                        context: context,
                        builder: (context) => const CreateEventDialog());
                    if (event != null) {
                      showEventDataOnScreen(event);
                    }
                  },
          ),
        ),
      ],
    );
  }

  Row buildRowForStep2FormWebView(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Add meeting details',
          style: Theme.of(context).textTheme.headline5,
        ),
        CustomButton(
          text: 'add meeting',
          autoSize: true,
          onPressed: !isStep1Complete
              ? null
              : () async {
                  final CalendarEventModel? event = await showDialog(
                      context: context,
                      builder: (context) => const CreateEventDialog());
                  if (event != null) {
                    showEventDataOnScreen(event);
                  }
                },
        ),
      ],
    );
  }

  Padding buildStep1form(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.safePercentWidth * 10),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: isStep1Complete
            ? Container()
            : VxDevice(
                mobile: buildColumnForMobileViewForm1(context),
                web: buildColumnForWebViewForm1(context),
              ),
      ),
    );
  }

  Column buildColumnForMobileViewForm1(BuildContext context) {
    return Column(
      children: [
        buildRowForNewGroupCheckBoxForMobile(),
        SizedBox(height: 10),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: !isCreateNewGroupChecked
              ? buildGroupListToSelect(context)
              : buildContainerForGroupDataInput(),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            text: 'done',
            autoSize: true,
            onPressed: selectedGroup == null && selectedList.length == 0
                ? null
                : () {
                    setState(() {
                      isStep1Complete = true;
                    });
                  },
          ),
        ),
        Divider(height: 10),
        SizedBox(height: 10),
      ],
    );
  }

  Column buildColumnForWebViewForm1(BuildContext context) {
    return Column(
      children: [
        buildRowForNewGroupCheckBoxForWeb(),
        SizedBox(height: 10),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: !isCreateNewGroupChecked
              ? buildGroupListToSelect(context)
              : buildContainerForGroupDataInput(),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            text: 'done',
            autoSize: true,
            onPressed: selectedGroup == null && selectedList.length == 0
                ? null
                : () {
                    setState(() {
                      isStep1Complete = true;
                    });
                  },
          ),
        ),
        Divider(height: 10),
        SizedBox(height: 10),
      ],
    );
  }

  AnimatedContainer buildAnimatedContainerForForm1Summary() {
    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        child: !isStep1Complete
            ? Container()
            : Padding(
                padding: EdgeInsets.only(left: context.safePercentWidth * 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step 1 summary',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    SizedBox(height: 10),
                    !isCreateNewGroupChecked
                        ? Container()
                        : Text('group name: $groupName '),
                    !isCreateNewGroupChecked
                        ? Container()
                        : SizedBox(height: 10),
                    (selectedGroup == null && selectedList.length == 0)
                        ? Container()
                        : Wrap(
                            children: [
                              Text(isCreateNewGroupChecked
                                  ? 'members: '
                                  : 'Selected group name: '),
                              Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: isCreateNewGroupChecked
                                      ? selectedList.fold(
                                          [],
                                          (previousValue, element) => [
                                                ...previousValue,
                                                Chip(
                                                    label: Text(
                                                        element.displayName ??
                                                            ''))
                                              ])
                                      : [
                                          Chip(
                                              label: Text(
                                                  selectedGroup?.name ?? ''))
                                        ]),
                            ],
                          )
                  ],
                ),
              ));
  }

  resetState() {
    isStep1Complete = false;
    isStep2Complete = false;
    isCreateNewGroupChecked = false;

    selectedGroup = null;
    _messageModel = null;
    _event = null;
    list = [];

    selectedList = [];
    groupName = 'unnamed';
    group = GroupModel(modifiedAt: Timestamp.now(), createdAt: Timestamp.now());
    setState(() {});
  }

  Form buildContainerForGroupDataInput() {
    return Form(
      key: _formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: context.safePercentWidth * 10),
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
              labelText: 'Group/ Chat name',
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
              spacing: 5,
              runSpacing: 5,
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
              labelText: 'Member name/ email',
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
          LimitedBox(
            maxHeight: context.safePercentHeight * 50,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: context.safePercentWidth * 20),
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
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
                            } catch (e) {}
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
            ),
          )
        ],
      ),
    );
  }

  Future createGroup() async {
    if (_firestoreService.firebaseUser == null) {
      return;
    }
    if (selectedList.length == 0) {
      return;
    }
    group.name = groupName;
    group.createdBy = _firestoreService.firebaseUser!.uid;
    group.members = selectedList.fold([_firestoreService.firebaseUser!.uid],
        (previousValue, element) => [...previousValue!, element.uid!]);
    group.type = selectedList.length > 2 ? 1 : 2;
    group.id = newGroupId;

    await _firestoreService.createGroupDoc(group);

    context.showToast(msg: 'new group created');

    return;
  }

  Future scheduleCalenderEventAndMeetForLater(CalendarEventModel event) async {
    String meetLink = HOST_URL +
        'meet?id=${selectedGroup?.id ?? newGroupId}&sub=${event.name.replaceAll(' ', '+')}';
    await FirestoreService.instance.createMessageDoc(
        _messageModel!, selectedGroup?.id ?? newGroupId,
        isNewGroup: selectedGroup == null);
    await FirestoreService.instance.createEventDoc(EventModel(
        eventBegin: event.begin.millisecondsSinceEpoch,
        eventEnd: event.end.millisecondsSinceEpoch,
        eventColorCode: eventColors.indexOf(event.eventColor),
        eventMeetLink: meetLink,
        eventSubject: event.name,
        members: selectedGroup?.members ?? group.members));
    context.showToast(msg: 'event added');
    return;
  }

  Padding buildGroupListToSelect(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.safePercentWidth * 10),
      child: Wrap(
        children: allAvailableGroups.fold(
            [],
            (previousValue, element) => [
                  ...previousValue,
                  SizedBox.fromSize(
                    child: ChatListTile(
                        onTileTap: () {
                          setState(() {
                            selectedGroup = element;
                          });
                        },
                        selectedTileColor:
                            _themeProvider?.themeMode().selectedTileColor,
                        isSelected: selectedGroup?.id == element.id,
                        title: element.name!,
                        subTitle: element.members?.length != null
                            ? element.members!.length.toString() + ' members'
                            : '',
                        avatorUrl: ''),
                  )
                ]),
      ),
    );
  }

  Row buildRowForNewGroupCheckBoxForWeb() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'choose a chat',
          style: Theme.of(context).textTheme.headline5,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'select contact/ create new group',
              softWrap: true,
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(width: 5),
            Checkbox(
                value: isCreateNewGroupChecked,
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selectedGroup = null;
                    }
                    selectedList.clear();
                    isCreateNewGroupChecked = value;
                  });
                }),
          ],
        )
      ],
    );
  }

  Wrap buildRowForNewGroupCheckBoxForMobile() {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'choose a chat',
              style: Theme.of(context).textTheme.headline5,
            )),
        SizedBox(width: 25),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'select contact/ create new group',
                    style: Theme.of(context).textTheme.bodyText1,
                  )),
            ),
            SizedBox(width: 25),
            Checkbox(
                value: isCreateNewGroupChecked,
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selectedGroup = null;
                    }
                    selectedList.clear();
                    isCreateNewGroupChecked = value;
                  });
                }),
          ],
        )
      ],
    );
  }

  void showEventDataOnScreen(CalendarEventModel event) {
    String meetLink = HOST_URL +
        'meet?id=${selectedGroup?.id ?? newGroupId}&sub=${event.name.replaceAll(' ', '+')}';

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
      isStep2Complete = true;
      _event = event;
      _messageModel = messageModel;
    });
  }
}
