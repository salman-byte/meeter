import 'package:flutter/material.dart';
import 'package:meeter/widgets/custom_button.dart';
import 'package:meeter/widgets/custom_text_field.dart';

class SignupForm extends StatelessWidget {
  final TextEditingController nameInputController;
  final TextEditingController usernameInputController;
  final TextEditingController passwordInputController;
  final TextEditingController confirmPasswordInputController;
  final Function() onSignUpPressed;
  SignupForm({
    Key? key,
    required this.onSignUpPressed,
    required this.usernameInputController,
    required this.passwordInputController,
    required this.confirmPasswordInputController,
    required this.nameInputController,
  }) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    String? password;
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
              controller: nameInputController,
              labelText: "Full Name",
              onChanged: (value) {
                password = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'name is empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0),
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
              onChanged: (value) {
                password = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Password is empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0),
            CustomTextField(
              controller: confirmPasswordInputController,
              obscureText: true,
              labelText: "Confirm password",
              validator: (value) {
                return value != password ? 'Password mismatch' : null;
              },
            ),
            const SizedBox(height: 10.0),
            CustomButton(
              text: 'Signup',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  onSignUpPressed();
                }
              },
              buttonColor: Colors.red,
              textColor: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
