import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class FS_RestaurantScreen extends StatefulWidget {
  @override
  _FS_RestaurantScreenState createState() => _FS_RestaurantScreenState();
}

class _FS_RestaurantScreenState extends State<FS_RestaurantScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String hotelName = '';
  String hotelMail = '';
  String hotelAddress = '';
  String hotelUsername = '';
  double averageRating = 0.0;
  List<Map<String, dynamic>> foodItems = [];

  double userLatitude = 0.0;
  double userLongitude = 0.0;
  double distanceInKm = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchHotelInfo();
    _fetchUserLocation();
  }

  void _fetchUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      userLatitude = position.latitude;
      userLongitude = position.longitude;
      print("User Lat: $userLatitude");
      print("User Lon: $userLongitude");

      // Calculate distance only if both user and hotel data are available
      if (hotelLatitude != 0.0 && hotelLongitude != 0.0) {
        _calculateDistance();
      }
    });
  }

  void _fetchHotelInfo() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map;
    final hotelUsername = args['username'];

    final hotelQuerySnapshot = await _firestore
        .collection('fs_hotels')
        .where('hotelUsername', isEqualTo: hotelUsername)
        .get();

    if (hotelQuerySnapshot.docs.isNotEmpty) {
      final hotelData = hotelQuerySnapshot.docs.first.data();
      setState(() {
        hotelName = hotelData['hotelName'];
        hotelMail = hotelData['hotelMail'];
        hotelAddress = hotelData['hotelAddress'];
        this.hotelUsername = hotelData['hotelUsername'];

        hotelLatitude = double.parse(hotelData['latitude']);
        hotelLongitude = double.parse(hotelData['longitude']);
        print("Hotel Lat: $hotelLatitude");
        print("Hotel Lon: $hotelLongitude");

        if (userLatitude != 0.0 && userLongitude != 0.0) {
          _calculateDistance();
        }
      });

      _fetchFoodItems();
    } else {
      print('No hotel found with the given username.');
    }
  }


  void _calculateDistance() async {
    if (hotelLatitude != 0.0 && hotelLongitude != 0.0) {
      double distance = Geolocator.distanceBetween(
          userLatitude, userLongitude, hotelLatitude, hotelLongitude);

      setState(() {
        distanceInKm = distance / 1000;
      });
    }
  }


  double hotelLatitude = 0.0;
  double hotelLongitude = 0.0;





  void _fetchFoodItems() async {
    final foodItemsSnapshot = await _firestore
        .collection('fs_food_items1')
        .where('productOwnership', isEqualTo: hotelUsername)
        .get();

    if (foodItemsSnapshot.docs.isNotEmpty) {
      List<Map<String, dynamic>> tempFoodItems = [];

      for (var doc in foodItemsSnapshot.docs) {
        double averageRating = await _calculateAverageRating(doc['productId']);
        tempFoodItems.add({
          'name': doc['productTitle'],
          'restaurant': doc['productOwnership'],
          'price': doc['productPrice'],
          'image': doc['productImg'],
          'id': doc['productId'],
          'desc': doc['productDesc'],
          'averageRating': averageRating,
        });
      }

      setState(() {
        foodItems = tempFoodItems;
      });
    }
  }

  Future<double> _calculateAverageRating(String productId) async {
    final ratingsSnapshot = await _firestore
        .collection('fs_comments')
        .where('productId', isEqualTo: productId)
        .get();

    if (ratingsSnapshot.docs.isEmpty) {
      return 0.0;
    }

    double totalRating = 0.0;
    for (var doc in ratingsSnapshot.docs) {
      totalRating += doc['rating'];
    }

    return totalRating / ratingsSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: FutureBuilder<String>(
          future: Translate.translateText("Restaurant View"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!);
            } else {
              return Text('Restaurant View');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Color(0xFF0D5EF9)),
            onPressed: () {
              // Add your favorite button action here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage('assets/HotelPic.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder(
                future: Translate.translateText(hotelName),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ));
                  } else {
                    return Text(hotelName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ));
                  }
                },
              ),
              SizedBox(height: 8),
              Text(
                hotelMail,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder(
                future: Translate.translateText(hotelAddress),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data!,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    );
                  } else {
                    return Text(
                      hotelAddress,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.star, color: Color(0xFF0D5EF9)),
                  SizedBox(width: 4),
                  Text('4.7'),
                  SizedBox(width: 16),
                  Icon(Icons.delivery_dining, color: Color(0xFF0D5EF9)),
                  SizedBox(width: 4),
                  FutureBuilder<String>(
                    future: Translate.translateText("Free"),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? Text(snapshot.data!)
                          : Text("Free");
                    },
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.location_on, color: Color(0xFF0D5EF9)),
                  SizedBox(width: 4),
                  Text(
                    distanceInKm > 0
                        ? "${distanceInKm.toStringAsFixed(2)} km away"
                        : "Calculating...",
                  ),


                ],
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: foodItems
                    .map((item) => MenuItem(
                          name: item['name'],
                          restaurant: item['restaurant'],
                          price: item['price'].toInt(),
                          image: item['image'],
                          id: item['id'],
                          desc: item['desc'],
                          averageRating: averageRating,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  CategoryTab({required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF0D5EF9) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? null : Border.all(color: Color(0xFF0D5EF9)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Color(0xFF0D5EF9),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String id;
  final String name;
  final int price;
  final String image;
  final String desc;
  final String restaurant;
  final double averageRating;

  MenuItem({
    required this.name,
    required this.restaurant,
    required this.price,
    required this.image,
    required this.id,
    required this.desc,
    required this.averageRating,
  });

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> _calculateAverageRating(String productId) async {
    final ratingsSnapshot = await _firestore
        .collection('fs_comments')
        .where('foodId', isEqualTo: productId)
        .get();

    if (ratingsSnapshot.docs.isEmpty) {
      return 0.0;
    }

    double totalRating = 0.0;
    for (var doc in ratingsSnapshot.docs) {
      totalRating += doc['rating'];
    }

    return totalRating / ratingsSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final assetImage = image;

    return FutureBuilder<double>(
      future: _calculateAverageRating(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading rating'));
        } else {
          final averageRating = snapshot.data ?? 0.0;
          print(averageRating);
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/fs_product', arguments: {
                'id': id,
                'title': name,
                'price': price,
                'image': assetImage,
                'description': desc,
                'shop': restaurant,
              });
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(assetImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '₹$price',
                          style: TextStyle(
                            color: Color(0xFF0D5EF9),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(width: 1),
                      if (averageRating > 4.5)
                        Image.asset(
                          'assets/toprated.png',
                          height: 35,
                          width: 45,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
