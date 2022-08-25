import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/Getx/app_initial_binding.dart';
import 'package:flutter_instagram_clone/firebase_options.dart';
import 'package:flutter_instagram_clone/screens/Auth/authscreen.dart';
import 'package:flutter_instagram_clone/app_navigations/main_navigation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetXBinding().dependencies();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
  FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
  FirebaseStorage.instance.useStorageEmulator("localhost", 9199);

  // await FirebaseAppCheck.instance.activate(webRecaptchaSiteKey: 'recaptcha-v3-site-key');
  await GetStorage.init();

  Intl.systemLocale = await findSystemLocale();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final appUserController = Get.find<AppUserController>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => Obx(() {
              return appUserController.isAuthenticated.isTrue ? MainNavigation() : const AuthScreen();
            }),
        "/login": (context) => const AuthScreen(),
      },
    );
  }
}
