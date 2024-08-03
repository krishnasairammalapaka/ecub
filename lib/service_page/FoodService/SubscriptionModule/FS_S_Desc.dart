import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final int price;
  final String image;
  final String desc;
  final String restaurant;
  final double rating;
  final String foodAvailTime;
  final bool isVeg;
  bool selected;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.desc,
    required this.restaurant,
    required this.rating,
    required this.foodAvailTime,
    required this.isVeg,
    this.selected = false,
  });

  @override
  String toString() {
    return 'MenuItem{id: $id, name: $name, price: $price, selected: $selected}';
  }
}

class FS_S_Desc extends StatefulWidget {
  @override
  _FS_S_DescState createState() => _FS_S_DescState();
}

class _FS_S_DescState extends State<FS_S_Desc> {
  Future<DocumentSnapshot<Map<String, dynamic>>>? futurePack;
  String selectedOption = 'Weekly';
  ValueNotifier<List<MenuItem>> selectedItemsNotifier = ValueNotifier([]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var packID = args['id'];
    futurePack = fetchPack(packID);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchPack(String packID) async {
    return await FirebaseFirestore.instance
        .collection('fs_packs')
        .doc(packID)
        .get();
  }

  Future<Map<String, List<MenuItem>>> fetchFoodItems(List<String> foodIds) async {
    Map<String, List<MenuItem>> categorizedFoodItems = {
      'breakfast': [],
      'lunch': [],
      'snack': [],
      'dinner': [],
    };

    for (String foodId in foodIds) {
      DocumentSnapshot<Map<String, dynamic>> foodDoc = await FirebaseFirestore.instance
          .collection('fs_food_items')
          .doc(foodId)
          .get();
      if (foodDoc.exists) {
        var foodData = foodDoc.data()!;
        foodData['id'] = foodDoc.id;
        MenuItem menuItem = MenuItem(
          id: foodData['id'],
          name: foodData['productTitle'],
          price: foodData['productPrice'],
          image: foodData['productImg'],
          desc: foodData['productDesc'],
          restaurant: foodData['productOwnership'],
          rating: foodData['productRating'],
          foodAvailTime: foodData['foodAvailTime'],
          isVeg: foodData['isVeg'],
          selected: shouldPreSelect(foodData['id']),
        );

        categorizedFoodItems[foodData['foodAvailTime']]?.add(menuItem);
      }
    }
    return categorizedFoodItems;
  }

  void _onCheckoutPressed(String packID) {
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var userMail = args['userMail'];

    Set<MenuItem> uniqueSelectedFoodItems = selectedItemsNotifier.value
        .where((item) => item.selected)
        .toSet();

    Set<String> uniqueSelectedFoodIds = uniqueSelectedFoodItems
        .map((item) => item.id)
        .toSet();

    // Convert sets back to lists
    List<MenuItem> selectedFoodItems = uniqueSelectedFoodItems.toList();
    List<String> selectedFoodIds = uniqueSelectedFoodIds.toList();

    // Debugging: Print selected food IDs
    print('Selected Food: $selectedFoodItems');
    print('Selected Food IDs: $selectedFoodIds');

    Navigator.pushNamed(
      context,
      '/fs_s_checkout',
      arguments: {
        'packID': packID,
        'subscription_type': selectedOption,
        'selectedFoodItems': selectedFoodItems,
        'selectedFoodIds': selectedFoodIds,
      },
    );
  }

  void _onSelectItem(MenuItem item) {
    setState(() {
      item.selected = !item.selected;
    });
    selectedItemsNotifier.value = List.from(selectedItemsNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var packID = args['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Food Pack'),
        backgroundColor: Color(0xFF0D5EF9),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: futurePack,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error1: ${snapshot.error}'));
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('No data found'));
                } else {
                  Map<String, dynamic> data = snapshot.data!.data()!;
                  List<String> foodIds = List<String>.from(data['pack_foods']);

                  return FutureBuilder<Map<String, List<MenuItem>>>(
                    future: fetchFoodItems(foodIds),
                    builder: (context, foodSnapshot) {
                      if (foodSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (foodSnapshot.hasError) {
                        return Center(child: Text('Error2: ${foodSnapshot.error}'));
                      } else if (!foodSnapshot.hasData || foodSnapshot.data!.isEmpty) {
                        return Center(child: Text('No food items found'));
                      } else {
                        Map<String, List<MenuItem>> categorizedFoodItems = foodSnapshot.data!;
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                buildCategorySection('Breakfast', categorizedFoodItems['breakfast']!),
                                buildCategorySection('Lunch', categorizedFoodItems['lunch']!),
                                buildCategorySection('Snacks', categorizedFoodItems['snack']!),
                                buildCategorySection('Dinner', categorizedFoodItems['dinner']!),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
          DropdownButton<String>(
            value: selectedOption,
            onChanged: (String? newValue) {
              setState(() {
                selectedOption = newValue!;
              });
            },
            items: <String>['Weekly', 'Monthly', 'Customized Dates']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () => _onCheckoutPressed(packID),
            child: Text('Checkout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0D5EF9),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              textStyle: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  bool shouldPreSelect(String foodId) {
    List<String> preSelectedFoodIds = ['foodId1', 'foodId2', 'foodId3'];
    return preSelectedFoodIds.contains(foodId);
  }

  Widget buildCategorySection(String title, List<MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ValueListenableBuilder<List<MenuItem>>(
          valueListenable: selectedItemsNotifier,
          builder: (context, selectedItems, _) {
            return GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                MenuItem item = items[index];
                return MenuItemWidget(
                  item: item,
                  onSelect: () => _onSelectItem(item),
                );
              },
            );
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onSelect;

  MenuItemWidget({required this.item, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: item.selected
              ? Colors.lightBlueAccent.withOpacity(0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (item.selected)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 7),
            Text(
              item.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text(
                  item.isVeg ? 'Vegetarian' : 'Non-Vegetarian',
                  style: TextStyle(
                    color: item.isVeg ? Colors.green : Colors.red,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '₹${item.price}',
                  style: TextStyle(
                    color: Color(0xFF0D5EF9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.centerRight,
              child: item.selected
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Icon(Icons.radio_button_unchecked, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
