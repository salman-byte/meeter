import 'package:flutter/material.dart';

class ConfirmEmail extends StatelessWidget {
  static String id = '/confirm-email';
  final String message =
      "An email has just been sent to you, Click the link provided to complete password reset";
  const ConfirmEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        )),
      ),
    );
  }
}
