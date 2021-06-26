import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// import 'package:meeter/chat_area.dart';
import 'package:meeter/screens/chat_page.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/widgets/chat_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import 'authUI.dart';
import 'meet_screen.dart';
import 'utils/authStatusNotifier.dart';
import 'utils/theme_notifier.dart';

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
      providers: [ChangeNotifierProvider(create: (_) => AuthStatusNotifier())],
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
    // FirestoreService().getCurrentUserDocData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: buildAppBar(),
      body: VxDevice(
        mobile: buildMainScreenForMobile(context),
        web: buildMainScreenForWeb(context),
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
          return PopupMenuButton(
            onSelected: (value) {
              showAnimatedDialog(
                duration: Duration(seconds: 1),
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return Dialog(child: SignInSignUpFlow());
                },
                animationType: DialogTransitionType.slideFromBottom,
                curve: Curves.fastLinearToSlowEaseIn,
              );
            },
            initialValue: null,
            child: authData.isUserAuthenticated
                ? CircleAvatar(
                    radius: 30.0,
                    backgroundImage:
                        NetworkImage(authData.currentUser!.photoUrl!),
                    backgroundColor: Colors.transparent,
                  )
                : ClipRRect(
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
              return List.generate(5, (index) {
                return PopupMenuItem(
                  value: index,
                  child: Text('button no $index'),
                );
              });
            },
          );
        }),
      ],
    );
  }

  Center buildMainScreenForMobile(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'This app is under construction 🚧',
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            'visit sometime later',
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    );
  }

  Row buildMainScreenForWeb(BuildContext context) {
    // showDialog(
    //     context: context, builder: (context) => Dialog(child: LoginScreen()));
    return Row(
      children: [
        Container(
          width: context.percentWidth * 30,
          child: ChatGroupList(),
        ),
        VerticalDivider(),
        Expanded(
          child: ChatPage(),
        ),
      ],
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
      body: StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: const [],
        builder: (context, snapshot) {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ChatListTile(
                    title: snapshot.data![index].firstName!,
                    subTitle: '',
                    avatorUrl: snapshot.data![index].imageUrl!,
                    trailingText: '');
              });
        },
      ),
    );
    // return ListView(
    //   children: ListTile.divideTiles(
    //     context: context,
    //     tiles: [
    //       ChatListTile(
    //           title: 'title',
    //           subTitle: 'subTitle',
    //           avatorUrl: 'avatorUrl',
    //           trailingText: 'trailingText'),
    //       ChatListTile(
    //           title: 'title',
    //           subTitle: 'subTitle',
    //           avatorUrl: 'avatorUrl',
    //           trailingText: 'trailingText'),
    //     ],
    //   ).toList(),
    // );
  }
}
