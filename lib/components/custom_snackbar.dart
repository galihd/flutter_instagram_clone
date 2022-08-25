import 'package:flutter/material.dart';

class MySnackbar {
  static show(BuildContext context, String message, bool floating) {
    return floating
        ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            width: 300,
            content: SizedBox(
              width: 200,
              child: Center(
                  heightFactor: 0.5,
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 13),
                  )),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))))
        : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 2),
            content: Center(
                child: Text(
              message,
              style: const TextStyle(fontSize: 13),
            ))));
  }
}
