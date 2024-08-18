import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/pages/sign_pages/google_sign_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import '../sign_pages/registration_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Initialize Firebase
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  void getUserdata() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();
      try {
        var box = await Hive.openBox('user_data');
        if (userData['firstname'] != null) {
          await box.clear();
          await box.put('email', userData['email']);
          await box.put('phonenumber', userData['phonenumber']);
          await box.put('age', userData['age']);
          await box.put('firstname', userData['firstname']);
          await box.put('lastname', userData['lastname']);
        }
      } catch (e) {
        print("Error storing data in Hive: $e");
      }
    }
  }

  // Login function
  Future<void> _loginWithEmailPassword(BuildContext context) async {
    try {
      final user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      ))
          .user;
      if (user != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        getUserdata();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to sign in with Email & Password"),
        ),
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _validateEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              backgroundColor: Colors.white,
              // appBar: AppBar(
              //   leading: IconButton(
              //     icon: Icon(Icons.arrow_back, color: Colors.black),
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //   ),
              //   backgroundColor: Colors.transparent,
              //   elevation: 0,
              // ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Login to ECUB',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            shadowColor: Colors.grey.withOpacity(0.5),
                            elevation: 5,
                          ),
                          // icon: FaIcon(FontAwesomeIcons.google,
                          //     color: Colors.red, size: 24.0),
                          label: Text(
                            'Continue with Google',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () async {
                            User? user = await AuthService().signInWithGoogle();
                            if (user != null) {
                              // Navigate to the desired screen
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              // Handle sign-in failure (optional)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Google sign-in failed')),
                              );
                            }
                            // print(user);
                            getUserdata();
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            shadowColor: Colors.grey.withOpacity(0.5),
                            elevation: 5,
                          ),
                          // icon: FaIcon(FontAwesomeIcons.apple,
                          //     color: Colors.blue, size: 24.0),
                          label: Text(
                            ' Continue with Apple ',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {},
                        ),
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'hi@example.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            shadowColor: Colors.blue.withOpacity(0.5),
                            elevation: 5,
                          ),
                          onPressed: () {
                            if (!_validateEmail(emailController.text)) {
                              _showErrorDialog(context,
                                  'Please enter a valid email address.');
                              return;
                            }
                            _loginWithEmailPassword(context);
                          },
                          child: Text(
                            'Submit',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forget_password');
                          },
                          child: Text(
                            'Forgot password',
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don’t have an account?",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpPage()),
                                );
                              },
                              child: Text(
                                'Create new',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}
