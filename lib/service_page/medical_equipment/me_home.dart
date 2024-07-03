import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_items.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:badges/badges.dart' as badges;

class Category {
  final String name;
  final String image;

  Category({required this.name, required this.image});
}

class MeHomePage extends StatelessWidget {
  const MeHomePage({super.key});

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
        title: const Text('Medical Equipment Categories'),
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
            )
          ),
        ],
      ),

      body: Column(
        children: [
          future_carouselSlider(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Available medical services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          future_grid_layout(),
        ],
      ),
    );
  }

  FutureBuilder<QuerySnapshot<Object?>> future_carouselSlider() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('medical_eqipment_categories')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final categories = snapshot.data!.docs.map((doc) {
            return Category(
              name: doc['name'],
              image: doc['image_url'],
            );
          }).toList();
          return CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
            ),
            items: categories.map((category) {
              return Builder(
                builder: (BuildContext context) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MeItems(categoryName: category.name),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red[300],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.network(
                              category.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            category.name,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  FutureBuilder<QuerySnapshot<Object?>> future_grid_layout() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('medical_eqipment_categories')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          // Convert each document into a Category object
          final categories = snapshot.data!.docs.map((doc) {
            return Category(
              name: doc['name'],
              image: doc['image_url'],
              // Assuming there's an 'imageUrl' field
            );
          }).toList();
          return grid_lay(categories);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Expanded grid_lay(List<Category> categories) {
    return Expanded(
      // Wrap GridView with Expanded
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns in the grid
            crossAxisSpacing: 5, // Space between columns
            mainAxisSpacing: 10, // Space between rows
          ),
          itemCount: categories.length, // Number of items in the grid
          itemBuilder: (context, index) {
            // Accessing each category by index
            Category category = categories[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeItems(categoryName: category.name),
                  ),
                );
              },
              child: Card(
                // Wrap GridTile with Card for elevation and shape
                color: Colors.grey[200],
                elevation: 5, // Shadow depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: GridTile(
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(category.image,
                              fit: BoxFit.cover), // Category image
                        ),
                      ),
                      Padding(
                        // Add padding around the text
                        padding: EdgeInsets.all(8.0),
                        child: Text(category.name,
                            textAlign: TextAlign.center), // Category name
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
