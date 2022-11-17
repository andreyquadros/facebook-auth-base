import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:integration_facebook_auth/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen() ,
  ));
}