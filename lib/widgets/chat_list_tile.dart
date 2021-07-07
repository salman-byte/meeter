import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final String avatorUrl;
  final Widget? trailingWidget;
  final bool isSelected;
  final selectedTileColor;

  final void Function()? onTileTap;
  const ChatListTile(
      {Key? key,
      required this.title,
      required this.subTitle,
      required this.avatorUrl,
      this.trailingWidget,
      this.onTileTap,
      this.isSelected = false,
      this.selectedTileColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selectedTileColor: selectedTileColor,
      selected: isSelected,
      onTap: onTileTap,
      title: Text(title),
      subtitle: Text(subTitle),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(20.0), //or 15.0
        child: Container(
          // height: 70.0,
          // width: 70.0,
          color: Color(0xffFF0E58),
          child: Icon(Icons.person, color: Colors.white, size: 50.0),
        ),
      ),
      trailing: Padding(padding: EdgeInsets.all(8.0), child: trailingWidget),
      // trailing: Align(
      //   alignment: Alignment.topRight,
      //   child: trailingWidget ?? Container(),
      // ),
    );
  }
}
