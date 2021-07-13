import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'allUsersList.dart';
import 'chatGroupList.dart';

class TabBarPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: VxDevice(
        mobile: Scaffold(
          appBar: PreferredSize(
            preferredSize:
                Size(double.infinity, context.safePercentHeight * 10),
            child: buildTabsOnTop(),
          ),
          body: buildTabBarViewBody(),
        ),
        web: Scaffold(
          appBar: PreferredSize(
            preferredSize:
                Size(double.infinity, context.safePercentHeight * 10),
            child: buildTabsOnTop(),
          ),
          body: buildTabBarViewBody(),
        ),
      ),
    );
  }

  TabBarView buildTabBarViewBody() {
    return TabBarView(
      children: [
        ChatGroupList(),
        AllUsersList(),
        // Icon(Icons.more),
      ],
    );
  }

  TabBar buildTabsOnTop() {
    return TabBar(
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
    );
  }
}
