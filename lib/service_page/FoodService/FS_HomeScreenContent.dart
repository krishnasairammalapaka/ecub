import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Cart_Db.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter/material.dart' hide CarouselController;

class FS_HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<FS_HomeScreenContent> {
  int _selectedIndex = 0;
  Box<Food_db>? FDbox;
  Box<Cart_Db>? _cartBox;
  String userFavType = 'both';

  Map<String, String> categoryImages = {};

  @override
  void initState() {
    super.initState();
    _openBox();
    _fetchUserFavType();
  }

  Future<void> _openBox() async {
    FDbox = await Hive.openBox<Food_db>('foodDbBox');
    _cartBox = await Hive.openBox<Cart_Db>('cartItems');
    _extractCategories();
  }

  void _extractCategories() {
    if (FDbox != null) {
      final categories = <String, String>{};
      for (var item in FDbox!.values) {
        categories[item.productMainCategory] = item.productImg;
      }
      setState(() {
        categoryImages = categories;
      });
    }
  }

  Future<void> _fetchUserFavType() async {
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userId = user.email;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userFavType = userDoc.data()?['userfavtype'] ?? 'both';
        });
      }
    } else {
      print("User not logged in.");
    }
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

  int getTotalCartItemsCount() {
    int totalItems = 0;
    for (var cartItem in _cartBox!.values) {
      totalItems += cartItem.ItemCount.toInt();
    }
    return totalItems;
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
              FDbox == null
                  ? Center(child: CircularProgressIndicator())
                  : ValueListenableBuilder(
                      valueListenable: FDbox!.listenable(),
                      builder: (context, Box<Food_db> items, _) {
                        if (items.isEmpty) {
                          return Center(child: Text('No items found.'));
                        } else {
                          List<Food_db> sortedItems = items.values
                              .where((item) => item.productRating >= 4.4)
                              .toList();

                          sortedItems.sort((a, b) =>
                              b.productRating.compareTo(a.productRating));

                          List<Food_db> favoriteItems =
                              sortedItems.where((item) {
                            return item.isVeg == userFavType;
                          }).toList();

                          List<Food_db> nonFavoriteItems =
                              sortedItems.where((item) {
                            return item.isVeg != userFavType;
                          }).toList();

                          List<Food_db> finalSortedItems =
                              favoriteItems + nonFavoriteItems;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: finalSortedItems.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2 / 3,
                            ),
                            itemBuilder: (context, index) {
                              var item = finalSortedItems[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/fs_product',
                                      arguments: {
                                        'id': item.productId,
                                        'title': item.productTitle,
                                        'price': item.productPrice.toInt(),
                                        'image': item.productImg,
                                        'description': item.productDesc,
                                        'shop': item.productOwnership,
                                      });
                                },
                                child: FoodTile(
                                  id: item.productId,
                                  title: item.productTitle,
                                  price: item.productPrice.toInt(),
                                  image: item.productImg,
                                  rating: item.productRating,
                                ),
                              );
                            },
                          );
                        }
                      },
                    )
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String image;

  CategoryCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class FoodTile extends StatelessWidget {
  final String id;
  final String title;
  final int price;
  final String image;
  double rating;

  FoodTile({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.rating,
  });

  Future<double?> _fetchAverageRating() async {
    final commentsCollection =
        FirebaseFirestore.instance.collection('fs_comments');
    final querySnapshot =
        await commentsCollection.where('foodId', isEqualTo: id).get();

    if (querySnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRating += data['rating'] ?? 0.0;
      }
      return totalRating / querySnapshot.docs.length;
    }
    return null; // Return null if there are no ratings
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double?>(
      future: _fetchAverageRating(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
          rating = snapshot.data!;
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Image.network(
                  image,
                  width: double.infinity,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹$price',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color.fromRGBO(0, 157, 255, 1.0),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 20,
                        ),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  final String image;

  CategoryTile({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      child: Container(
        width: screenSize.width * 0.25,
        height: screenSize.width * 0.3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              fit: BoxFit.cover,
              width: screenSize.width * 0.2,
              height: screenSize.width * 0.2,
            ),
            SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
