import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ecub_s1_v2/models/Hotels_Db.dart';
import 'package:ecub_s1_v2/translation.dart';

class FS_CategoryScreen extends StatefulWidget {
  @override
  _FS_CategoryScreenState createState() => _FS_CategoryScreenState();
}

class _FS_CategoryScreenState extends State<FS_CategoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String hotelName = '';
  String hotelMail = '';
  String hotelAddress = '';
  String hotelUsername = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchLastOrder();
  }

  void _showSuggestionPopUp(String timeElapsed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Would you like to reorder?"),
          content: Text(
              "Your last order from this hotel was delivered $timeElapsed hours ago. Would you like to buy from them again?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to the order page or add item to cart
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchLastOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    final userMail = user?.email;

    if (userMail != null) {
      final orderQuerySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userMail)
          .orderBy('deliveryTime', descending: true)
          .limit(1)
          .get();

      if (orderQuerySnapshot.docs.isNotEmpty) {
        final lastOrder = orderQuerySnapshot.docs.first.data();
        final lastOrderHotel = lastOrder['vendor'];
        final lastOrderDeliveryTime = lastOrder['deliveryTime'];

        // Compare hotel usernames
        if (lastOrderHotel == hotelUsername) {
          // final timeElapsed = DateTime.now().difference(lastOrderDeliveryTime).inHours.toString();
          _showSuggestionPopUp(lastOrderDeliveryTime);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String type = arguments['type'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D5EF9),
        elevation: 0,
        title: Text('Categories'), // Added a title for better UI
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Hotels_Db>>(
                future: _getFilteredHotels(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hotels found.'));
                  } else {
                    final hotels = snapshot.data!;
                    return ListView.builder(
                      itemCount: hotels.length,
                      itemBuilder: (context, index) {
                        final hotel = hotels[index];
                        return RestaurantCard(
                          name: hotel.hotelName,
                          location: hotel.hotelAddress,
                          rating: 4.5, // Example rating, replace with actual data
                          deliveryTime: hotel.hotelPhoneNo, // Example data, replace if needed
                          imageUrl: 'assets/hotel.png', // Replace with actual image URL
                          Username: hotel.hotelUsername,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Hotels_Db>> _getFilteredHotels(String type) async {
    final hotelBox = await Hive.openBox<Hotels_Db>('hotelDbBox');
    return hotelBox.values.where((hotel) => hotel.hotelType == type).toList();
  }
}

class RestaurantCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String deliveryTime;
  final String imageUrl;
  final String Username;

  RestaurantCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.deliveryTime,
    required this.imageUrl,
    required this.Username,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/fs_hotel', arguments: {
          'id': 1,
          'username': Username,
          'name': name,
        });
      },
      child: Card(
        child: ListTile(
          leading: Image.asset(imageUrl, width: 50, height: 50),
          title: FutureBuilder<String>(
            future: Translate.translateText(name),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Transform.scale(
                  scale: 0.4,
                  child: CircularProgressIndicator(),
                );
              } else {
                return snapshot.hasData ? Text(snapshot.data!) : Text(name);
              }
            },
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String>(
                future: Translate.translateText(location),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Transform.scale(
                      scale: 0.4,
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return snapshot.hasData ? Text(snapshot.data!) : Text(location);
                  }
                },
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow[700]),
                  SizedBox(width: 5),
                  Text('$rating'),
                  SizedBox(width: 10),
                  Icon(Icons.phone, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(deliveryTime),
                ],
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
