import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Hotels_Db.dart';

class FS_Search extends StatefulWidget {
  @override
  _FS_SearchState createState() => _FS_SearchState();
}

class _FS_SearchState extends State<FS_Search> {
  int _selectedIndex = 1;

  TextEditingController _searchController = TextEditingController();
  Box<Food_db>? foodBox;
  Box<Hotels_Db>? hotelBox;

  List<Food_db> foodResults = [];
  List<Hotels_Db> hotelResults = [];
  List<Hotels_Db> topHotels = [];
  List<Food_db> popularFoodItems = [];

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  Future<void> _openBoxes() async {
    foodBox = await Hive.openBox<Food_db>('foodDbBox');
    hotelBox = await Hive.openBox<Hotels_Db>('hotelDbBox');
    if (foodBox != null && hotelBox != null) {
      setState(() {
        topHotels = hotelBox!.values.toList();
        popularFoodItems = foodBox!.values.toList();
        _shuffleList(topHotels);
        _shuffleList(popularFoodItems);
      });
    }
  }

  void _shuffleList(List list) {
    final random = Random();
    for (int i = list.length - 1; i > 0; i--) {
      int n = random.nextInt(i + 1);
      var temp = list[i];
      list[i] = list[n];
      list[n] = temp;
    }
  }

  void _search(String query) {
    if (foodBox != null && hotelBox != null) {
      List<Food_db> foodItems = foodBox!.values.where((item) {
        return item.productTitle.toLowerCase().contains(query.toLowerCase()) ||
            item.productDesc.toLowerCase().contains(query.toLowerCase()) ||
            item.productMainCategory.toLowerCase().contains(query.toLowerCase());
      }).toList();

      List<Hotels_Db> hotelItems = hotelBox!.values.where((item) {
        return item.hotelName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      foodItems.sort((a, b) {
        if (a.productRating != b.productRating) {
          return b.productRating.compareTo(a.productRating);
        } else {
          return a.productOwnership.compareTo(b.productOwnership);
        }
      });

      setState(() {
        foodResults = foodItems;
        hotelResults = hotelItems;
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/fs_home');
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(Icons.tune, color: Colors.red),
              onPressed: () {},
            ),
          ],
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Restaurant Near By You...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Pizza',
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  _search(value);
                },
              ),
              SizedBox(height: 16),
              if (foodResults.isNotEmpty) ...[
                Text(
                  "Food Items",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: foodResults.length,
                  itemBuilder: (context, index) {
                    var item = foodResults[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/fs_product', arguments: {
                          'id': item.productId,
                          'title': item.productTitle,
                          'price': item.productPrice.toInt(),
                          'image': item.productImg,
                          'description': item.productDesc,
                          'shop': item.productOwnership,
                        });
                      },
                      child: FullSizedTile(
                        title: item.productTitle,
                        description: item.productDesc,
                        imageUrl: item.productImg,
                        category: item.productMainCategory,
                        location: item.productOwnership,
                        rating: item.productRating,
                      ),
                    );
                  },
                ),
              ],
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
                        Navigator.pushNamed(context, '/fs_hotel', arguments: {
                          'id': item.hotelId,
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
              SizedBox(height: 16),
              Column(
                children: topHotels.map((hotel) => RestaurantTile(name: hotel.hotelName, rating: 4.5)).toList(),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('View All', style: TextStyle(color: Colors.red)),
                ),
              ),
              SizedBox(height: 8),
              Text('Popular Restaurant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: PopularRestaurantTile(
                        name: 'European Pizza', subname: 'Uttora Coffee House'),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: PopularRestaurantTile(
                        name: 'Buffalo Pizza', subname: 'Cafenio Coffee Club'),
                  ),
                ],
              ),

            ],
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
      ),
    );
  }
}

class CustomChip extends StatelessWidget {
  final String label;
  final bool selected;

  CustomChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: selected ? Colors.red : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.red,
          fontWeight: FontWeight.bold,
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

  const FullSizedTile({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.location,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_pin, size: 16, color: Colors.red),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
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

class PopularRestaurantTile extends StatelessWidget {
  final String name;
  final String subname;

  PopularRestaurantTile({required this.name, required this.subname});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(fontSize: 16)),
          SizedBox(height: 4),
          Text(subname, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}


class RestaurantTile extends StatelessWidget {
  final String name;
  final double rating;

  RestaurantTile({required this.name, required this.rating});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/fs_hotel', arguments: {
          'id': name,
        });
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/hotel_prof.png'),
        ),
        title: Text(name),
        subtitle: Row(
          children: List.generate(
            5,
                (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: 18,
              color: Colors.yellow,
            ),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}