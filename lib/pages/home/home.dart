import 'package:ecub_s1_v2/components/bottom_nav_bar.dart';
import 'package:ecub_s1_v2/components/speech_recog_page.dart';
import 'package:ecub_s1_v2/pages/home/home_screen.dart';
import 'package:ecub_s1_v2/profile/profile.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_cart.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_orders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Future<String> getUserName() async {
    var box = Hive.box('user_data');
    final firstName = box.get('firstname');
    final lastName = box.get('lastname');
    if (firstName != null && lastName != null) {
      return firstName + " " + lastName;
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
    Mecart(),
    MeOrders()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (_selectedIndex == 0 || _selectedIndex == 1)
            ? AppBar(
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
                                          WidgetStateProperty.all<Color>(
                                              const Color.fromRGBO(
                                                  187, 222, 251, 1)),
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
              )
            : null,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => SpeechRecognitionScreen(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
            );
          },
          backgroundColor: Colors.green, // Custom background color
          elevation: 10.0, // Custom elevation
          shape: RoundedRectangleBorder(
            // Custom shape
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Icon(Icons.mic),
        ),
        body: Center(
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavBar(
          onTabChange: (index) => navigateBottomBar(index),
        ));
  }
}
