import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela inicial Logado'),
        actions: [GestureDetector(onTap: (){
          Get.offAll(() => LoginScreen());
        },
      child: Icon(Icons.logout))],
      ),
    );
  }
}
