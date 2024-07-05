import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Hotels_Db.dart';

class FS_RestaurantScreen extends StatefulWidget {
  @override
  _FS_RestaurantScreenState createState() => _FS_RestaurantScreenState();
}

class _FS_RestaurantScreenState extends State<FS_RestaurantScreen> {
  Box<Food_db>? FDbox;
  Hotels_Db? hotelDetails;
  List<Food_db> hotelDishes = [];

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  Future<void> _openBoxes() async {
    FDbox = await Hive.openBox<Food_db>('foodDbBox');
    var hotelBox = await Hive.openBox<Hotels_Db>('hotelDbBox');

    // Retrieve arguments passed from the previous screen
    final Map<String, dynamic>? args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    var hotelID = args?['id']; // Access the 'id' argument

    hotelDetails =
        hotelBox.values.firstWhere((hotel) => hotel.hotelUsername == hotelID);

    if (hotelDetails != null) {
      hotelDishes = FDbox!.values
          .where((dish) => dish.productOwnership == hotelDetails!.hotelUsername)
          .toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Details'),
      ),
      body: hotelDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Logo
            Center(
              child: Image.asset(
                'assets/hotel_prof.png', // Replace with hotel logo path from hotelDetails
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            // Hotel Name
            Text(
              hotelDetails!.hotelName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Hotel Email
            Text(
              'Email: ${hotelDetails!.hotelMail}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            // Hotel Address
            Text(
              'Address: ${hotelDetails!.hotelAddress}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            // Hotel Phone Number
            Text(
              'Phone: ${hotelDetails!.hotelPhoneNo}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            // Hotel Username
            Text(
              'Username: ${hotelDetails!.hotelUsername}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            // Hotel Type
            Text(
              'Type: ${hotelDetails!.hotelType}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            // Homemade Tag if applicable
            if (hotelDetails!.hotelType == "homemade")
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Chip(
                  label: Text('Homemade'),
                  backgroundColor: Colors.green,
                ),
              ),
            SizedBox(height: 16),
            // List of Dishes
            Text(
              'Dishes Available:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: hotelDishes.length,
              itemBuilder: (context, index) {
                var dish = hotelDishes[index];
                return ListTile(
                  leading: Image.asset(
                    dish.productImg,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(dish.productTitle),
                  subtitle: Text('₹ ${dish.productPrice}'),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // Add dish to cart or perform other actions
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
