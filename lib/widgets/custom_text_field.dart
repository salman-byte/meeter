import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Creates a [TextFormField] widget and can be used accross the app to maintain constant design pattern.
///
/// has no required parameters.
///
/// optional parameters are:
///
/// `controller` - can be null but inorder to controll input the [TextEditingController] can be passed.
///
/// `prefixText` - the text shows up when user starts typing,
///
///  `hintText` - shown inside of blank input field and as the user starts typing it disappears ,
///
///  `labelText` - shown inside of blank input field and as the user starts typing it goes on the top of text field,
///
///  `initialValue` - the text which should be auto filled for user, if text editing controller is passed then this should be null,
///
///  `multiLines` - if you want to make field expand when user input large text make it true,
///
///  `maxLines` - to limit the maximum lines for input when `multiLines` is true,
///
///  `maxLength`  - takes integer value and limits the input up to that character.
///
/// the width of the text field is as large as its parent.
///
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? prefixText;
  final String? hintText;
  final String? labelText;
  final String? initialValue;
  final bool? multiLines;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? inputType;

  final bool? obscureText;
  const CustomTextField(
      {Key? key,
      this.multiLines = false,
      this.maxLength,
      this.prefixText,
      this.hintText,
      this.inputType,
      this.onSaved,
      this.validator,
      this.initialValue,
      this.onChanged,
      this.maxLines,
      this.obscureText = false,
      this.controller,
      this.labelText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Color(0x00000000), blurRadius: 11)]),
      child: TextFormField(
        textInputAction: TextInputAction.next,
        controller: controller,
        inputFormatters: (maxLength == null)
            ? null
            : [
                LengthLimitingTextInputFormatter(maxLength),
              ],
        initialValue: initialValue ?? null,
        onSaved: onSaved,
        onChanged: onChanged,
        validator: validator,
        obscureText: obscureText!,
        // selectionHeightStyle: BoxHeightStyle.max,
        showCursor: true,
        style: TextStyle(height: 1.5),
        maxLength: null,
        keyboardType: inputType ?? null,
        maxLines: (multiLines!)
            ? (maxLines != null)
                ? maxLines
                : null
            : 1,
        decoration: InputDecoration(
          labelText: labelText ?? null,
          border: OutlineInputBorder(),
          hintText: hintText ?? null,
          prefix: (prefixText != null) ? Text(prefixText!) : null,
          // fillColor: Color.fromRGBO(255, 255, 255, 1),
          filled: true,
          contentPadding: EdgeInsets.fromLTRB(16.0, 14.0, 15.0, 13.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(),
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
