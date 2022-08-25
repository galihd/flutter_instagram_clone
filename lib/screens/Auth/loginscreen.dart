import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/appuser_repo.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/components/auth_input.dart';
import 'package:flutter_instagram_clone/components/custom_loading_indicator.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key, required this.switchForm}) : super(key: key);
  final VoidCallback switchForm;
  final formKey = GlobalKey<FormState>();
  final userNameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final userController = Get.find<AppUserController>();

  void loginHandler(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      CustomIndicator.show(context, "Signing in...");
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userNameTextController.text, password: passwordTextController.text)
          .then((result) async {
        AppUser signedUser = await AppUsersRepo.findFirstAppUserByAttribute("email", result.user!.email!);
        userController.isAuthenticated.isFalse
            ? userController.userLogin(signedUser).then((a) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacementNamed("/");
              })
            : userController.switchUser(signedUser).then((a) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacementNamed("/");
              });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.asset('assets/images/Instagram_header.png', width: 200, height: 150)),
              FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Form(
                      key: formKey,
                      child: Column(children: [
                        AuthTextInput(
                          textController: userNameTextController,
                          textHint: 'Username,Email or Phone number',
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
                              child: ElevatedButton(onPressed: (() => loginHandler(context)), child: const Text("Log in")),
                            )),
                      ]))),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Forgotten your login details?", style: TextStyle(fontSize: 13)),
                  TextButton(
                      onPressed: () {
                        Get.snackbar("Help", "HEEEEELLLLP");
                      },
                      child: const Text("Get help with loggin in.", style: TextStyle(fontSize: 13)))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Divider(
                    color: Colors.grey.shade600,
                  )),
                  const Text('OR'),
                  Expanded(
                      child: Divider(
                    color: Colors.grey.shade600,
                  ))
                ],
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(width: 1, color: Colors.grey.shade600))),
        child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 0.075,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account?', style: TextStyle(fontSize: 13)),
                TextButton(
                    onPressed: () {
                      userNameTextController.clear();
                      passwordTextController.clear();
                      switchForm();
                    },
                    child: const Text("Sign up.", style: TextStyle(fontSize: 13)))
              ],
            )),
      ),
    ));
  }
}
