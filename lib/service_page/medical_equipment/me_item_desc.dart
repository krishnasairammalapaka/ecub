// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/RentCalculator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class MeItemDesc extends StatelessWidget {
  final String storeName;
  final String categoryName;
  final String itemName;
  final String imageUrl;
  final String price;
  final String storeAddress;

  MeItemDesc({
    required this.storeName,
    required this.categoryName,
    required this.itemName,
    required this.imageUrl,
    required this.price,
    required this.storeAddress,
  });

  Future<void> addItemToCart(BuildContext context, String name, String storeName, String address,
        String rating, String imageUrl) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        DocumentReference itemRef = FirebaseFirestore.instance
            .collection('me_cart')
            .doc(user.email)
            .collection('items')
            .doc("${name}_$storeName");
  
        DocumentSnapshot itemSnapshot = await itemRef.get();
        if (itemSnapshot.exists) {
          int currentQuantity = itemSnapshot['quantity'];
          await itemRef.update({'quantity': currentQuantity + 1});
        } else {
          await itemRef.set({
            'name': name,
            'storeName': storeName,
            'address': address,
            'rating': rating,
            'imageUrl': imageUrl,
            'quantity': 1,
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(itemSnapshot.exists
                ? 'Item quantity updated'
                : 'Item added to cart'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    Stream<int> fetchCartItemCount() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      // Return a stream of document snapshots from Firestore
      return FirebaseFirestore.instance
          .collection('me_cart')
          .doc(user.email)
          .collection('items')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.length); // Map the snapshots to their count
    } else {
      // Return a stream of 0 if the user is not logged in
      return Stream.value(0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.blue,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: StreamBuilder<int>(
                stream: fetchCartItemCount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    return badges.Badge(
                      badgeContent: Text(
                        snapshot.data.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.shopping_cart),
                        onPressed: () {
                          Navigator.pushNamed(context, '/me_cart');
                        },
                      ),
                    );
                  } else {
                    return IconButton(
                      icon: Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.pushNamed(context, '/me_cart');
                      },
                    );
                  }
                },
              )),
        ],
        title: Text(itemName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    itemName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'by $storeName',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  Image.network(
                    imageUrl,
                    height: 200,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '₹$price',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Breath up to 95% pure oxygen',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add to cart logic here
                          addItemToCart(context, itemName, storeName, 'address', 'rating', imageUrl);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.shopping_cart),
                            SizedBox(width: 8),
                            Text('Add to cart'),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red, // Text color
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RentCalculator(
                                    shopName: storeName,
                                    productName: itemName,
                                    price: price,
                                    image_url: imageUrl,
                                    shopAddress: storeAddress,
                                  ),
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green, // Border color
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 8),
                            Text('Rental'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Product Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The Oxygen Concentrator is a portable and compact device that provides a continuous flow of oxygen to patients in need. It is ideal for home use, travel, and clinical settings.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '* Compact and lightweight design\n'
              '* Continuous flow of oxygen up to 5 LPM\n'
              '* Adjustable oxygen concentration (30-90%)\n'
              '* Low power consumption\n'
              '* Quiet operation\n'
              '* Easy to use and maintain',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Specifications:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Dimensions: 12 x 10 x 8 inches\n'
              'Weight: 15 lbs\n'
              'Power: 120V, 60Hz\n'
              'Oxygen output: 1-5 LPM\n'
              'Concentration: 30-95%',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Brand Name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      '4.4',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          color: Colors.yellow,
                        );
                      }),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('923 Ratings and 257 Reviews'),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text('67%'),
                        SizedBox(width: 4),
                        Container(
                          width: 150,
                          child: LinearProgressIndicator(
                            value: 0.67,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('20%'),
                        SizedBox(width: 4),
                        Container(
                          width: 150,
                          child: LinearProgressIndicator(
                            value: 0.20,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('7%'),
                        SizedBox(width: 4),
                        Container(
                          width: 150,
                          child: LinearProgressIndicator(
                            value: 0.07,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('2%'),
                        SizedBox(width: 4),
                        Container(
                          width: 150,
                          child: LinearProgressIndicator(
                            value: 0.02,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Erric Hoffman'),
              subtitle: Text('05-Jan-2024'),
              trailing: Icon(Icons.star, color: Colors.yellow),
            ),
            SizedBox(height: 16),
            Text(
              'Good quality product',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/me_cart');
                },
                child: Text('GO TO CART'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
