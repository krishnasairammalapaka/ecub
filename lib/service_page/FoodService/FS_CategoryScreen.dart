import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ecub_s1_v2/models/Hotels_Db.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:geolocator/geolocator.dart'; // Add this for geolocation

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
  double userLat = 0.0;
  double userLng = 0.0;

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



  Future<Position> _getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      throw Exception('Location permission not granted');
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371; // Radius of the earth in km
    double dLat = _deg2rad(lat2 - lat1);
    double dLng = _deg2rad(lng2 - lng1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String type = arguments['type'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D5EF9),
        elevation: 0,
        title: Text('Categories'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/fs_nearhotel');
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/maps.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

        ],
      ),
      body: FutureBuilder<Position>(
        future: _getUserLocation(), // Wait for user location
        builder: (context, locationSnapshot) {
          if (locationSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading spinner
          } else if (locationSnapshot.hasError) {
            return Center(child: Text('Error: ${locationSnapshot.error}'));
          } else if (locationSnapshot.hasData) {
            Position position = locationSnapshot.data!;
            userLat = position.latitude;
            userLng = position.longitude;

            return FutureBuilder<List<Hotels_Db>>(
              future: _getFilteredHotels(type),
              builder: (context, hotelSnapshot) {
                if (hotelSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (hotelSnapshot.hasError) {
                  return Center(child: Text('Error: ${hotelSnapshot.error}'));
                } else if (!hotelSnapshot.hasData || hotelSnapshot.data!.isEmpty) {
                  return Center(child: Text('No hotels found.'));
                } else {
                  final hotels = hotelSnapshot.data!;

                  // Sort the hotels based on distance from user's location
                  hotels.sort((a, b) {
                    double distanceA = _calculateDistance(
                        userLat, userLng, a.hotelLat, a.hotelLng);
                    double distanceB = _calculateDistance(
                        userLat, userLng, b.hotelLat, b.hotelLng);
                    return distanceA.compareTo(distanceB);
                  });

                  return ListView.builder(
                    itemCount: hotels.length,
                    itemBuilder: (context, index) {
                      final hotel = hotels[index];
                      final distance = _calculateDistance(
                          userLat, userLng, hotel.hotelLat, hotel.hotelLng);

                      return RestaurantCard(
                        name: hotel.hotelName,
                        location: hotel.hotelAddress,
                        rating: 4.5, // Example rating
                        deliveryTime: hotel.hotelPhoneNo,
                        imageUrl: 'assets/hotel_prof.png', // Example image URL
                        Username: hotel.hotelUsername,
                        distance: distance, // Add distance here
                      );
                    },
                  );
                }
              },
            );
          } else {
            return Center(child: Text('Could not fetch location.'));
          }
        },
      ),
    );
  }

  Future<List<Hotels_Db>> _getFilteredHotels(String type) async {
    final querySnapshot = await _firestore
        .collection('fs_hotels')
        .where('hotelType', isEqualTo: type)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Hotels_Db(
        hotelName: data['hotelName'],
        hotelAddress: data['hotelAddress'],
        hotelPhoneNo: data['hotelPhoneNo'],
        hotelType: data['hotelType'],
        hotelUsername: data['hotelUsername'],
        hotelLat: double.parse(data['latitude']),
          hotelLng: double.parse(data['longitude'])
      );
    }).toList();
  }
}

class RestaurantCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String deliveryTime;
  final String imageUrl;
  final String Username;
  final double distance; // Distance in km

  RestaurantCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.deliveryTime,
    required this.imageUrl,
    required this.Username,
    required this.distance,
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
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<String>(
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
                    ),
                    SizedBox(width: 10), // Spacer between location and distance
                    Text('${distance.toStringAsFixed(2)} km', // Display distance
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 10), // Spacer
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
              ],
            ),
          ),
        )

    );
  }
}

class Hotels_Db {
  final String hotelName;
  final String hotelAddress;
  final String hotelPhoneNo;
  final String hotelType;
  final String hotelUsername;
  final double hotelLat; // Latitude of the hotel
  final double hotelLng; // Longitude of the hotel

  Hotels_Db({
    required this.hotelName,
    required this.hotelAddress,
    required this.hotelPhoneNo,
    required this.hotelType,
    required this.hotelUsername,
    required this.hotelLat,
    required this.hotelLng,
  });
}
