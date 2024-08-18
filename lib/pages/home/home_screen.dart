import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<String> getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();
      return userData['firstname'] +
          " " +
          userData[
              'lastname']; // Assuming the field for the user's name is 'name'
    }
    return 'No User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Make the entire screen scrollable
        child: Column(
          children: [
            SizedBox(height: 20),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('categories').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  // Convert each document into a Category object
                  List<Category> categories = snapshot.data!.docs.map((doc) {
                    return Category.fromMap(doc.data() as Map<String, dynamic>);
                  }).toList();

                  // Pass the list of categories to the carouselSlider function
                  return Column(
                    children: [
                      carouselSlider(categories),
                      SizedBox(height: 20),
                      newCarousel(), // Add the new carousel here
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<String>(
                future: Translate.translateText("Categories"),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Text(
                          snapshot.data!,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          'Categories',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        );
                },
              ),
            ),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('categories').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  // Convert each document into a Category object
                  List<Category> categories = snapshot.data!.docs.map((doc) {
                    return Category.fromMap(doc.data() as Map<String, dynamic>);
                  }).toList();

                  // Pass the list of categories to the carouselSlider function
                  return grid_lay(categories);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget grid_lay(List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        shrinkWrap: true, // Add this line
        physics: NeverScrollableScrollPhysics(), // Disable GridView scrolling
        padding: const EdgeInsets.all(10), // Adjust padding as needed
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
          crossAxisSpacing: 10, // Horizontal space between items
          mainAxisSpacing: 10, // Vertical space between items
          childAspectRatio: 3 / 2, // Aspect ratio of each item
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, category.path);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5, // Shadow depth
                    offset: Offset(0, 5), // Shadow position
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.network(
                        category.imageUrl,
                        fit: BoxFit.cover,
                      ), // Category image
                    ),
                  ),
                  Padding(
                    // Add padding around the text
                    padding: EdgeInsets.all(8.0),
                    child: FutureBuilder<String>(
                      future: Translate.translateText(category.name),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? Text(snapshot.data!, textAlign: TextAlign.center)
                            : Text(category.name, textAlign: TextAlign.center);
                      },
                    ),
                    // Category name
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  CarouselSlider carouselSlider(List<Category> categories) {
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
                Navigator.pushNamed(context, category.path);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[100],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Image.network(category.imageUrl,
                            fit: BoxFit.cover)),
                    FutureBuilder<String>(
                      future: Translate.translateText(category.name),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? Text(snapshot.data!,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold))
                            : Text(category.name,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold));
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  CarouselSlider newCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 3.0,
        enlargeCenterPage: true,
      ),
      items: [
        // First image
        Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue[100],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/me_ad.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class Category {
  final String name;
  final String imageUrl;
  final String path; // Add the path property

  Category({
    required this.name,
    required this.imageUrl,
    required this.path, // Add path to the constructor
  });

  factory Category.fromMap(Map<String, dynamic> data) {
    return Category(
      name: data['name'],
      imageUrl: data['image_link'],
      path: data['path'], // Extract path from the map
    );
  }
}
