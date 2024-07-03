import 'dart:ui';
import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,24,20),
                  child: Image.asset(
                    'assets/images/ecub_logo.png',
                    width: 100,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Welcome to the ECUB App!',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.transparent),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'We are glad to have you here.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.transparent),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  icon: Icon(Icons.arrow_forward),
                  label: Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow.withOpacity(0.8),
                    foregroundColor: Colors.black // This is the background color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}