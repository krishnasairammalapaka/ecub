import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Cart_Db.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_FavoriteScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_Profile.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_Search.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FS_HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<FS_HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  Box<Food_db>? FDbox;
  Box<Cart_Db>? _cartBox;

  Map<String, String> categoryImages = {};

  @override
  void initState() {
    super.initState();
    _openBox();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _pageController.jumpToPage(index);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/user.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _cartBox!.listenable(),
              builder: (context, Box<Cart_Db> box, _) {
                int totalItems = getTotalCartItemsCount();

                return Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart, size: 40),
                      onPressed: () {
                        Navigator.pushNamed(context, '/fs_cart');
                      },
                    ),
                    if (totalItems > 0)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$totalItems',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,

              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good food.\nFast delivery.",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        CarouselSlider(
                          items: [
                            {
                              'image': 'assets/slide1.png',
                              'route': '/offers'
                            },
                            {
                              'image': 'assets/slide2.png',
                              'route': '/offers'
                            },
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
                                    margin:
                                    EdgeInsets.symmetric(horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                    ),
                                    child: Image.asset(
                                      item['image'] ??
                                          'assets/defaultImage.png',
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
                            autoPlayAnimationDuration:
                            Duration(milliseconds: 800),
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
                                Navigator.pushNamed(context, '/fs_category',
                                    arguments: {
                                      'title': "Home Made Restaurants",
                                      'type': "homemade"
                                    });
                              },
                              child: CategoryTile(
                                title: "Home Made",
                                image: "assets/home_made.png",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/fs_category',
                                    arguments: {
                                      'title': "Home Made Restaurants",
                                      'type': "restaurant"
                                    });
                              },
                              child: CategoryTile(
                                title: "Restuarent",
                                image: "assets/restuarnt_logo.png",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/fs_s_home',
                                    arguments: {
                                      'title': "entry.key",
                                      'type': "entry.key"
                                    });
                              },
                              child: CategoryTile(
                                title: "Subscription",
                                image: "assets/subscription_logo.png",
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
                            children:
                            categoryImages.entries.map((entry) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/fs_dishes',
                                      arguments: {
                                        'title': entry.key,
                                        'type': entry.key
                                      });
                                },
                                child: CategoryCard(
                                  title: entry.key,
                                  image: entry.value,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Popular now",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        FDbox == null
                            ? Center(child: CircularProgressIndicator())
                            : ValueListenableBuilder(
                          valueListenable: FDbox!.listenable(),
                          builder: (context, Box<Food_db> items, _) {
                            if (items.isEmpty) {
                              return Center(
                                  child: Text('No items found.'));
                            } else {
                              List<Food_db> sortedItems =
                              items.values.toList();
                              sortedItems.sort((a, b) => b.productRating
                                  .compareTo(a.productRating));

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: sortedItems.length,
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 2 / 3,
                                ),
                                itemBuilder: (context, index) {
                                  var item = sortedItems[index];
                                  if (item.productRating > 4.4) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/fs_product',
                                            arguments: {
                                              'id': item.productId,
                                              'title':
                                              item.productTitle,
                                              'price': item.productPrice
                                                  .toInt(),
                                              'image': item.productImg,
                                              'description':
                                              item.productDesc,
                                              'shop':
                                              item.productOwnership,
                                            });
                                      },
                                      child: FoodTile(
                                        title: item.productTitle,
                                        price:
                                        item.productPrice.toInt(),
                                        image: item.productImg,
                                        rating: item.productRating,
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              );
                            }
                          },
                        ),

                      ],
                    ),
                  ),
                )

              ],

            ),


          ),



          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Icon(
                    Icons.dinner_dining,
                    size: 30,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Icon(
                    Icons.search,
                    size: 30,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Icon(
                    Icons.favorite,
                    size: 30,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Icon(
                    Icons.person,
                    size: 30,
                  ),
                ),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            backgroundColor: Colors.red,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            onTap: _onItemTapped,
          ),
        ]));
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
                image: AssetImage(image),
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
  final String title;
  final int price;
  final String image;
  final double rating;

  FoodTile(
      {required this.title,
        required this.price,
        required this.image,
        required this.rating});

  @override
  Widget build(BuildContext context) {
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
            child: Image.asset(
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
                    color: Colors.red,
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
                      rating.toString(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
