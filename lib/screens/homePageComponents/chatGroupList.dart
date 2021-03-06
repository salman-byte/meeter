import 'package:flutter/material.dart';
import 'package:meeter/models/groupModel.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:meeter/utils/theme_notifier.dart';
import 'package:meeter/widgets/chat_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

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
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Consumer<AppStateNotifier>(
            builder: (context, appState, child) {
              String? currentSelectedChatId =
                  appState.getCurrentSelectedChat?.id ?? '';
              return Consumer<ThemeProvider>(
                builder: (context, theme, child) => ListView.builder(
                    itemCount:
                        snapshot.data != null ? snapshot.data!.length : 0,
                    itemBuilder: (context, index) {
                      final recentMessage =
                          snapshot.data?[index].recentMessage?.messageText ??
                              '';
                      // return Container();
                      return ChatListTile(
                          selectedTileColor:
                              theme.themeMode().selectedTileColor,
                          isSelected:
                              snapshot.data![index].id == currentSelectedChatId,
                          onTileTap: () {
                            if (appState.getCurrentSelectedChat?.id !=
                                snapshot.data![index].id) {
                              appState.setCurrentSelectedChat =
                                  snapshot.data![index];
                              if (!(snapshot.data![index].recentMessage!.readBy!
                                  .contains(FirestoreService
                                      .instance.firebaseUser?.uid))) {
                                FirestoreService.instance
                                    .markLastMessageAsReadInGroupDoc(
                                        groupId: snapshot.data![index].id!);
                              }
                            }
                            if (context.isMobile) {
                              VxNavigator.of(context).push(
                                  Uri.parse('/chat-view'),
                                  params: {'group': snapshot.data![index]});
                            }
                          },
                          title: snapshot.data![index].name!,
                          subTitle: recentMessage,
                          avatorUrl: '',
                          trailingWidget: buildTrailingWidget(
                              snapshot, index, currentSelectedChatId));
                    }),
              );
            },
          );
        },
      ),
    );
  }

  SizedBox buildTrailingWidget(AsyncSnapshot<List<GroupModel>> snapshot,
      int index, String currentSelectedChatId) {
    if ((snapshot.data![index].id != currentSelectedChatId) &&
        snapshot.data?[index].recentMessage?.messageText == null) {
      return SizedBox.shrink(
        child: Icon(
          Icons.fiber_new,
          color: Colors.green,
        ),
      );
    } else if (snapshot.data![index].id != currentSelectedChatId &&
            snapshot.data?[index].recentMessage?.readBy != null
        ? (!(snapshot.data![index].recentMessage!.readBy!
            .contains(FirestoreService.instance.firebaseUser?.uid)))
        : false) {
      return SizedBox.shrink(
        child: Icon(
          Icons.brightness_1_sharp,
          size: 10,
          color: Colors.green,
        ),
      );
    } else
      return SizedBox.shrink();
  }
}
