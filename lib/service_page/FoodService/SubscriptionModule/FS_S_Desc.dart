import 'package:flutter/material.dart';

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String desc;
  final String restaurant;
  final double rating;

  MenuItem({
    required this.name,
    required this.restaurant,
    required this.price,
    required this.image,
    required this.id,
    required this.desc,
    required this.rating,
  });
}

class FS_S_Desc extends StatefulWidget {
  @override
  _FS_S_DescState createState() => _FS_S_DescState();
}

class _FS_S_DescState extends State<FS_S_Desc> {
  String selectedOption = 'weekly';
  List<MenuItem> morningItems = [
    MenuItem(
      id: '1',
      name: 'Pancakes',
      price: 150,
      image: 'assets/foods/cake.jpg',
      desc: 'Delicious pancakes with syrup',
      restaurant: 'Restaurant A',
      rating: 4.5,
    ),
    MenuItem(
      id: '2',
      name: 'Omelette',
      price: 120,
      image: 'assets/foods/pizza.jpg',
      desc: 'Healthy vegetable omelette',
      restaurant: 'Restaurant B',
      rating: 4.0,
    ),
  ];
  List<MenuItem> lunchItems = [
    MenuItem(
      id: '3',
      name: 'Chicken Salad',
      price: 200,
      image: 'assets/foods/salad.jpg',
      desc: 'Fresh chicken salad',
      restaurant: 'Restaurant C',
      rating: 4.2,
    ),
    MenuItem(
      id: '4',
      name: 'Grilled Sandwich',
      price: 180,
      image: 'assets/foods/chicken_curry.jpg',
      desc: 'Tasty grilled sandwich',
      restaurant: 'Restaurant D',
      rating: 4.8,
    ),
  ];

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
              Text(
                'Lunch Items',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              GridView.builder(
                itemCount: lunchItems.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  childAspectRatio: 0.9, // Adjust to fit item height
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final item = lunchItems[index];
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
                image: AssetImage(item.image),
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
