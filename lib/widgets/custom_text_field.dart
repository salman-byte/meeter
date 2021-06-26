import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? prefixText;
  final String? hintText;
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
      this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Color(0x00000000), blurRadius: 11)]),
      child: TextFormField(
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
