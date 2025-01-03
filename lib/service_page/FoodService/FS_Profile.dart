import 'package:ecub_s1_v2/translation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:maps_launcher/maps_launcher.dart';



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
  Future<void> _launchMaps(String orderId) async {
  try {
    final orderDoc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();

    if (orderDoc.exists) {
      // Starting coordinates (9.5121° N, 77.6340° E)
      final startLat = 9.5121;
      final startLng = 77.6340;
      
      // Destination coordinates (9.5636° N, 77.6822° E)
      final destLat = 9.5636;
      final destLng = 77.6822;

      final intent = 'google.navigation:q=$destLat,$destLng&origin=$startLat,$startLng';
      if (await canLaunch(intent)) {
        await launch(intent);
      }
    }
  } catch (e) {
    print('Error launching maps: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'Past Orders'),
          SizedBox(height: 20),
          FutureBuilder<List<DocumentSnapshot>>(
            future: FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.email)
                .get()
                .then((snapshot) => snapshot.docs),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final order = snapshot.data![index].data() as Map<String, dynamic>;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['itemName'] ?? 'Unknown Item',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Amount: ₹${order['itemPrice']?.toString() ?? '0.0'}'),
                          Text('Status: ${order['status'] ?? 'Unknown'}'),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _launchMaps(snapshot.data![index].id),
                            icon: Icon(Icons.location_on),
                            label: Text('Track Order'),
                            style: ElevatedButton.styleFrom(
                               backgroundColor: Theme.of(context).primaryColor,
                             ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
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
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _getCheckoutHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where('userId', isEqualTo: user.email)
          .get();
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

          // Parse the timestamp string and sort the orders by date (descending)
          orders.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final dateA = DateTime.parse(aData['timestamp']);
            final dateB = DateTime.parse(bData['timestamp']);
            return dateB.compareTo(dateA); // Sorting in descending order (latest first)
          });

          // Group orders by date
          Map<String, List<DocumentSnapshot<Map<String, dynamic>>>> groupedOrders = {};
          for (var order in orders) {
            final orderData = order.data() as Map<String, dynamic>;
            String orderDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(orderData['timestamp']));

            if (groupedOrders.containsKey(orderDate)) {
              groupedOrders[orderDate]!.add(order);
            } else {
              groupedOrders[orderDate] = [order];
            }
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: groupedOrders.keys.length,
            itemBuilder: (context, index) {
              String date = groupedOrders.keys.toList()[index];
              List<DocumentSnapshot<Map<String, dynamic>>> ordersForDate = groupedOrders[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      date,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(), // Prevent inner list from scrolling
                    shrinkWrap: true, // Take up only as much space as needed
                    itemCount: ordersForDate.length,
                    itemBuilder: (context, index) {
                      final orderData = ordersForDate[index].data() as Map<String, dynamic>;
                      final status = orderData['status'] ?? 'pending';
                      final deliveryTime = orderData['etd'] ?? 'Loading...';

                      return OrderHistoryItem(
                        orderId: ordersForDate[index].id,
                        foodname: orderData['itemName'] ?? 'Unknown Food',
                        restaurant: orderData['vendor'] ?? 'Unknown Restaurant',
                        amount: orderData['itemPrice']?.toDouble() ?? 0,
                        status: status,
                        deliveryTime: deliveryTime,
                        foodId: orderData['itemId'] ?? '1',
                      );
                    },
                  ),
                ],
              );
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
  final String status;
  final String deliveryTime;
  final String foodname;
  final String foodId;

  const OrderHistoryItem({
    required this.orderId,
    required this.restaurant,
    required this.amount,
    required this.status,
    required this.deliveryTime,
    required this.foodname,
    required this.foodId,
  });

Future<void> _launchMaps(BuildContext context) async {
  try {
    final orderDoc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();

    if (orderDoc.exists) {
      // Starting coordinates (9.5121° N, 77.6340° E)
      final startLat = 9.5121;
      final startLng = 77.6340;
      
      // Destination coordinates (9.5636° N, 77.6822° E)
      final destLat = 9.5636;
      final destLng = 77.6822;

      final intent = 'google.navigation:q=$destLat,$destLng&origin=$startLat,$startLng';
      if (await canLaunch(intent)) {
        await launch(intent);
      }
    }
  } catch (e) {
    print('Error launching maps: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    String statusMessage;
    switch (status) {
      case 'pending':
        statusMessage = 'Food is being cooked';
        break;
      case 'in_transit':
        statusMessage = 'Food is on the way';
        break;
      case 'completed':
        statusMessage = 'Food is waiting to deliver';
        break;
      case 'delivered':
        statusMessage = 'Order delivered';
        break;
      default:
        statusMessage = 'Unknown status';
    }

    return GestureDetector(
      onTap: () => _launchMaps(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                foodname,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Amount: ₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Status: $statusMessage',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              if (status == 'delivered')
                Text('Delivered on: $deliveryTime',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }
}


class ReviewDialog extends StatefulWidget {
  final String orderId;
  final String restaurant;
  final String foodId;
  final Map<String, dynamic>? existingReview; // Add existing review data

  const ReviewDialog({
    required this.orderId,
    required this.restaurant,
    required this.foodId,
    this.existingReview, // Optional, can be null for new review
  });

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final TextEditingController _commentsController = TextEditingController();
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!['rating'] ?? 0.0;
      _commentsController.text = widget.existingReview!['comments'] ?? '';
    }
  }

  void _submitReview() async {
    User? user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user?.email)
        .get();

    var name=userDoc['firstname'];

    if (user != null) {
      final formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      await FirebaseFirestore.instance
          .collection('fs_comments')
          .doc(widget.orderId)
          .set({
        'foodId': widget.foodId,
        'orderId': widget.orderId,
        'restaurant': widget.restaurant,
        'userId': user.email,
        'rating': _rating,
        'comments': _commentsController.text,
        'timestamp': formattedTimestamp,
        'userName': name
      });

      Navigator.pop(context);
      setState(() {
        // Update UI state if needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Review ${widget.restaurant}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rate your experience:'),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          SizedBox(height: 10),
          TextField(
            controller: _commentsController,
            decoration: InputDecoration(hintText: 'Enter your comments here'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _submitReview,
          child: Text('Submit'),
        ),
      ],
    );
  }
}
