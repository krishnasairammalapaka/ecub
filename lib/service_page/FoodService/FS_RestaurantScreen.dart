import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ecub_s1_v2/models/Hotels_Db.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';

class FS_RestaurantScreen extends StatefulWidget {
  @override
  _FS_RestaurantScreenState createState() => _FS_RestaurantScreenState();
}

class _FS_RestaurantScreenState extends State<FS_RestaurantScreen> {
  Box<Food_db>? FDbox;
  Box<Hotels_Db>? hotelBox;
  String hotelName = '';
  String hotelMail = '';
  String hotelAddress = '';
  String hotelUsername = '';
  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  Future<void> _openBoxes() async {
    hotelBox = await Hive.openBox<Hotels_Db>('hotelDbBox');
    FDbox = await Hive.openBox<Food_db>('foodDbBox');
    _fetchHotelInfo();
  }

  void _fetchHotelInfo() {
    final args = ModalRoute.of(context)?.settings.arguments as Map;
    final hotelusername = args['username'];
    final hotelList = hotelBox?.values.toList();

    if (hotelList != null) {
      for (var hotel in hotelList) {
        if (hotel.hotelUsername == hotelusername) {
          setState(() {
            hotelName = hotel.hotelName;
            hotelMail = hotel.hotelMail;
            hotelAddress = hotel.hotelAddress;
            hotelUsername = hotel.hotelUsername;
          });

          _fetchFoodItems();
          break;
        }
      }
    }
  }


  void _fetchFoodItems() {
    final allFoodItems = FDbox?.values.where((item) => item.productOwnership == hotelUsername).toList();

    if (allFoodItems != null) {
      setState(() {
        foodItems = allFoodItems.map((item) => {
          'name': item.productTitle,
          'restaurant': item.productOwnership,
          'price': item.productPrice,
          'image': item.productImg
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Restaurant View'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.red),
            onPressed: () {
              // Add your favorite button action here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage('assets/hotel.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                hotelName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                hotelMail,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                hotelAddress,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.red),
                  SizedBox(width: 4),
                  Text('4.7'),
                  SizedBox(width: 16),
                  Icon(Icons.delivery_dining, color: Colors.red),
                  SizedBox(width: 4),
                  Text('Free'),
                  SizedBox(width: 16),
                  Icon(Icons.access_time, color: Colors.red),
                  SizedBox(width: 4),
                  Text('20 min'),
                ],
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: foodItems.map((item) => MenuItem(
                  name: item['name'],
                  restaurant: item['restaurant'],
                  price: item['price'],
                  image: item['image'],
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class CategoryTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  CategoryTab({required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.red : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? null : Border.all(color: Colors.red),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.red,
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String name;
  final String restaurant;
  final double price;
  final String image;

  MenuItem({required this.name, required this.restaurant, required this.price, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Text(restaurant),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹$price',
          style: TextStyle(
            color: Colors.red,
            fontSize: 15
          ),
    ),

            ],
          ),
        ],
      ),
    );
  }
}
