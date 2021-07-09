import 'package:flutter/material.dart';
import 'package:meeter/models/userModel.dart';
import 'package:meeter/services/firestoreService.dart';
import 'package:meeter/widgets/chat_list_tile.dart';

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
                );
              });
        },
      ),
    );
  }
}
