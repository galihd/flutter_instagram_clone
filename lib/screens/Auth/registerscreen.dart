import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/components/auth_input.dart';
import 'package:flutter_instagram_clone/components/custom_loading_indicator.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatelessWidget {
  final VoidCallback switchForm;
  final formKey = GlobalKey<FormState>();
  final userNameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final userController = Get.find<AppUserController>();
  RegisterScreen({Key? key, required this.switchForm}) : super(key: key);

  void registerHandler(BuildContext context) {
    if (formKey.currentState!.validate()) {
      CustomIndicator.show(context, "Registering...");

      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: userNameTextController.text, password: passwordTextController.text)
          .then((value) => userController.registerUser(userNameTextController.text, userNameTextController.text).then((e) {
                Navigator.of(context).pop();
                switchForm();
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child:
              Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            FractionallySizedBox(
                widthFactor: 0.9,
                child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AuthTextInput(
                          textController: userNameTextController,
                          textHint: 'Email',
                          isPassword: false,
                          validator: (val) => (val == null || EmailValidator.validate(val)) ? null : "Email invalid",
                        ),
                        AuthTextInput(
                          textController: passwordTextController,
                          textHint: 'Password',
                          isPassword: true,
                          validator: (val) => (val == null || val.length < 8) ? "Password minimum 8 characters" : null,
                        ),
                        Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: FractionallySizedBox(
                              widthFactor: 1,
                              child:
                                  ElevatedButton(onPressed: (() => registerHandler(context)), child: const Text("Register")),
                            ))
                      ],
                    )))
          ]),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1, color: Colors.grey.shade600))),
          child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 0.075,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?', style: TextStyle(fontSize: 13)),
                  TextButton(
                      onPressed: () {
                        userNameTextController.clear();
                        passwordTextController.clear();
                        switchForm();
                      },
                      child: const Text("Sign in.", style: TextStyle(fontSize: 13)))
                ],
              )),
        ),
      ),
    );
  }
}
