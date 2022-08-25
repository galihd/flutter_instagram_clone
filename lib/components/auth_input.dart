import 'package:flutter/material.dart';

class AuthTextInput extends StatelessWidget {
  AuthTextInput({Key? key, required this.textController, required this.textHint, required this.isPassword, this.validator})
      : super(key: key);

  final TextEditingController textController;
  final String textHint;
  final bool isPassword;
  String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          obscureText: isPassword,
          decoration: InputDecoration(border: const OutlineInputBorder(), hintText: textHint),
          controller: textController,
          validator: validator,
        ));
  }
}
