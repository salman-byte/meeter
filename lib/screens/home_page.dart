import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:meeter/utils/authStatusNotifier.dart';
import 'package:meeter/utils/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import 'authUI.dart';
import 'homePageComponents/chatGroupList.dart';
import 'homePageComponents/tabBarPageView.dart';
import 'homePageComponents/webVievPageBody.dart';

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
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);

    return VxDevice(
      mobile: Consumer<AuthStatusNotifier>(builder: (context, authData, child) {
        return !(authData.isUserAuthenticated)
            ? Scaffold(
                appBar: buildAppBar(),
                body: MobileViewPageBody(),
              )
            : Scaffold(
                drawer: buildDrawerForNavigationInMobileView(),
                appBar: buildAppBar(),
                body: MobileViewPageBody());
      }),
      web: Scaffold(appBar: buildAppBar(), body: WebViewPageBody()),
    );
  }

  Drawer buildDrawerForNavigationInMobileView() {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
              ),
              child: Center(child: Text('Drawer Header')),
            ),
            ListTile(
              title: Text('start chat/ schedule meet'),
              leading: Icon(Icons.add_to_queue),
              onTap: () {
                // Update the state of the app
                VxNavigator.of(context).push(Uri.parse('/create-meet'));
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('check events'),
              leading: Icon(Icons.calendar_today),
              onTap: () {
                // Update the state of the app
                VxNavigator.of(context).push(Uri.parse('/schedule'));
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(widget.title!),
      actions: [
        IconButton(
            icon: themeProvider!.isLightTheme
                ? Icon(Icons.nightlight_round)
                : Icon(Icons.lightbulb_outline_rounded),
            onPressed: () {
              themeProvider!.toggleThemeData();
            }),
        // Switch.adaptive(
        //   value: themeProvider!.isLightTheme ? false : true,
        //   // onChanged: (value) {
        //   //   themeProvider!.toggleThemeData(value);
        //   // },
        // ),
        SizedBox(width: 20),
        Consumer<AuthStatusNotifier>(builder: (context, authData, child) {
          return !(authData.isUserAuthenticated)
              ? Container()
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
                      child: Icon(Icons.exit_to_app),
                    ),
                  ),
                  itemBuilder: (context) {
                    return <PopupMenuItem>[
                      PopupMenuItem(
                        value: 2,
                        child: Text('logout'),
                      )
                    ];
                  },
                );
        }),
        SizedBox(width: 20),
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
          : TabBarPageView();
    });
  }
}

class WebViewPageBody extends StatelessWidget {
  WebViewPageBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStatusNotifier>(builder: (context, authData, child) {
      return (authData.isUserAuthenticated)
          ? WebViewPageBodyForAuthenticatedUser()
          : SignInSignUpFlow(
              inDialogMode: false,
            );
    });
  }
}
