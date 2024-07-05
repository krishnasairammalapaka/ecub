import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FS_HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<FS_HomeScreen> {
  int _selectedIndex = 2;
  Box<Food_db>? FDbox;
  Map<String, String> categoryImages = {};

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    FDbox = await Hive.openBox<Food_db>('foodDbBox');
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/fs_home');
        break;
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/hamburger.png'),
          onPressed: () {},
        ),
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
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/fs_cart');
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/cart.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  {'image': 'assets/slide.png', 'route': '/home_subscribed'},
                  {'image': 'assets/slide2.png', 'route': '/home_made'},
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
              categoryImages.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categoryImages.entries.map((entry) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/fs_dishes',
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
                    return Center(child: Text('No items found.'));
                  } else {

                    List<Food_db> sortedItems = items.values.toList();
                    sortedItems.sort((a, b) =>
                        b.productRating.compareTo(a.productRating));

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
                              title: item.productTitle,
                              price: item.productPrice.toInt(),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
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

  FoodTile({required this.title, required this.price, required this.image, required this.rating});

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
