import 'package:flutter/material.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:meeter/widgets/custom_text_field.dart';
import 'package:velocity_x/velocity_x.dart';

import 'forgotPassword.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameInputController;
  final TextEditingController passwordInputController;
  final Function() onLoginPressed;
  final _formKey = GlobalKey<FormState>();

  LoginForm({
    Key? key,
    required this.onLoginPressed,
    required this.usernameInputController,
    required this.passwordInputController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            CustomTextField(
              controller: usernameInputController,
              labelText: "Enter email",
              validator: (value) {
                if (!value!.contains('@') || !value.endsWith('.com')) {
                  return "Email must contain '@' and end with '.com'";
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0),
            CustomTextField(
              controller: passwordInputController,
              obscureText: true,
              labelText: "Enter password",
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Password is empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0),
            CustomButton(
              text: 'Login',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  onLoginPressed();
                }
              },
              buttonColor: Colors.red,
              textColor: Colors.white,
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                VxNavigator.of(context).push(Uri.parse(ForgotPassword.id));
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
