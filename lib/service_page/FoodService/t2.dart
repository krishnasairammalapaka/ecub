import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:flutter/material.dart';

class FS_HomeScreenContent extends StatefulWidget {
  const FS_HomeScreenContent({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<FS_HomeScreenContent> {
  int _selectedIndex = 0;
  CollectionReference foodCollection = FirebaseFirestore.instance.collection('fs_food_items1');
  CollectionReference cartCollection = FirebaseFirestore.instance.collection('fs_cart');
  CollectionReference commentsCollection = FirebaseFirestore.instance.collection('fs_comments');

  Map<String, String> categoryImages = {};

  @override
  void initState() {
    super.initState();
    foodCollection = FirebaseFirestore.instance.collection('fs_food_items1');
    cartCollection = FirebaseFirestore.instance.collection('fs_cart');
    commentsCollection = FirebaseFirestore.instance.collection('fs_comments');
    _extractCategories();
  }

  Future<void> _extractCategories() async {
    final categories = <String, String>{};
    final snapshot = await foodCollection.get();

    for (var item in snapshot.docs) {
      categories[item['productMainCategory']] = item['productImg'];
    }

    setState(() {
      categoryImages = categories;
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 1:
          Navigator.pushNamed(context, '/fs_search');
          break;
        case 2:
          Navigator.pushNamed(context, '/fs_favourite');
          break;
        case 3:
          Navigator.pushNamed(context, '/fs_profile');
          break;
        default:
          break;
      }
    }
  }

  Future<num> getTotalCartItemsCount() async {
    num totalItems = 0;
    final snapshot = await cartCollection.get();

    for (var cartItem in snapshot.docs) {
      totalItems += cartItem['ItemCount'].toInt();
    }

    return totalItems;
  }

  Future<double> _calculateAverageRating(String foodId) async {
    final snapshot = await commentsCollection.where('foodId', isEqualTo: foodId).get();
    if (snapshot.docs.isEmpty) return 0.0;

    double totalRating = 0.0;
    snapshot.docs.forEach((doc) {
      totalRating += doc['rating'];
    });

    return totalRating / snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String>(
                future: Translate.translateText("Good food\n fast delivery"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    return Text(
                      snapshot.data!,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    return Text(
                      "Good food\n Fast delivery",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              CarouselSlider(
                items: [
                  {'image': 'assets/slide1.png', 'route': '/offers'},
                  {'image': 'assets/slide2.png', 'route': '/offers'},
                ].map((item) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        item['route'] ?? '/defaultRoute',
                      );
                    },
                    child: Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: screenSize.width * 0.9,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                          ),
                          child: Image.asset(
                            item['image'] ?? 'assets/defaultImage.png',
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: screenSize.height * 0.15,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayInterval: Duration(seconds: 6),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: true,
                  viewportFraction: 1.0,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/fs_category', arguments: {
                        'title': "Home Made Restaurants",
                        'type': "homemade"
                      });
                    },
                    child: FutureBuilder<String>(
                      future: Translate.translateText("Homemade"),
                      builder: (context, snapshot) {
                        return CategoryTile(
                          title: snapshot.hasData ? snapshot.data! : "Homemade",
                          image: "assets/home_made.png",
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/fs_category', arguments: {
                        'title': "Home Made Restaurants",
                        'type': "restaurant"
                      });
                    },
                    child: FutureBuilder<String>(
                      future: Translate.translateText("Restaurants"),
                      builder: (context, snapshot) {
                        return CategoryTile(
                          title:
                          snapshot.hasData ? snapshot.data! : "Restaurants",
                          image: "assets/restuarnt_logo.png",
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/fs_s_home', arguments: {
                        'title': "entry.key",
                        'type': "entry.key"
                      });
                    },
                    child: FutureBuilder<String>(
                      future: Translate.translateText("Subscription"),
                      builder: (context, snapshot) {
                        return CategoryTile(
                          title: snapshot.hasData
                              ? snapshot.data!
                              : "Subscription",
                          image: "assets/subscription_logo.png",
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              categoryImages.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categoryImages.entries.map((entry) {
                    return GestureDetector(
                      onTap: () {
                        print(entry.key);
                        Navigator.pushNamed(context, '/fs_dishes',
                            arguments: {
                              'title': entry.key,
                              'type': entry.key
                            });
                      },
                      child: FutureBuilder<String>(
                        future: Translate.translateText(entry.key),
                        builder: (context, snapshot) {
                          return CategoryCard(
                              title: snapshot.hasData
                                  ? snapshot.data!
                                  : entry.key,
                              image: entry.value);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<String>(
                future: Translate.translateText("Popular Now"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    return Text(
                      snapshot.data!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    return Text(
                      "Popular now",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              FutureBuilder<QuerySnapshot>(
                future: foodCollection.get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: FutureBuilder<String>(
                          future: Translate.translateText('No items found.'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasData) {
                              return Center(child: Text(snapshot.data!));
                            } else {
                              return Center(
                                  child: Text(
                                      'No items found.')); // Fall back to original text if translation fails
                            }
                          },
                        ));
                  } else {
                    List<DocumentSnapshot> sortedItems = snapshot.data!.docs;
                    // sortedItems.sort((a, b) =>
                    //     (b['productRating'] as num).compareTo(a['productRating'] as num));

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: sortedItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final item = sortedItems[index];
                        final itemId = item.id;
                        return FutureBuilder<double>(
                          future: _calculateAverageRating(itemId),
                          builder: (context, ratingSnapshot) {
                            if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (ratingSnapshot.hasData) {
                              final averageRating = ratingSnapshot.data!;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/fs_item_details',
                                      arguments: itemId);
                                },
                                child: FoodCard(
                                  title: item['productTitle'],
                                  image: item['productImg'],
                                  price: item['productPrice'],
                                  rating: averageRating,
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/fs_item_details',
                                      arguments: itemId);
                                },
                                child: FoodCard(
                                  title: item['productName'],
                                  image: item['productImg'],
                                  price: item['productPrice'],
                                  rating: 0.0,
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  final String image;

  const CategoryTile({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(image, height: 60, width: 60),
        SizedBox(height: 5),
        Text(title),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String image;

  const CategoryCard({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
      ),
      child: Column(
        children: [
          Image.network(image, height: 60, width: 60),
          SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final String title;
  final String image;
  final double price;
  final double rating;

  const FoodCard({super.key, 
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(image, height: 80, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('\$${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
