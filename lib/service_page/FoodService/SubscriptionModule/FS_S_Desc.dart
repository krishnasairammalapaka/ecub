import 'package:ecub_s1_v2/translation.dart';
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
              selected: shouldPreSelect(foodData['id']),
            );

            categorizedFoodItems[category]?.add(menuItem);
          }
        }
      }
    }
    return categorizedFoodItems;
  }

  void _onCheckoutPressed(String packID) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var userMail = args['userMail'];

    // Separate selected food items by category
    List<MenuItem> selectedFoodItems =
        selectedItemsNotifier.value.where((item) => item.selected).toList();

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

    if (selectedFoodItems.isEmpty) {
      print('No food items selected');
    } else {
      // Debugging: Print selected food IDs
      print('Breakfast: $breakfastSelected');
      print('Lunch: $lunchSelected');
      print('Snacks: $snacksSelected');
      print('Dinner: $dinnerSelected');
    }

    Navigator.pushNamed(
      context,
      '/fs_s_checkout',
      arguments: {
        'packID': packID,
        'subscription_type': selectedOption,
        'breakfastSelected': breakfastSelected,
        'lunchSelected': lunchSelected,
        'snacksSelected': snacksSelected,
        'dinnerSelected': dinnerSelected,
      },
    );
  }

  void _onSelectItem(MenuItem item) {
    item.selected = !item.selected;
    if (item.selected) {
      selectedItemsNotifier.value = List.from(selectedItemsNotifier.value)
        ..add(item);
    } else {
      selectedItemsNotifier.value = List.from(selectedItemsNotifier.value)
        ..removeWhere((i) => i.id == item.id);
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
        title: FutureBuilder<String>(
          future: Translate.translateText("Food Pack"),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Transform.scale(
                scale: 0.4,
                child: CircularProgressIndicator(),
              );
            } else {
              return snapshot.hasData
                  ? Text(snapshot.data!)
                  : Text("Food Pack");
            }
          },
        ),
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
                  return Center(
                      child: FutureBuilder<String>(
                    future: Translate.translateText("No data found"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Transform.scale(
                          scale: 0.4,
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return snapshot.hasData
                            ? Text(snapshot.data!)
                            : Text("No Data Found");
                      }
                    },
                  ));
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
                        return Center(
                            child: FutureBuilder<String>(
                          future: Translate.translateText("No items found"),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Transform.scale(
                                scale: 0.4,
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return snapshot.hasData
                                  ? Text(snapshot.data!)
                                  : Text("No items Found");
                            }
                          },
                        ));
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0D5EF9),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              textStyle: TextStyle(fontSize: 20),
            ),
            child: FutureBuilder<String>(
              future: Translate.translateText("Checkout"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Transform.scale(
                    scale: 0.4,
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return snapshot.hasData
                      ? Text(snapshot.data!)
                      : Text("CheckOut");
                }
              },
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
    if (items.isEmpty) {
      return SizedBox.shrink(); // Do not display anything if the list is empty
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<String>(
          future: Translate.translateText(title),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Transform.scale(
                scale: 0.4,
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              return Text(
                snapshot.data!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          },
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
    final veg = item.isVeg ? 'Veg' : 'Non-Veg';
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
            FutureBuilder<String>(
              future: Translate.translateText(item.name),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Transform.scale(
                    scale: 0.4,
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                  );
                } else {
                  return Text(
                    item.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                  );
                }
              },
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
                FutureBuilder<String>(
                  future: Translate.translateText(veg),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Transform.scale(
                        scale: 0.4,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: item.isVeg ? Colors.green : Colors.red,
                            overflow: TextOverflow.ellipsis),
                      );
                    } else {
                      return Text(
                        veg,
                        style: TextStyle(
                            fontSize: 14,
                            color: item.isVeg ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
