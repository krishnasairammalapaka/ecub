import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Cart_Db.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_FavoriteScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_HomeScreenContent.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_Profile.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_Search.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecub_s1_v2/components/bottom_nav_fs.dart';

class FS_HomeScreen extends StatefulWidget {
  @override
  _FS_HomeScreenState createState() => _FS_HomeScreenState();
}

class _FS_HomeScreenState extends State<FS_HomeScreen> {
  int _selectedIndex = 0;
  Box<Food_db>? FDbox;
  Box<Cart_Db>? _cartBox;

  Map<String, String> categoryImages = {};

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    FDbox = await Hive.openBox<Food_db>('foodDbBox');
    _cartBox = await Hive.openBox<Cart_Db>('cartItems');
    _extractCategories();
    setState(() {});
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
    if (_cartBox != null) {
      for (var cartItem in _cartBox!.values) {
        totalItems += cartItem.ItemCount.toInt();
      }
    }
    return totalItems;
  }

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    FS_HomeScreenContent(),
    FS_Search(),
    FS_FavoriteScreen(),
    FS_Profile(),
  ];

  @override
  Widget build(BuildContext context) {
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
                          color: Color(0xFF0D5EF9),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
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
                    color: Color(0xFF0D5EF9),
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
  final VoidCallback onTap;

  CategoryTile({required this.title, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
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
