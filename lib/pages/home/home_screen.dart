import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
      body: Column(
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
                return carouselSlider(categories);
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
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }

  Expanded grid_lay(List<Category> categories) {
    return Expanded(
      // Wrap GridView with Expanded
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
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
                  color: Colors.grey[200],
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
                        child: Image.network(category.imageUrl,
                            fit: BoxFit.cover,
                            // color: Colors.red[900],
                            ), // Category image
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
            );
          },
        ),
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
                  color: Colors.red[400],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Image.network(category.imageUrl,
                            fit: BoxFit.cover)),
                    Text(category.name,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
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