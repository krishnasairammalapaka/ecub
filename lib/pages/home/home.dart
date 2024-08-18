// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/components/bottom_nav_bar.dart';
import 'package:ecub_s1_v2/components/speech_recog_page.dart';
import 'package:ecub_s1_v2/main.dart';
import 'package:ecub_s1_v2/pages/home/home_screen.dart';
import 'package:ecub_s1_v2/profile/profile.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_cart.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_orders.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:ecub_s1_v2/globals.dart' as globals;

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
      return firstName;
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
  void showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Language"),
          content: Container(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    elevation: 1,
                    child: ListTile(
                      title: Center(child: Text("English")),
                      onTap: () {
                        setState(() {
                          globals.selectedLanguage = 'en';
                          print(
                              'Selected Language: ${globals.selectedLanguage}');
                        });
                        Navigator.of(context).pop();
                        _restartApp();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Material(
                    elevation: 1,
                    child: ListTile(
                      title: Center(child: Text("हिंदी")),
                      onTap: () {
                        setState(() {
                          globals.selectedLanguage = 'hi';
                        });
                        Navigator.of(context).pop();
                        _restartApp();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Material(
                    elevation: 1,
                    child: ListTile(
                      title: Center(child: Text("ಕನ್ನಡ")),
                      onTap: () {
                        setState(() {
                          globals.selectedLanguage = 'kn';
                        });
                        Navigator.of(context).pop();
                        _restartApp();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Material(
                    elevation: 1,
                    child: ListTile(
                      title: Center(child: Text("मराठी")),
                      onTap: () {
                        setState(() {
                          globals.selectedLanguage = 'mr';
                        });
                        Navigator.of(context).pop();
                        _restartApp();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Material(
                    elevation: 1,
                    child: ListTile(
                      title: Center(child: Text("ଓଡିଆ")),
                      onTap: () {
                        setState(() {
                          globals.selectedLanguage = 'or';
                        });
                        Navigator.of(context).pop();
                        _restartApp();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Material(
                    elevation: 1,
                    child: ListTile(
                      title: Center(child: Text("தமிழ்")),
                      onTap: () {
                        setState(() {
                          globals.selectedLanguage = 'ta';
                        });
                        Navigator.of(context).pop();
                        _restartApp();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Material(
                    elevation: 1,
                    child: ListTile(
                      title: Center(child: Text("తెలుగు")),
                      onTap: () {
                        setState(() {
                          globals.selectedLanguage = 'te';
                        });
                        Navigator.of(context).pop();
                        _restartApp();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _restartApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()),
      (Route<dynamic> route) => false,
    );
  }

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
                      return Text('Loading...');
                    }
                    // return Text('Hi, ${snapshot.data}');
                    return FutureBuilder(
                        future: Translate.translateText('Hi! ${snapshot.data}'),
                        builder: (context, snapshotx) {
                          if (snapshotx.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading...');
                          }
                          return Text(
                            snapshotx.data!,
                            overflow: TextOverflow.ellipsis,
                          );
                        });
                  },
                ),
                actions: [
                  GestureDetector(
                    onTap: showLanguageDialog,
                    child: Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Stack(
                        children: [
                          Icon(
                              FontAwesomeIcons
                                  .language, // Font Awesome language icon
                              size: 35,
                              color: Colors.black),
                          // Positioned(
                          //   right: 0,
                          //   bottom: 0,
                          //   child: Container(
                          //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          //     decoration: BoxDecoration(
                          //       color: Colors.white,
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //     child: Text(
                          //       globals.selectedLanguage.toUpperCase(),
                          //       style: TextStyle(
                          //         color: Colors.black,
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
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
