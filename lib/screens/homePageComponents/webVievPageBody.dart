import 'package:flutter/material.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:meeter/utils/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../create_meet.dart';
import '../events_page.dart';
import 'chatWithHeader.dart';
import 'tabBarPageView.dart';

enum BodyPage { CHAT, SCHEDULE, CREATE_MEET }

class WebViewPageBodyForAuthenticatedUser extends StatefulWidget {
  const WebViewPageBodyForAuthenticatedUser({
    Key? key,
  }) : super(key: key);

  @override
  _WebViewPageBodyForAuthenticatedUserState createState() =>
      _WebViewPageBodyForAuthenticatedUserState();
}

class _WebViewPageBodyForAuthenticatedUserState
    extends State<WebViewPageBodyForAuthenticatedUser> {
  BodyPage page = BodyPage.CHAT;
  ThemeProvider? themeProvider;

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 500),
          height: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: context.safePercentHeight * 10,
                child: Row(
                  children: [
                    page == BodyPage.SCHEDULE
                        ? Container(
                            width: context.safePercentWidth * 0.5,
                            color: themeProvider!.themeData().accentColor,
                          )
                        : Container(
                            width: context.safePercentWidth * 0.5,
                          ),
                    Container(
                      // width: double.maxFinite,
                      child: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () {
                          if (page != BodyPage.SCHEDULE) {
                            setState(() {
                              page = BodyPage.SCHEDULE;
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: context.safePercentHeight * 10,
                child: Row(children: [
                  page == BodyPage.CHAT
                      ? Container(
                          width: context.safePercentWidth * 0.5,
                          color: themeProvider!.themeData().accentColor,
                        )
                      : Container(
                          width: context.safePercentWidth * 0.5,
                        ),
                  Container(
                    // width: double.maxFinite,
                    child: IconButton(
                      icon: Icon(Icons.chat),
                      onPressed: () {
                        if (page != BodyPage.CHAT) {
                          setState(() {
                            page = BodyPage.CHAT;
                          });
                        }
                      },
                    ),
                  )
                ]),
              ),
              Container(
                height: context.safePercentHeight * 10,
                child: Row(children: [
                  page == BodyPage.CREATE_MEET
                      ? Container(
                          width: context.safePercentWidth * 0.5,
                          color: themeProvider!.themeData().accentColor,
                        )
                      : Container(
                          width: context.safePercentWidth * 0.5,
                        ),
                  Container(
                    // width: double.maxFinite,
                    child: IconButton(
                      icon: Icon(Icons.add_to_queue),
                      onPressed: () {
                        if (page != BodyPage.CREATE_MEET) {
                          setState(() {
                            page = BodyPage.CREATE_MEET;
                          });
                        }
                      },
                    ),
                  )
                ]),
              )
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: buildBodyPageBasedOnTheEnum),
        ),
      ],
    );
  }

  Widget get buildBodyPageBasedOnTheEnum {
    if (page == BodyPage.CHAT)
      return Row(
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
                        ? ChatViewWithHeader(
                            group: appstate.getCurrentSelectedChat!)
                        : Container()),
          ),
        ],
      );
    else if (page == BodyPage.CREATE_MEET)
      return CreateMeet();
    else
      return EventPage();
  }
}
