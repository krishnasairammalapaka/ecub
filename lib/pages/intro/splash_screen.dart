import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:ecub_s1_v2/pages/intro/intro.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splashscreen.gif',
          width: 1500,
          height: 1500,
        ),
      ),
    );
  }
}
