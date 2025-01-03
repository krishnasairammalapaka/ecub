import 'package:ecub_s1_v2/translation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Hotels_Db.dart';

class FS_Search extends StatefulWidget {
  const FS_Search({super.key});

  @override
  _FS_SearchState createState() => _FS_SearchState();
}

class _FS_SearchState extends State<FS_Search> {
  final TextEditingController _searchController = TextEditingController();
  Box<Food_db>? foodBox;
  Box<Hotels_Db>? hotelBox;

  List<Food_db> foodResults = [];
  List<Hotels_Db> hotelResults = [];

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  Future<void> _openBoxes() async {
    foodBox = await Hive.openBox<Food_db>('foodDbBox');
    hotelBox = await Hive.openBox<Hotels_Db>('hotelDbBox');
  }

  void _search(String query) {
    if (foodBox != null && hotelBox != null) {
      List<Food_db> foodItems = foodBox!.values.where((item) {
        return item.productTitle.toLowerCase().contains(query.toLowerCase()) ||
            item.productDesc.toLowerCase().contains(query.toLowerCase()) ||
            item.productMainCategory
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();

      List<Hotels_Db> hotelItems = hotelBox!.values.where((item) {
        return item.hotelName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        foodResults = foodItems;
        hotelResults = hotelItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: TabBar(
            tabs: [
              FutureBuilder<String>(
                future: Translate.translateText("Food Items"),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Tab(text: snapshot.data!)
                      : Tab(text: "Food items");
                },
              ),
              FutureBuilder<String>(
                future: Translate.translateText("Restaurants"),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Tab(text: snapshot.data!)
                      : Tab(text: "Restaurants");
                },
              ),
            ],
          ),
          title: Container(
            color: Colors.white,
            child: FutureBuilder<String>(
              future:
                  Translate.translateText("Search Food Items or Restaurants"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: snapshot.data!,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (value) {
                      _search(value);
                    },
                  );
                } else {
                  return TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Food Items or Restaurants',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (value) {
                      _search(value);
                    },
                  );
                }
              },
            ),
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (foodResults.isNotEmpty) ...[
                      FutureBuilder<String>(
                        future: Translate.translateText("Food Items"),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data!,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ));
                          } else {
                            return Text("Food Items",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ));
                          }
                        },
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: foodResults.length,
                        itemBuilder: (context, index) {
                          var item = foodResults[index];
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
                            child: FutureBuilder<List<String?>>(
                              future: Future.wait([
                                Translate.translateText(item.productTitle),
                                Translate.translateText(item.productDesc),
                                Translate.translateText(
                                    item.productMainCategory),
                                Translate.translateText(item.productOwnership),
                                Translate.translateText(item.productRating
                                    .toString()), // Assuming rating is numeric
                              ]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return FullSizedTile(
                                    title:
                                        snapshot.data![0] ?? item.productTitle,
                                    description:
                                        snapshot.data![1] ?? item.productDesc,
                                    imageUrl: item.productImg,
                                    category: snapshot.data![2] ??
                                        item.productMainCategory,
                                    location: snapshot.data![3] ??
                                        item.productOwnership,
                                    rating: double.tryParse(snapshot.data![4] ??
                                            item.productRating.toString()) ??
                                        item.productRating,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hotelResults.isNotEmpty) ...[
                      Text(
                        "Restaurants",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: hotelResults.length,
                        itemBuilder: (context, index) {
                          var item = hotelResults[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/fs_hotel',
                                  arguments: {
                                    'id': item.hotelId,
                                    'username': item.hotelUsername,
                                    'name': item.hotelName,
                                  });
                            },
                            child: FullSizedTile(
                              title: item.hotelName,
                              description: item.hotelMail,
                              imageUrl: "assets/hotel_prof.png",
                              category: item.hotelPhoneNo,
                              location: item.hotelAddress,
                              rating: 4.0,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullSizedTile extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String location;
  final double rating;

  const FullSizedTile({super.key, 
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.location,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              category,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Location: $location",
                  style: TextStyle(fontSize: 14),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 14),
                    Text(
                      rating.toString(),
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
