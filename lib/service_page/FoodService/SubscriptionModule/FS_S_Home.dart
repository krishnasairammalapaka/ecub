import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class FS_S_Home extends StatefulWidget {
  const FS_S_Home({super.key});

  @override
  _FS_S_HomeState createState() => _FS_S_HomeState();
}

class _FS_S_HomeState extends State<FS_S_Home>
    with SingleTickerProviderStateMixin {
  final int _selectedIndex = 0;
  TabController? _tabController;

  final firestoreInstance = FirebaseFirestore.instance;
  CollectionReference packsCollection =
      FirebaseFirestore.instance.collection('fs_packs');

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
          title: FutureBuilder<String>(
            future: Translate.translateText("Subscriptions"),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Text(snapshot.data!)
                  : Text("Subscriptions");
            },
          ),
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
    return StreamBuilder<QuerySnapshot>(
      stream: packsCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final packs = snapshot.data?.docs ?? [];

        return ListView(
          padding: EdgeInsets.all(16.0),
          children: packs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final packID = doc.id; // Extract the document ID

            int packPriceW = (data['pack_price_w'] is int) ? data['pack_price_w'] : int.tryParse(data['pack_price_w'].toString()) ?? 0; // Convert to int
            int packPriceM = (data['pack_price_m'] is int) ? data['pack_price_m'] : int.tryParse(data['pack_price_m'].toString()) ?? 0; // Convert to int

            // print(packID);
            return _buildMealItem(
              packID,
              data['pack_name'],
              data['pack_img'],
              data['pack_rating'],
              packPriceW,
              ((packPriceW / 7) * 30).round(),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMealItem(String id, String PackName, String image, double rating,
      int wprice, int mprice) {
    return GestureDetector(
      onTap: () {
        print(id);
        Navigator.pushNamed(context, '/fs_s_desc', arguments: {
          'id': id,
        });
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
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder<String>(
                future: Translate.translateText(PackName),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Text(snapshot.data!,
                          style: TextStyle(fontWeight: FontWeight.bold))
                      : Text(PackName,
                          style: TextStyle(fontWeight: FontWeight.bold));
                },
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Chip(
                    label: FutureBuilder<String>(
                      future: Translate.translateText("BESTSELLER"),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? Text(snapshot.data!,
                                style:
                                    TextStyle(overflow: TextOverflow.ellipsis))
                            : Text("BESTSELLER",
                                style:
                                    TextStyle(overflow: TextOverflow.ellipsis));
                      },
                    ),
                    backgroundColor: Colors.orange,
                  ),
                  Spacer(),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        color: index < rating ? Colors.orange : Colors.grey,
                        size: 16,
                      );
                    }),
                  ),
                  SizedBox(width: 8),
                  Text(rating.toString()),
                  Spacer(),
                ],
              ),
              SizedBox(height: 4),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPriceTag(
                        'Weekly Subscription', '₹ $wprice', Colors.blue),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildPriceTag(
                        'Monthly Subscription', '₹ $mprice', Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTag(String title, String price, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<String>(
          future: Translate.translateText(title),
          builder: (context, snapshot) {
            return snapshot.hasData ? Text(snapshot.data!) : Text(title);
          },
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.0),
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
