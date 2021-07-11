import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:meeter/widgets/custom_text_field.dart';
import 'package:velocity_x/velocity_x.dart';

import 'confirmEmail.dart';

class ForgotPassword extends StatefulWidget {
  static String id = '/forgot-password';

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _auth = FirebaseAuth.instance;
  bool isErrorOccured = false;
  String? errorMsg;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailInputController = TextEditingController();

  _passwordReset() async {
    try {
      _formKey.currentState?.save();
      final user =
          await _auth.sendPasswordResetEmail(email: emailInputController.text);

      VxNavigator.of(context).push(Uri.parse(ConfirmEmail.id));
    } on FirebaseException catch (e) {
      setState(() {
        errorMsg = e.message.toString();
        isErrorOccured = true;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isErrorOccured = true;
      });
    }
  }

  @override
  void dispose() {
    emailInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        widthFactor: context.safePercentWidth * 40,
        heightFactor: context.safePercentHeight * 40,
        child: LimitedBox(
          maxWidth: context.safePercentWidth * 40,
          maxHeight: context.safePercentHeight * 40,
          child: Form(
            key: _formKey,
            child: Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10.0),
                    isErrorOccured == true
                        ? Container(
                            padding: EdgeInsets.all(10),
                            margin:
                                const EdgeInsets.only(top: 16.0, left: 16.0),
                            color: Colors.red,
                            child: Text(errorMsg!),
                          )
                        : Container(),
                    Text(
                      'Email Your Email',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    SizedBox(
                      width: context.safePercentWidth * 30,
                      child: CustomTextField(
                        controller: emailInputController,
                        validator: (value) {
                          if (!emailInputController.text.contains('@') ||
                              !emailInputController.text.endsWith('.com')) {
                            return "Email must contain '@' and end with '.com'";
                          }
                          return null;
                        },
                        labelText: 'Email',
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      autoSize: true,
                      text: 'Send Email',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _passwordReset();
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      child: Text('Back to Home screen'),
                      onPressed: () {
                        VxNavigator.of(context).popToRoot();
                        // .push(Uri.parse('/'));
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
