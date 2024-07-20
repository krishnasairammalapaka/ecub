import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Hotels_Db.dart';

class FS_DishesScreen extends StatefulWidget {
  @override
  _FS_DishesScreenState createState() => _FS_DishesScreenState();
}

class _FS_DishesScreenState extends State<FS_DishesScreen> {
  Box<Food_db>? FDbox;
  Box<Hotels_Db>? hotelBox;
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  Future<void> _openBoxes() async {
    FDbox = await Hive.openBox<Food_db>('foodDbBox');
    hotelBox = await Hive.openBox<Hotels_Db>('hotelDbBox');
    setState(() {});
  }

  String getHotelName(String hotelUsername) {
    var hotel = hotelBox?.values.firstWhereOrNull(
          (hotel) => hotel.hotelUsername == hotelUsername,
    );
    return hotel?.hotelName ?? 'Unknown Hotel';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var dish = args['title'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D5EF9),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              items: [
                DropdownMenuItem(
                  child: Text("All"),
                  value: "all",
                ),
                DropdownMenuItem(
                  child: Text("Restaurant"),
                  value: "restuarent",
                ),
                DropdownMenuItem(
                  child: Text("Home-made"),
                  value: "homemade",
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
              },
              value: selectedFilter,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restaurants with $dish',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FDbox == null || hotelBox == null
                  ? Center(child: CircularProgressIndicator())
                  : ValueListenableBuilder(
                valueListenable: FDbox!.listenable(),
                builder: (context, Box<Food_db> items, _) {
                  if (items.isEmpty) {
                    return Center(child: Text('No items found.'));
                  } else {
                    var filteredItems = items.values.where((item) {
                      if (selectedFilter == 'all') {
                        return item.productMainCategory == dish;
                      } else if (selectedFilter == "restuarent") {
                        return item.productMainCategory == dish &&
                            item.productType == "restuarent";
                      } else if (selectedFilter == 'homemade') {
                        return item.productMainCategory == dish &&
                            item.productType == 'homemade';
                      }
                      return false;
                    }).toList();

                    if (filteredItems.isEmpty) {
                      return Center(child: Text('No items found.'));
                    }

                    return ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        var item = filteredItems[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/fs_product',
                              arguments: {
                                'id': item.productId,
                                'title': item.productTitle,
                                'price': item.productPrice.toInt(),
                                'image': item.productImg,
                                'description': item.productDesc,
                                'shop': item.productOwnership,
                              },
                            );
                          },
                          child: RestaurantCard(
                            name: item.productTitle,
                            location: getHotelName(item.productOwnership),
                            rating: item.productRating,
                            deliveryTime: item.productPrepTime,
                            imageUrl: item.productImg,
                            isHomeMade: item.productType == 'homemade',
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String deliveryTime;
  final String imageUrl;
  final bool isHomeMade;

  RestaurantCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.deliveryTime,
    required this.imageUrl,
    required this.isHomeMade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(location),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow[700]),
                      SizedBox(width: 5),
                      Text('$rating'),
                      SizedBox(width: 10),
                      Icon(Icons.timer, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(deliveryTime),
                    ],
                  ),
                  if (isHomeMade)
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      padding:
                      EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Home-made',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
