import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'allUsersList.dart';
import 'chatGroupList.dart';

class TabBarPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, context.safePercentHeight * 10),
          child: Column(
            children: [
              Container(
                child: new TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.chat),
                      text: 'chats',
                      iconMargin: EdgeInsets.only(bottom: 5),
                    ),
                    Tab(
                      icon: Icon(Icons.person),
                      text: 'available',
                      iconMargin: EdgeInsets.only(bottom: 5),
                    ),
                    // Tab(icon: Icon(Icons.more)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatGroupList(),
            AllUsersList(),
            // Icon(Icons.more),
          ],
        ),
      ),
    );
  }
}
