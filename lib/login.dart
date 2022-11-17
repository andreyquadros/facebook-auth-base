import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:integration_facebook_auth/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  var loading = false;

  void logarFacebook() async {
    setState((){
      loading = true;
    });

    try{
      final facebookLoginResult = await FacebookAuth.instance.login();
      final userData = await FacebookAuth.instance.getUserData();
      final facebookAuthCredential = FacebookAuthProvider.credential(facebookLoginResult.accessToken!.token);
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      await FirebaseFirestore.instance.collection('users').add({
        'email': userData['email'],
        'imageUrl': userData['picture']['data']['url'],
        'name' : userData['name'],
      });
        Get.to(()=> HomeScreen());
    }on FirebaseAuthException catch(e){
      var title = '';
      switch (e.code){
        case 'account-exists-with-different-credential':
          title = 'Esta conta existe com uma credencial diferente';
          break;
      }

    }finally{
      setState(){
        loading = false;
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _login = TextEditingController();
    TextEditingController _senha = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Login'),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: _login,
            cursorColor: Colors.blue,
            decoration: InputDecoration(
              fillColor: Colors.blue,
              focusColor: Colors.blue,
              hoverColor: Colors.blue,
              border: OutlineInputBorder(),
              hintText: 'Login',
            ),
          ),
        TextFormField(
            controller: _senha,
            cursorColor: Colors.blue,
            decoration: InputDecoration(
              fillColor: Colors.blue,
              focusColor: Colors.blue,
              hoverColor: Colors.blue,
              border: OutlineInputBorder(),
              hintText: 'Senha',
            ),
          ),
          ElevatedButton.icon(onPressed: logarFacebook, icon: Icon(Icons.facebook), label: Text('Logar com o Facebook'))
        ],
      ),
    );
  }
}
