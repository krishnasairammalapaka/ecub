import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String desc;
  final String restaurant;
  final double rating;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.desc,
    required this.restaurant,
    required this.rating,
  });
}

class FS_S_Desc extends StatefulWidget {
  @override
  _FS_S_DescState createState() => _FS_S_DescState();
}

class _FS_S_DescState extends State<FS_S_Desc> {
  String selectedOption = 'weekly';
  List<MenuItem> morningItems = [];

  @override
  void initState() {
    super.initState();
    // Fetch data from Firestore when widget initializes
    fetchPackFoods();
  }

  void fetchPackFoods() async {
    // Access pack_id passed as argument
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final String packId = args['id'];

    // Fetch pack_foods from Firestore
    CollectionReference packsCollection =
    FirebaseFirestore.instance.collection('fs_pack');

    // Assuming pack_foods is an array field in fs_pack containing food item IDs
    DocumentSnapshot packSnapshot = await packsCollection.doc(packId).get();
    List<String> foodIds = List<String>.from(packSnapshot.get('pack_foods'));

    // Fetch each food item from Firestore and update morningItems list
    List<MenuItem> items = [];
    for (String foodId in foodIds) {
      DocumentSnapshot foodSnapshot =
      await FirebaseFirestore.instance.collection('food').doc(foodId).get();
      if (foodSnapshot.exists) {
        MenuItem item = MenuItem(
          id: foodSnapshot.id,
          name: foodSnapshot.get('name'),
          price: foodSnapshot.get('price').toDouble(),
          image: foodSnapshot.get('image'),
          desc: foodSnapshot.get('desc'),
          restaurant: foodSnapshot.get('restaurant'),
          rating: foodSnapshot.get('rating').toDouble(),
        );
        items.add(item);
      }
    }

    setState(() {
      morningItems = items;
    });
  }

  void _onCheckoutPressed() {
    if (selectedOption == 'customized dates') {
      Navigator.pushNamed(context, '/fs_s_cal');
    } else {
      Navigator.pushNamed(context, '/fs_s_checkout');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Subscription'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Morning Items',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              GridView.builder(
                itemCount: morningItems.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  childAspectRatio: 0.9, // Adjust to fit item height
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final item = morningItems[index];
                  return MenuItemWidget(item: item);
                },
              ),
              SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOption = newValue!;
                  });
                },
                items: <String>['weekly', 'monthly', 'customized dates']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onCheckoutPressed,
                child: Text('Checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final MenuItem item;

  MenuItemWidget({required this.item});

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
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.image), // Assuming image is a URL
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${item.price}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                      (index) => Icon(
                    index < item.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
