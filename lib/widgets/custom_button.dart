import 'package:flutter/material.dart';

/// Creates a [RaisedButton]` widget and can be used accross the app to maintain constant design pattern.
///
/// required input is `text` that gets displayed on the button.
///
/// optional parameters are `onPressed`, `buttonColor`, `autoSize` and `textColor`
///
/// if `autoSize` is `null` or `false` then the width of the button is as large as its parent, but if `autoSize` is `true` then its width shrinks to its child.
///
class CustomButton extends StatelessWidget {
  final Color? textColor;
  final Color? buttonColor;
  final void Function()? onPressed;
  final bool? autoSize;
  final String? text;
  const CustomButton(
      {@required this.text,
      this.buttonColor,
      this.onPressed,
      this.textColor,
      Key? key,
      this.autoSize = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: autoSize! ? null : double.infinity,
      height: autoSize! ? null : 30,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        color: buttonColor ?? Colors.cyan[400],
        onPressed: onPressed,
        child: Text(text!,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: textColor ?? Colors.white)),
      ),
    );
  }
}
