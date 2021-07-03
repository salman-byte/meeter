import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/models/userModel.dart';

// import 'package:meeter/chat_area.dart';
import 'package:meeter/screens/chat_page.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:meeter/utils/create_group.dart';
import 'package:meeter/widgets/chat_list_tile.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import 'constants/constants.dart';
import 'screens/authUI.dart';
import 'screens/meet_screen.dart';
import 'utils/authStatusNotifier.dart';
import 'utils/theme_notifier.dart';
import 'widgets/custom_text_field.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Vx.setPathUrlStrategy();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isLightTheme = prefs.getBool('isLightTheme') ?? false;

  print(isLightTheme);

  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(isLightTheme: isLightTheme),
    child: AppStart(),
  ));
}

class AppStart extends StatelessWidget {
  const AppStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStatusNotifier()),
        ChangeNotifierProvider(create: (_) => AppStateNotifier()),
      ],
      child: MyApp(
        themeProvider: themeProvider,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final ThemeProvider themeProvider;

  const MyApp({Key? key, required this.themeProvider}) : super(key: key);
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigator = VxNavigator(
    notFoundPage: (uri, params) => MaterialPage(
      key: ValueKey('not-found-page'),
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Page ${uri.path} not found'),
          ),
        ),
      ),
    ),
    routes: {
      '/': (uri, params) =>
          MaterialPage(child: MyHomePage(title: 'Meeter Home Page')),
      '/meet': (uri, params) {
        print('in the /meet block');
        return MaterialPage(
            child: Meeting(
          isAudioMuted: params['am'],
          isAudioOnly: params['ao'],
          isVideoMuted: params['vm'],
          subject: params['sub'],
        ));
      }
    },
  );
  @override
  void initState() {
    AuthStatusNotifier();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: widget.themeProvider.themeData(),
      title: 'Meeter',
      routerDelegate: navigator,
      routeInformationParser: VxInformationParser(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ThemeProvider? themeProvider;
  @override
  void initState() {
    // TODO: implement initState
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    // FirestoreService().getGroupData();
    // FirestoreService().getGroupsListAsStream();
    // FirestoreService().createGroupDoc(GroupModel(
    //     createdAt: Timestamp.fromDate(DateTime.now()),
    //     id: "abcdefghijklllllllllll",
    //     modifiedAt: Timestamp.fromDate(DateTime.now()),
    //     name: "Random topic",
    //     createdBy: 'dasfsfdssdsdfsd'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: buildAppBar(),
      body: VxDevice(
        mobile: MobileViewPageBody(),
        // mobile: WebViewPageBody(),
        web: WebViewPageBody(),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(widget.title!),
      actions: [
        Switch.adaptive(
          value: themeProvider!.isLightTheme ? false : true,
          onChanged: (value) {
            themeProvider!.toggleThemeData(value);
          },
        ),
        SizedBox(width: 10),
        Consumer<AuthStatusNotifier>(builder: (context, authData, child) {
          return !(authData.isUserAuthenticated)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), //or 15.0
                  child: Container(
                    // height: 70.0,
                    // width: 70.0,
                    color: Color(0xffFF0E58),
                    child: Icon(Icons.person, color: Colors.white, size: 50.0),
                  ),
                )
              : PopupMenuButton(
                  onSelected: (value) {
                    switch (value) {
                      case 2:
                        FirebaseAuth.instance.signOut();
                        break;
                      default:
                        buildShowAnimatedSignUpDialog(context);
                    }
                  },
                  initialValue: null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0), //or 15.0
                    child: Container(
                      // height: 70.0,
                      // width: 70.0,
                      color: Color(0xffFF0E58),
                      child:
                          Icon(Icons.person, color: Colors.white, size: 50.0),
                    ),
                  ),
                  itemBuilder: (context) {
                    return <PopupMenuItem>[
                      PopupMenuItem(
                        value: 0,
                        child: Text('settings'),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text('invite'),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Text('logout'),
                      )
                    ];
                  },
                );
        }),
      ],
    );
  }

  Future buildShowAnimatedSignUpDialog(BuildContext context) {
    return showAnimatedDialog(
      duration: Duration(seconds: 1),
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
            child: SignInSignUpFlow(
          inDialogMode: true,
        ));
      },
      animationType: DialogTransitionType.slideFromBottom,
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }
}

class MobileViewPageBody extends StatelessWidget {
  const MobileViewPageBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStatusNotifier>(builder: (context, authData, child) {
      return !(authData.isUserAuthenticated)
          ? SignInSignUpFlow(
              inDialogMode: false,
            )
          : Container(
              width: context.percentWidth * 30,
              child: ChatGroupList(),
            );
    });
  }
}

class WebViewPageBody extends StatelessWidget {
  const WebViewPageBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStatusNotifier>(builder: (context, authData, child) {
      return (authData.isUserAuthenticated)
          ? Row(
              children: [
                Container(
                  width: context.percentWidth * 30,
                  child: TabBarPageView(),
                ),
                VerticalDivider(),
                Expanded(
                  child: Consumer<AppStateNotifier>(
                      builder: (context, appstate, child) =>
                          appstate.getCurrentSelectedChat != null
                              ? ChatPage()
                              : Container()),
                ),
              ],
            )
          : SignInSignUpFlow(
              inDialogMode: false,
            );
    });
  }
}

class TabBarPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            new Container(
              child: IconButton(
                icon: Icon(Icons.group_add),
                onPressed: () {
                  showCreateGroupDialog(context);
                },
              ),
            ),
          ],
          bottom: new PreferredSize(
            preferredSize: Size(double.infinity, kToolbarHeight),
            child: Column(
              children: [
                Container(
                  child: new TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.chat)),
                      Tab(icon: Icon(Icons.people)),
                      Tab(icon: Icon(Icons.more)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            ChatGroupList(),
            AllUsersList(),
            Icon(Icons.more),
          ],
        ),
      ),
    );
  }

  Future showCreateGroupDialog(BuildContext context) {
    return showAnimatedDialog(
      duration: Duration(seconds: 1),
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(child: PersonNameInputWidget());
      },
      animationType: DialogTransitionType.slideFromBottom,
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }
}

class ChatGroupList extends StatelessWidget {
  const ChatGroupList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirestoreService.instance.getGroupsListAsStream(),
        builder: (context, AsyncSnapshot<List<GroupModel>> snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return Consumer<AppStateNotifier>(
            builder: (context, appState, child) {
              String? currentSelectedChatId =
                  appState.getCurrentSelectedChat?.id ?? '';
              return ListView.builder(
                  itemCount: snapshot.data != null ? snapshot.data!.length : 0,
                  itemBuilder: (context, index) {
                    print(currentSelectedChatId);
                    // return Container();
                    return ChatListTile(
                        isSelected:
                            snapshot.data![index].id == currentSelectedChatId,
                        onTileTap: () {
                          appState.setCurrentSelectedChat =
                              snapshot.data![index];
                        },
                        title: snapshot.data![index].name!,
                        subTitle: '',
                        avatorUrl: '',
                        trailingText: '');
                  });
            },
          );
        },
      ),
    );
  }
}

class AllUsersList extends StatelessWidget {
  const AllUsersList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirestoreService.instance.usersListAsStream(),
        builder: (context, AsyncSnapshot<List<UserData>> snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return ListView.builder(
              itemCount: snapshot.data != null ? snapshot.data!.length : 0,
              itemBuilder: (context, index) {
                // return Container();
                return ChatListTile(
                    title: snapshot.data![index].displayName!,
                    subTitle: '',
                    avatorUrl: '',
                    trailingText: '');
              });
        },
      ),
    );
  }
}
