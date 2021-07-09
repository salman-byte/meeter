import 'package:flutter/material.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class MeetSettings extends StatefulWidget {
  final String groupId;
  const MeetSettings({Key? key, required this.groupId}) : super(key: key);

  @override
  _MeetSettingsState createState() => _MeetSettingsState();
}

class _MeetSettingsState extends State<MeetSettings> {
  final subjectText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          Container(
            width: context.safePercentWidth * 40,
            child: TextField(
              controller: subjectText,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Subject",
              ),
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          CustomButton(
            autoSize: true,
            onPressed: subjectText.text == ''
                ? null
                : () {
                    Navigator.of(context)
                        .pop({'id': widget.groupId, 'sub': subjectText.text});
                  },
            text: "Join Meeting",
          ),
        ],
      ),
    );
  }
}
