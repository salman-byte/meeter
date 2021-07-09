import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AttachmentBox extends StatelessWidget {
  const AttachmentBox({
    Key? key,
    required this.attachmentBoxOpen,
    required this.handleImageSelection,
    required this.handleFileSelection,
  }) : super(key: key);

  final ValueNotifier<bool> attachmentBoxOpen;
  final handleImageSelection;
  final handleFileSelection;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      builder: (BuildContext context, bool attachmentBoxOpen, Widget? child) {
        return AnimatedContainer(
          height: attachmentBoxOpen ? context.safePercentHeight * 15 : 0,
          duration: Duration(milliseconds: 500),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: !attachmentBoxOpen
                ? Container()
                : Wrap(
                    runSpacing: 5,
                    spacing: 5,
                    alignment: WrapAlignment.start,
                    children: [
                        iconCreation(
                          text: 'Photo',
                          icons: Icons.image_outlined,
                          onTap: () {
                            handleImageSelection();
                          },
                        ),
                        iconCreation(
                            onTap: () {
                              handleFileSelection();
                            },
                            text: 'File',
                            icons: Icons.attach_file),
                      ]),
          ),
        );
      },
      valueListenable: attachmentBoxOpen,
    );
  }

  Widget iconCreation(
      {required IconData icons, required String text, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            // backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
          )
        ],
      ),
    );
  }
}
