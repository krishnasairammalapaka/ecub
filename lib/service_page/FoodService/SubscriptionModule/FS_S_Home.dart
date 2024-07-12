import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class FS_S_Home extends StatefulWidget {
  @override
  _FS_S_HomeState createState() => _FS_S_HomeState();
}

class _FS_S_HomeState extends State<FS_S_Home>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Subscriptions'),
          centerTitle: true, // Center aligns the title

          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // Handle search action
              },
            ),
          ],

        ),
        body: Column(
          children: [
            SizedBox(height: 12),
            CarouselSlider(
              items: [
                {'image': 'assets/slide2.png', 'route': '/offers'},
                {'image': 'assets/slide4.png', 'route': '/offers'},
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
            SizedBox(height: 8), // Add space from the TabBar

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMealList('Full Meals'),
                  _buildMealList('Mini Meals'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealList(String mealType) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [

        _buildMealItem(),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMealItem() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/fs_s_desc');
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300] ?? Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: new Image.asset('assets/Meals.jpg'),
              ),
              SizedBox(height: 8),
              Text(
                'South Indian Veg Meal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Chip(
                    label: Text('BESTSELLER'),
                    backgroundColor: Colors.orange,
                  ),
                  Spacer(),
                  Icon(Icons.shopping_bag),
                  SizedBox(width: 8),
                  Icon(Icons.favorite_border),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 16),
                  Icon(Icons.star, color: Colors.orange, size: 16),
                  Icon(Icons.star, color: Colors.orange, size: 16),
                  Icon(Icons.star, color: Colors.orange, size: 16),
                  Icon(Icons.star, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Text('(10)'),
                ],
              ),
              SizedBox(height: 8),
              Text('Vegetable curry, Rotti, Dal, Curd, Pickle, Rice'),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _buildPriceTag(
                          'Weekly Subscription', '₹ 122', Colors.blue)),
                  SizedBox(width: 8),
                  Expanded(
                      child: _buildPriceTag(
                          'Monthly Subscription', '₹ 450', Colors.green)),
                ],
              ),
            ],
          ),
        ),
      )
    );



  }

  Widget _buildPriceTag(String title, String price, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            price,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}