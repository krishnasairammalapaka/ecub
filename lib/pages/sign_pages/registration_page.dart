import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final firstnameController = TextEditingController();

  final lastnameController = TextEditingController();

  final phonenumberController = TextEditingController();

  final emailController = TextEditingController();

  final ageController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmpasswordController = TextEditingController();

  Future<void> addUser(BuildContext context) async {
    final localContext = context;
    if (firstnameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter your first name'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (lastnameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter your last name'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (phonenumberController.text.isEmpty ||
        phonenumberController.text.length != 10) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid phone number'),
            content: Text('Please enter a valid mobile number'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Email'),
            content: Text('Please enter a valid email'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (ageController.text.isEmpty ||
        int.tryParse(ageController.text) == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid age'),
            content: Text('Please enter a valid age'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Weak Password'),
            content: Text('Password must be at least 6 characters long'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (passwordController.text != confirmpasswordController.text) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Mismatch'),
            content: Text('Password and confirm password do not match'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      // Create a new user with Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        String email = userCredential
            .user!.email!; // It's safe to use ! here after the null check

        // Add user details to Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        firestore.collection('users').doc(email).set({
          'firstname': firstnameController.text,
          'lastname': lastnameController.text,
          'phonenumber': phonenumberController.text,
          'age': int.parse(ageController.text),
          'email': email,
        });


        // Check if the widget is still mounted before showing the dialog
        if (!mounted) return;

        // User registration successful
        showDialog(
          context: context, // Use the current context directly
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registration Successful'),
              content: Text('You have been successfully registered.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // Optionally, navigate to another screen here if needed
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Handle the case where the user is null
        showDialog(
          context: context, // Use the current context directly
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registration Error'),
              content: Text('Failed to create user account.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      }
      // Check if the widget is still mounted before showing the dialog
      if (!mounted) return;

      // User registration successful
      showDialog(
        context: localContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Successful'),
            content: Text('You have been successfully registered.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the dialog
                  // Optionally, navigate to another screen
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Check if the widget is still mounted before showing the dialog
      if (!mounted) return;

      // Handle errors
      showDialog(
        context: localContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Failed'),
            content: Text(e.toString()), // Show the error message
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color.fromARGB(255, 243, 195, 210),
              Color.fromARGB(255, 255, 250, 250),
              Color.fromARGB(255, 255, 250, 250),
              Color.fromARGB(255, 221, 210, 251)
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Sign Up to ECUB",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 122, 7, 7),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: firstnameController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Enter your First name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: lastnameController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Enter your Last name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: phonenumberController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Enter your Mobile number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        } else if (value.length != 10 &&
                            !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                          return 'Please enter a valid mobile number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Enter your email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Age',
                          hintText: "Enter age",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        } else if (int.tryParse(value) == null) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Enter your password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: confirmpasswordController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          labelText: 'Confirm your password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      obscureText: true,
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        addUser(context);
                      },
                      child: Text('Register'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already having the account?"),
                        // SizedBox(width: 2),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
