import 'package:firebase_auth/firebase_auth.dart';
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

class FS_S_PackChange extends StatefulWidget {
  @override
  _FS_S_PackChangeState createState() => _FS_S_PackChangeState();
}

class _FS_S_PackChangeState extends State<FS_S_PackChange> {
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

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchPack(
      String packID) async {
    return await FirebaseFirestore.instance
        .collection('fs_packs')
        .doc(packID)
        .get();
  }

  Future<Map<String, List<MenuItem>>> fetchFoodItems(String packID) async {
    Map<String, List<MenuItem>> categorizedFoodItems = {
      'breakfast': [],
      'lunch': [],
      'snack': [],
      'dinner': [],
    };

    for (String category in categorizedFoodItems.keys) {
      DocumentSnapshot<Map<String, dynamic>> categoryDoc =
      await FirebaseFirestore.instance
          .collection('fs_packs')
          .doc(packID)
          .collection('pack_foods')
          .doc(category)
          .get();
      if (categoryDoc.exists) {
        List<String> foodIds = List<String>.from(categoryDoc.data()!['food']);
        for (String foodId in foodIds) {
          DocumentSnapshot<Map<String, dynamic>> foodDoc =
          await FirebaseFirestore.instance
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
              foodAvailTime: category,
              // use the category directly
              isVeg: foodData['isVeg'],
              selected: await shouldPreSelect(foodData['id']),
            );

            categorizedFoodItems[category]?.add(menuItem);
          }
        }
      }
    }
    return categorizedFoodItems;
  }

  Future<void> _onCheckoutPressed(String packID) async {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Separate selected food items by category
    List<MenuItem> selectedFoodItems = selectedItemsNotifier.value.where((item) => item.selected).toList();

    List<String> breakfastSelected = selectedFoodItems
        .where((item) => item.foodAvailTime == 'breakfast')
        .map((item) => item.id)
        .toList();

    List<String> lunchSelected = selectedFoodItems
        .where((item) => item.foodAvailTime == 'lunch')
        .map((item) => item.id)
        .toList();

    List<String> snacksSelected = selectedFoodItems
        .where((item) => item.foodAvailTime == 'snack')
        .map((item) => item.id)
        .toList();

    List<String> dinnerSelected = selectedFoodItems
        .where((item) => item.foodAvailTime == 'dinner')
        .map((item) => item.id)
        .toList();

    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      throw Exception('User is not authenticated');
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('fs_service')
        .doc('packs')
        .get();

    // Retrieve each list of food IDs from Firestore
    List<dynamic> breakfastIds = snapshot.data()?['breakfastSelected'] as List<dynamic>? ?? [];
    List<dynamic> lunchIds = snapshot.data()?['lunchSelected'] as List<dynamic>? ?? [];
    List<dynamic> snacksIds = snapshot.data()?['snacksSelected'] as List<dynamic>? ?? [];
    List<dynamic> dinnerIds = snapshot.data()?['dinnerSelected'] as List<dynamic>? ?? [];

    // Append the newly selected IDs to the existing IDs
    breakfastIds.addAll(breakfastSelected);
    lunchIds.addAll(lunchSelected);
    snacksIds.addAll(snacksSelected);
    dinnerIds.addAll(dinnerSelected);

    // Debugging: Print the updated food IDs
    print('Updated Breakfast IDs: $breakfastIds');
    print('Updated Lunch IDs: $lunchIds');
    print('Updated Snacks IDs: $snacksIds');
    print('Updated Dinner IDs: $dinnerIds');

    // Debugging: Print the updated food IDs
    print('Updated Breakfast IDs: $breakfastSelected');
    print('Updated Lunch IDs: $lunchSelected');
    print('Updated Snacks IDs: $snacksSelected');
    print('Updated Dinner IDs: $dinnerSelected');


    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore
        .collection('users')
        .doc(userEmail)
        .collection('fs_service')
        .doc('packs');

    final cartCollectionRef = firestore
        .collection('fs_cart')
        .doc(userEmail)
        .collection('packs')
        .doc('info');

    // Update Firestore with the appended lists
    await collectionRef.update({
      'breakfastSelected': breakfastSelected,
      'lunchSelected': lunchSelected,
      'snacksSelected': snacksSelected,
      'dinnerSelected': dinnerSelected,
    });

    // await cartCollectionRef.update({
    //   'breakfastSelected': breakfastIds,
    //   'lunchSelected': lunchIds,
    //   'snacksSelected': snacksIds,
    //   'dinnerSelected': dinnerIds,
    // });

    await cartCollectionRef.update({
      'breakfastSelected': breakfastSelected,
      'lunchSelected': lunchSelected,
      'snacksSelected': snacksSelected,
      'dinnerSelected': dinnerSelected,
    });

    Navigator.pushNamed(context, '/fs_profile');
  }





  void _onSelectItem(MenuItem item) {
    item.selected = !item.selected;
    if (item.selected) {
      selectedItemsNotifier.value = List.from(selectedItemsNotifier.value)..add(item);
    } else {
      selectedItemsNotifier.value = List.from(selectedItemsNotifier.value)..removeWhere((i) => i.id == item.id);
    }
    selectedItemsNotifier.notifyListeners();
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
                  return FutureBuilder<Map<String, List<MenuItem>>>(
                    future: fetchFoodItems(packID),
                    builder: (context, foodSnapshot) {
                      if (foodSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (foodSnapshot.hasError) {
                        return Center(
                            child: Text('Error2: ${foodSnapshot.error}'));
                      } else if (!foodSnapshot.hasData ||
                          foodSnapshot.data!.isEmpty) {
                        return Center(child: Text('No food items found'));
                      } else {
                        Map<String, List<MenuItem>> categorizedFoodItems =
                        foodSnapshot.data!;
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                buildCategorySection('Breakfast',
                                    categorizedFoodItems['breakfast']!),
                                buildCategorySection(
                                    'Lunch', categorizedFoodItems['lunch']!),
                                buildCategorySection(
                                    'Snacks', categorizedFoodItems['snack']!),
                                buildCategorySection(
                                    'Dinner', categorizedFoodItems['dinner']!),
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
            child: Text('Update'),
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


  Future<List<dynamic>> fetchFoodIds() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userEmail == null) {
        throw Exception('User is not authenticated');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('fs_service')
          .doc('packs')
          .get();

      // Retrieve each list of food IDs and combine them
      List<dynamic> breakfastIds = snapshot.data()?['breakfastSelected'] as List<dynamic>? ?? [];
      List<dynamic> lunchIds = snapshot.data()?['lunchSelected'] as List<dynamic>? ?? [];
      List<dynamic> snacksIds = snapshot.data()?['snacksSelected'] as List<dynamic>? ?? [];
      List<dynamic> dinnerIds = snapshot.data()?['dinnerSelected'] as List<dynamic>? ?? [];

      // Combine all lists into one
      List<dynamic> allFoodIds = [
        ...breakfastIds,
        ...lunchIds,
        ...snacksIds,
        ...dinnerIds,
      ];


      return allFoodIds;
    } catch (e) {
      // Handle errors (e.g., network issues)
      print('Error fetching food IDs: $e');
      return [];
    }
  }


  Future<bool> shouldPreSelect(String foodId) async {
    try {
      List<dynamic> allFoodIds = await fetchFoodIds();
      return allFoodIds.contains(foodId);
    } catch (e) {
      print('Error checking food ID selection: $e');
      return false;
    }
  }


  Widget buildCategorySection(String title, List<MenuItem> items) {
    if (items.isEmpty) {
      return SizedBox.shrink(); // Do not display anything if the list is empty
    }

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
          color:
          item.selected ? Color(0xFF0D5EF9).withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: item.selected ? Color(0xFF0D5EF9) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              item.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 4),
            Row(
              children: [

                Text(
                  '₹ ${item.price} ',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  item.isVeg ? Icons.verified : Icons.verified,
                  color: item.isVeg ? Colors.green : Colors.red,
                  size: 15,
                ),
                SizedBox(width: 4),
                Text(
                  item.isVeg ? 'Veg' : 'Non-Veg',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

