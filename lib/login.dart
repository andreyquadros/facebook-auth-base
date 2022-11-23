import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:integration_facebook_auth/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController _login = TextEditingController();
  TextEditingController _senha = TextEditingController();

  var loading = false;

  Future<void> registrarUsuarioEmailSenha() async {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _login.text, password: _senha.text);

    credential.user!.sendEmailVerification();

    await FirebaseFirestore.instance.collection('users').add({
      'email': _login.text,
      'senha': _senha.text,
    });

    Get.snackbar('Cadastro', 'Registro Salvo com Sucesso no Firebase').show();
  }
  Future<void> logarUsuarioEmailSenha() async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _login.text, password: _senha.text);
    if(credential.user != null ) {

      print(credential.user);
      print('logado');
      Get.off(()=> const HomeScreen());
    }
  }

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
        Get.off(()=> const HomeScreen());
    }on FirebaseAuthException catch(e){
      print('O erro em questão foi o: ${e}');
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

  void logarGoogle() async {

    setState((){
      loading = true;
    });

    try{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final googleUserData = await FirebaseAuth.instance.signInWithCredential(credential);
      print('Os dados do Google são: ${googleUserData}');

      await FirebaseFirestore.instance.collection('users').add({
        'email': googleUser?.email,
        'name' : googleUser?.displayName,
      });

      Get.off(()=> const HomeScreen());

    }on FirebaseAuthException catch(e){
      var title = '';
      print('O erro em questão foi o: ${e}');
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


    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela de Login'),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: _login,
            cursorColor: Colors.blue,
            decoration: const InputDecoration(
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
            decoration: const InputDecoration(
              fillColor: Colors.blue,
              focusColor: Colors.blue,
              hoverColor: Colors.blue,
              border: OutlineInputBorder(),
              hintText: 'Senha',
            ),
          ),

          ElevatedButton(
              onPressed: registrarUsuarioEmailSenha,
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
              child: loading
                  ? Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("Registrando..."),
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        backgroundColor: Colors.blue,
                        strokeWidth: 3,
                      ),
                    )
                  ],
                ),
              )
                  : SizedBox(
                  height: 40,
                    width: 220,
                    child: Row(
                      children: const [
                        Icon(Icons.email),
                        Text("Registrar com Email e Senha"),
                      ],
                    ),
                  )),
          ElevatedButton(
              onPressed: logarUsuarioEmailSenha,
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
              child: loading
                  ? Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("Logando..."),
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        backgroundColor: Colors.blue,
                        strokeWidth: 3,
                      ),
                    )
                  ],
                ),
              )
                  : SizedBox(
                  height: 40,
                    width: 200,
                    child: Row(
                      children: const [
                        Icon(Icons.email),
                        Text("Logar com Email e Senha"),
                      ],
                    ),
                  )),

          ElevatedButton.icon(onPressed: logarFacebook, icon: const Icon(Icons.facebook), label: const Text('Logar com o Facebook')),
          ElevatedButton.icon(onPressed: logarGoogle, icon: const Icon(Icons.g_mobiledata), label: const Text('Logar com o Google')),
        ],
      ),
    );
  }
}
