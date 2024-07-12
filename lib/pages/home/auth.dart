import 'package:ecub_s1_v2/pages/home/home.dart';
import 'package:ecub_s1_v2/pages/intro/intro.dart';
import 'package:ecub_s1_v2/pages/intro/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//handles state of login
//if login home else intro

class AuthPage extends StatelessWidget{
  const AuthPage({super.key});

  @override
  Widget build(BuildContext content){
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.active){
          User? user = snapshot.data;
          if(user == null){
            return SplashScreen();
          }else{
            return HomePage();
          }
        }else{
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}