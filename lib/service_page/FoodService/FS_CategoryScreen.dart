import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ecub_s1_v2/models/Hotels_Db.dart';

class FS_CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments passed to this screen
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String type = arguments['type'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D5EF9),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                future: _getFilteredHotels(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                    return Center(child: Text('No hotels found.'));
                  } else {
                    final hotels = snapshot.data as List<Hotels_Db>;
                    return ListView.builder(
                      itemCount: hotels.length,
                      itemBuilder: (context, index) {
                        final hotel = hotels[index];
                        return RestaurantCard(
                          name: hotel.hotelName,
                          location: hotel.hotelAddress,
                          rating: 4.5, // Assuming rating is constant, replace with actual data if available
                          deliveryTime: hotel.hotelPhoneNo, // Assuming delivery time is constant, replace with actual data if available
                          imageUrl: 'assets/hotel.png', // Replace with actual image URL if available
                          Username: hotel.hotelUsername,
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

  Future<List<Hotels_Db>> _getFilteredHotels(String type) async {
    final hotelBox = await Hive.openBox<Hotels_Db>('hotelDbBox');
    return hotelBox.values.where((hotel) => hotel.hotelType == type).toList();
  }
}

class RestaurantCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String deliveryTime;
  final String imageUrl;
  final String Username;

  RestaurantCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.deliveryTime,
    required this.imageUrl,
    required this.Username,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/fs_hotel', arguments: {
          'id': 1,
          'username':Username,
          'name': name,
        });
      },
      child: Card(
        child: ListTile(
          leading: Image.asset('assets/hotel_prof.png', width: 50, height: 50),
          title: Text(name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow[700]),
                  SizedBox(width: 5),
                  Text('$rating'),
                  SizedBox(width: 10),
                  Icon(Icons.phone, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(deliveryTime),
                ],
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}


