import 'package:ecub_s1_v2/models/CheckoutHistory_DB.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FS_Profile extends StatefulWidget {
  const FS_Profile({Key? key}) : super(key: key);

  @override
  State<FS_Profile> createState() => _FS_ProfileState();
}

class _FS_ProfileState extends State<FS_Profile> {
  bool isLoading = true;
  late Map<String, dynamic> userProfile;
  bool hasActiveSubscription = false;
  late String activeSubscriptionName;
  late String packID;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.email)
          .get();

      if (userDoc.exists) {
        setState(() {
          userProfile = userDoc.data()!;
          hasActiveSubscription = userProfile['isPackSubs'] ?? false;
        });

        if (hasActiveSubscription) {
          DocumentSnapshot<Map<String, dynamic>> packDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.email)
                  .collection('fs_service')
                  .doc('packs')
                  .get();

          if (packDoc.exists) {
            setState(() {
              packID = packDoc.data()!['packID'];
            });

            DocumentSnapshot<Map<String, dynamic>> packDetails =
                await FirebaseFirestore.instance
                    .collection('fs_packs')
                    .doc(packID)
                    .get();

            if (packDetails.exists) {
              setState(() {
                activeSubscriptionName = packDetails.data()!['pack_name'];
                isLoading = false;
              });
            }
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderSection(userProfile: userProfile),
                  Divider(),
                  if (hasActiveSubscription)
                    ActiveSubscriptionSection(
                      subscriptionName: activeSubscriptionName,
                      packID: packID,
                    ),
                  Divider(),
                  PastOrdersSection(),
                ],
              ),
            ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final Map<String, dynamic> userProfile;

  HeaderSection({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder(
                future: Translate.translateText(userProfile['firstname']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    return Text(snapshot.data!,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ));
                  } else {
                    return Text('N/A',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ));
                  }
                },
              ),
              TextButton(
                onPressed: () {},
                child: FutureBuilder<String>(
                  future: Translate.translateText("Edit"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      );
                    } else {
                      // Return a default Text widget if there's no data
                      return Text(
                        'EDIT',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Text(
            '${userProfile['phonenumber'] ?? 'N/A'} , ${userProfile['email'] ?? 'N/A'}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveSubscriptionSection extends StatelessWidget {
  final String subscriptionName;
  final String packID;

  ActiveSubscriptionSection(
      {required this.subscriptionName, required this.packID});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/fs_s_packcheck',
            arguments: {'id': packID},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(title: 'Active Subscription'),
            SizedBox(height: 10),
            Text(
              subscriptionName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PastOrdersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'Past Orders'),
          SizedBox(height: 20),
          OrdersListView(),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Translate.translateText(title),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return Text(snapshot.data!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ));
        } else {
          return Text(title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ));
        }
      },
    );
  }
}

class OrdersListView extends StatelessWidget {
  Future<List<DocumentSnapshot<Map<String, dynamic>>>>
      _getCheckoutHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('orders').get();
      return querySnapshot.docs;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      future: _getCheckoutHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('An error occurred'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No past orders found'));
        } else {
          final orders = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data()!;
              final userEmail = FirebaseAuth.instance.currentUser?.email;

              if (order['userId'] == userEmail) {
                final date = (order['timestamp'] as Timestamp).toDate();

                return OrderHistoryItem(
                  orderId: orders[index].id,
                  restaurant: order['itemName'] ?? 'Unknown Restaurant',
                  amount: order['itemPrice']?.toDouble() ?? 0,
                  date: date,
                );
              } else {
                return SizedBox.shrink();
              }
            },
          );
        }
      },
    );
  }
}

class OrderHistoryItem extends StatelessWidget {
  final String orderId;
  final String restaurant;
  final double amount;
  final DateTime date;

  const OrderHistoryItem({
    required this.orderId,
    required this.restaurant,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date into a readable string
    final formattedDate = DateFormat('MMMM d, yyyy at h:mm a').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: Translate.translateText(restaurant),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              } else {
                return Text(
                  restaurant,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            },
          ),
          Text('₹$amount'),
          Text(formattedDate), // Display formatted date
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: FutureBuilder<String>(
                  future: Translate.translateText("Reorder"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      return Text(snapshot.data!);
                    } else {
                      return Text('REORDER');
                    }
                  },
                ),
              ),
              // ElevatedButton(
              //   onPressed: () {},
              //   child: Text('RATE ORDER'),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
