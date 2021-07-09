import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:meeter/utils/authStatusNotifier.dart';
import 'package:meeter/utils/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import 'authUI.dart';
import 'homePageComponents/chatGroupList.dart';
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
                      // PopupMenuItem(
                      //   value: 0,
                      //   child: Text('settings'),
                      // ),
                      // PopupMenuItem(
                      //   value: 1,
                      //   child: Text('invite'),
                      // ),
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
