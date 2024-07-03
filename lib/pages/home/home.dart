import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/components/bottom_nav_bar.dart';
import 'package:ecub_s1_v2/pages/home/home_screen.dart';
import 'package:ecub_s1_v2/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Future<String> getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();
      return userData['firstname'] +
          " " +
          userData[
              'lastname']; // Assuming the field for the user's name is 'name'
    }
    return 'No User';
  }

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //greet user
          title: FutureBuilder<String>(
            future: getUserName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading...');
              }
              return Text('Hi, ${snapshot.data}');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text("Are you sure you want to logout?"),
                        actions: [
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all<Color>(const Color.fromRGBO(187, 222, 251, 1)),
                              ),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: Text("Yes")),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "No",
                              )),
                        ],
                      );
                    });
              },
            )
          ],
        ),
        body: Center(
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavBar(
          onTabChange: (index) => navigateBottomBar(index),
        ));
  }
}
