import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key}); // Removed the 'super.' prefix for clarity and compatibility

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No user data found.'));
                }
                var userData = Hive.box("user_data");
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4.0,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.person,
                                color: Theme.of(context).primaryColor),
                            title: FutureBuilder(
                                future: Translate.translateText(
                                    '${userData.get('firstname')} ${userData.get('lastname')}'),
                                builder: (context, snapshotx) {
                                  if (snapshotx.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text('Loading...');
                                  }
                                  return snapshotx.hasData
                                      ? Text(snapshotx.data!,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold))
                                      : Text(
                                          '${userData.get('firstname')} ${userData.get('lastname')}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold));
                                }),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.email,
                                color: Theme.of(context).primaryColor),
                            title: Text('${userData.get('email')}',
                                style: TextStyle(fontSize: 18)),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone,
                                color: Theme.of(context).primaryColor),
                            title: Text('${userData.get('phonenumber')}',
                                style: TextStyle(fontSize: 18)),
                          ),
                          ListTile(
                            leading: Icon(Icons.cake,
                                color: Theme.of(context).primaryColor),
                            title: Text('${userData.get('age')}',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          //add mecart and me orders icon buttons
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     ElevatedButton.icon(
          //       onPressed: () {
          //         Navigator.pushNamed(context, '/me_cart');
          //       },
          //       icon: Icon(Icons.shopping_cart),
          //       label: Text('View Cart'),
          //     ),
          //     ElevatedButton.icon(
          //       onPressed: () {
          //         Navigator.pushNamed(context, '/me_orders');
          //       },
          //       icon: Icon(Icons.shopping_bag),
          //       label: Text('View Orders'),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
