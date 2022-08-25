import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_clone/screens/Auth/loginscreen.dart';
import 'package:flutter_instagram_clone/screens/Auth/registerscreen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLoginForm = true;

  void switchForm() {
    setState(() {
      showLoginForm = !showLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoginForm
        ? LoginScreen(
            switchForm: switchForm,
          )
        : RegisterScreen(
            switchForm: switchForm,
          );
  }
}
