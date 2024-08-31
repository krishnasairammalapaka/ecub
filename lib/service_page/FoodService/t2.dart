import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  List<Map<String, dynamic>> foodItems = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchHotelInfo();
  }


  void _fetchHotelInfo() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map;
    final hotelUsernameArg = args['username'];


    final hotelQuerySnapshot = await _firestore
        .collection('fs_hotels')
        .where('hotelUsername', isEqualTo: hotelUsernameArg)
        .get();

    if (hotelQuerySnapshot.docs.isNotEmpty) {
      final hotelData = hotelQuerySnapshot.docs.first.data();
      setState(() {
        hotelName = hotelData['hotelName'] ?? '';
        hotelMail = hotelData['hotelMail'] ?? '';
        hotelAddress = hotelData['hotelAddress'] ?? '';
        hotelUsername = hotelData['hotelUsername'] ?? '';
      });
      _fetchFoodItems();
    } else {

      print('No hotel found with the given username.');
      setState(() {
        isLoading = false;
      });
    }
  }


  void _fetchFoodItems() async {
    final foodItemsSnapshot = await _firestore
        .collection('fs_food_items1')
        .where('productOwnership', isEqualTo: hotelUsername)
        .get();

    if (foodItemsSnapshot.docs.isNotEmpty) {
      List<Map<String, dynamic>> items = [];

      for (var doc in foodItemsSnapshot.docs) {
        String productId = doc['productId'];
        double averageRating = await _fetchAverageRating(productId);

        items.add({
          'name': doc['productTitle'] ?? '',
          'restaurant': doc['productOwnership'] ?? '',
          'price': (doc['productPrice'] ?? 0),
          'image': doc['productImg'] ?? '',
          'id': doc['productId'] ?? '',
          'desc': doc['productDesc'] ?? '',
          'rating': averageRating,
        });
      }


      double maxRating = items.isNotEmpty
          ? items.map((item) => item['rating'] as double).reduce((a, b) => a > b ? a : b)
          : 0.0;

      setState(() {
        foodItems = items.map((item) {
          item['isTopRated'] = item['rating'] == maxRating;
          return item;
        }).toList();
        isLoading = false;
      });

      print('Fetched food items: $foodItems');
    } else {
      setState(() {
        foodItems = [];
        isLoading = false;
      });
      print('No food items found for hotelUsername: $hotelUsername');
    }
  }


  Future<double> _fetchAverageRating(String productId) async {
    final commentsSnapshot = await _firestore
        .collection('fs_comments')
        .where('productId', isEqualTo: productId)
        .get();

    if (commentsSnapshot.docs.isEmpty) {
      return 0.0;
    }

    double totalRating = commentsSnapshot.docs
        .map((doc) {
      var rating = doc['rating'];
      if (rating is int) {
        return rating.toDouble();
      } else if (rating is double) {
        return rating;
      } else {
        return 0.0;
      }
    })
        .fold(0.0, (prev, element) => prev + element);

    return totalRating / commentsSnapshot.docs.length;
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

            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    return Text(
                      snapshot.data!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    return Text(
                      hotelName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
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
                  Icon(Icons.access_time, color: Color(0xFF0D5EF9)),
                  SizedBox(width: 4),
                  FutureBuilder<String>(
                    future: Translate.translateText("20 minutes"),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? Text(snapshot.data!)
                          : Text("20 min");
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              foodItems.isEmpty
                  ? Text('No food items available.')
                  : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: foodItems.map((item) {
                  double rating = (item['rating'] is num)
                      ? (item['rating'] as num).toDouble()
                      : 0.0;
                  bool isTopRated = item['isTopRated'] ?? false;

                  return MenuItem(
                    name: item['name'] ?? '',
                    restaurant: item['restaurant'] ?? '',
                    price: (item['price'] ?? 0).toInt(),
                    image: item['image'] ?? '',
                    id: item['id'] ?? '',
                    desc: item['desc'] ?? '',
                    rating: rating,
                    isTopRated: isTopRated,
                  );
                }).toList(),
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
  final double rating;
  final bool isTopRated;

  MenuItem({
    required this.name,
    required this.restaurant,
    required this.price,
    required this.image,
    required this.id,
    required this.desc,
    required this.rating,
    required this.isTopRated,
  });

  @override
  Widget build(BuildContext context) {
    final assetImage = image;
    return FutureBuilder<List<String?>>(
      future: Future.wait([
        Translate.translateText(name),
        Translate.translateText(desc),
        Translate.translateText(restaurant),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading translations'));
        } else {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/fs_product', arguments: {
                'id': id,
                'title': snapshot.data![0] ?? name,
                'price': price,
                'image': assetImage,
                'description': snapshot.data![1] ?? desc,
                'shop': snapshot.data![2] ?? restaurant,
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          snapshot.data![0] ?? name,
                          style: TextStyle(
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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
                      if (isTopRated)
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
