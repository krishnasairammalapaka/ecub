import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/components/bottom_nav_bar.dart';
import 'package:ecub_s1_v2/components/speech_recog_page.dart';
import 'package:ecub_s1_v2/globals.dart' as globals;
import 'package:ecub_s1_v2/main.dart';
import 'package:ecub_s1_v2/pages/home/home_screen.dart';
import 'package:ecub_s1_v2/profile/profile.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_cart.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_orders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreNotificationService.initializeFirestoreListener(user.email!);
      analyzeAndSaveUserFavType(user.email!);
    } else {
      print("User not logged in.");
    }
  }

  Future<void> analyzeAndSaveUserFavType(String userId) async {
    final ordersRef = FirebaseFirestore.instance.collection('orders');
    final usersRef = FirebaseFirestore.instance.collection('users');

    QuerySnapshot userOrdersSnapshot =
        await ordersRef.where('userId', isEqualTo: userId).get();

    if (userOrdersSnapshot.docs.isEmpty) {
      await usersRef.doc(userId).update({'userfavtype': 'veg and nonveg'});
      return;
    }

    bool likesVeg = false;
    bool likesNonVeg = false;

    for (var order in userOrdersSnapshot.docs) {
      String foodId = order.get('itemId');
      DocumentSnapshot foodSnapshot = await FirebaseFirestore.instance
          .collection('fs_food_items1')
          .doc(foodId)
          .get();

      if (foodSnapshot.exists) {
        String foodType = foodSnapshot.get('isVeg').toString();

        if (foodType == 'true') {
          likesVeg = true;
        } else if (foodType == 'false') {
          likesNonVeg = true;
        }
      }
    }

    String userFavType;
    if (likesVeg && likesNonVeg) {
      userFavType = 'veg and nonveg';
    } else if (likesVeg) {
      userFavType = 'veg';
    } else if (likesNonVeg) {
      userFavType = 'nonveg';
    } else {
      userFavType = 'veg and nonveg'; // Fallback
    }

    await usersRef.doc(userId).update({'userfavtype': userFavType});
  }

  Future<String> getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email) // Assuming email is used as the document ID
          .get();
      if (userData.exists) {
        final firstName = userData['firstname'];
        final lastName = userData['lastname'];
        return '$firstName $lastName';
      }
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
              title: FutureBuilder<String>(
                future: getUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  }

                  String userName = snapshot.data ?? 'No User';
                  return Text('Hi! $userName', overflow: TextOverflow.ellipsis);
                },
              ),
              actions: [
                GestureDetector(
                  onTap: showLanguageDialog,
                  child: Container(
                    margin: EdgeInsets.only(right: 15),
                    child: const Icon(FontAwesomeIcons.language,
                        size: 35, color: Colors.black),
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
                                    MaterialStateProperty.all<Color>(
                                        const Color.fromRGBO(187, 222, 251, 1)),
                              ),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: Text("Yes"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No"),
                            ),
                          ],
                        );
                      },
                    );
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
        backgroundColor: Colors.green,
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: Icon(Icons.mic),
      ),
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
    );
  }

  void showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Language"),
          content: SizedBox(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Center(child: Text("English")),
                    onTap: () {
                      setState(() {
                        globals.selectedLanguage = 'en';
                      });
                      Navigator.of(context).pop();
                      _restartApp();
                    },
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
}

class FirestoreNotificationService {
  static void initializeFirestoreListener(String userId) {
    FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data != null && data['status'] != null) {
            String newStatus = data['status'];
            OrderNotification({
              'title': 'Order Status Updated',
              'description': 'Your order status has changed to $newStatus.'
            });
          }
        }
      }
    });
  }
}
