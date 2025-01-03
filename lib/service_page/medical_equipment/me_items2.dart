// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_item_desc.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_item_details.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:badges/badges.dart' as badges;

class MeItems2 extends StatefulWidget {
  final String categoryName;

  const MeItems2({super.key, required this.categoryName});

  @override
  State<MeItems2> createState() => _MeItems2State();
}

class _MeItems2State extends State<MeItems2> {
  List<String> itemKeys = [];
  List<String> Imagelt = [];

  @override
  void initState() {
    super.initState();
    fetchItemKeys();
  }

  Stream<int> fetchCartItemCount() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      // Return a stream of document snapshots from Firestore
      return FirebaseFirestore.instance
          .collection('me_cart')
          .doc(user.email)
          .collection('items')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.length); // Map the snapshots to their count
    } else {
      // Return a stream of 0 if the user is not logged in
      return Stream.value(0);
    }
  }

  List<String> products = [
    "Finger Pulse Oximeter",
    "Nebulizer",
    "Steamer",
    "Suction Machine",
    "Spirometer",
    "Oxygen Concentrator",
    "Walking Stick",
    "Walker",
    "Elbow Crutch",
    "Under Crutch",
    "Rollator",
    "Attendant Wheelchair",
    "Self-Driven Wheelchair",
    "Reclining Wheelchair",
    "Motorized Wheelchair",
    "Transit Wheelchair"
  ];

  Map<String, String> categories = {
    "Finger Pulse Oximeter": "Respiratory",
    "Nebulizer": "Respiratory",
    "Steamer": "Respiratory",
    "Suction Machine": "Respiratory",
    "Spirometer": "Respiratory",
    "Oxygen Concentrator": "Respiratory",
    "Walking Stick": "Walking Aids",
    "Walker": "Walking Aids",
    "Elbow Crutch": "Walking Aids",
    "Under Crutch": "Walking Aids",
    "Rollator": "Walking Aids",
    "Attendant Wheelchair": "Wheel Chair",
    "Self-Driven Wheelchair": "Wheel Chair",
    "Reclining Wheelchair": "Wheel Chair",
    "Motorized Wheelchair": "Wheel Chair",
    "Transit Wheelchair": "Wheel Chair"
  };

  void registerClick(String itemName) async {
    var box = await Hive.openBox('clickData');
    // if box is empty set values

    if (box.length < 3) {
      int index = products.indexOf(itemName);
      box.add(index + 1);
    } else {
      box.deleteAt(0);
      int index = products.indexOf(itemName);
      box.add(index + 1);
    }
    // print the box values enclosed in []
    print([box.values.toList()]);
  }

  void fetchItemKeys() async {
    // Fetch documents from the subcollection
    var querySnapshot = await FirebaseFirestore.instance
        .collection('medical_eqipment_categories')
        .get();
    List<String> tempKeys = [];
    List<String> images = [];
    for (var doc in querySnapshot.docs) {
      if (doc.data()['name'] == widget.categoryName) {
        Map<String, dynamic> items = doc.data()['items'] ?? {};
        items.forEach((key, value) {
          tempKeys.add(key);
          images.add(value);
        });
      }
    }
    tempKeys = tempKeys.toSet().toList();
    images = images.toList();

    setState(() {
      Imagelt = images;
      itemKeys = tempKeys;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: Translate.translateText(widget.categoryName),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Text(
                    snapshot.data!,
                  )
                : Text(widget.categoryName);
          },
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: StreamBuilder<int>(
                stream: fetchCartItemCount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    return badges.Badge(
                      badgeContent: Text(
                        snapshot.data.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.shopping_cart),
                        onPressed: () {
                          Navigator.pushNamed(context, '/me_cart');
                        },
                      ),
                    );
                  } else {
                    return IconButton(
                      icon: Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.pushNamed(context, '/me_cart');
                      },
                    );
                  }
                },
              )),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: itemKeys.length, // Number of items in the list
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
          crossAxisSpacing: 10, // Horizontal space between items
          mainAxisSpacing: 10, // Vertical space between items
          childAspectRatio: 0.8, // Aspect ratio of each item
        ),
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            elevation: 5,
            margin: const EdgeInsets.all(5),
            child: InkWell(
              onTap: () async {
                // Navigate to the item details page
                registerClick(itemKeys[index]);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => MeItemDetails(
                //       itemName: itemKeys[index],
                //       itemImage: Imagelt[index],
                //       categoryName: widget.categoryName,
                //     ),
                //   ),
                // );
                // show store_list
                await store_list(context, widget.categoryName, itemKeys[index],
                    Imagelt[index]);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            Imagelt[index], // Image URL
                            fit: BoxFit
                                .cover, // Cover the entire space of the container
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder<String>(
                      future: Translate.translateText(itemKeys[index]),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? Text(
                                snapshot.data!, // Item name
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              )
                            : Text(
                                itemKeys[index], // Item name
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _currentSortOption = 'Prize';
  Future<dynamic> store_list(BuildContext context, String categoryName,
      String itemName, String itemImage) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            DropdownButton<String>(
              value: _currentSortOption,
              onChanged: (String? newValue) {
                setState(() {
                  _currentSortOption = newValue!;
                });
                Navigator.pop(context);
                store_list(context, categoryName, itemName, itemImage);
              },
              items: <String>['Rating', 'Name', 'Prize']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('medical_eqipment_categories1')
                    .doc(categoryName)
                    .collection('data')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    var stores = snapshot.data!.docs.map((doc) {
                      return Stores(
                        name: doc['Name'],
                        address: doc['Address'],
                        rating: doc['Rating'],
                        prize: doc['prize'],
                        rent: doc['rent'],
                      );
                    }).toList();
                    switch (_currentSortOption) {
                      case 'Name':
                        stores.sort((a, b) => a.name.compareTo(b.name));
                        break;
                      case 'Rating':
                        stores.sort((a, b) {
                          int compareRating = b.rating.compareTo(a.rating);
                          if (compareRating == 0) {
                            return a.prize.compareTo(b.prize);
                          }
                          return compareRating;
                        });
                        break;
                      case 'Prize':
                        stores.sort((a, b) => a.prize.compareTo(b.prize));
                        break;
                    }

                    return ListView.builder(
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: InkWell(
                              onTap: () {
                                // addItemToCart(
                                //   widget.itemName,
                                //   stores[index]!.name,
                                //   stores[index]!.address,
                                //   stores[index]!.rating.toString(),
                                //   widget.itemImage,
                                // );
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MeItemDesc(
                                      storeName: stores[index].name,
                                      categoryName: categoryName,
                                      itemName: itemName,
                                      imageUrl: itemImage,
                                      price: stores[index].prize.toString(),
                                      storeAddress: stores[index].address,
                                      rent: stores[index].rent,
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: Icon(Icons.store, color: Colors.red),
                                title: FutureBuilder<String>(
                                  future: Translate.translateText(
                                      stores[index].name),
                                  builder: (context, snapshot) {
                                    return snapshot.hasData
                                        ? Text(
                                            snapshot.data!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : Text(
                                            stores[index].name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                  },
                                ),
                                subtitle: FutureBuilder<String>(
                                  future: Translate.translateText(
                                      stores[index].address),
                                  builder: (context, snapshot) {
                                    return snapshot.hasData
                                        ? Text(
                                            snapshot.data!,
                                          )
                                        : Text(stores[index].address);
                                  },
                                ),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${stores[index].rating}⭐",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Price: ₹${stores[index].prize}",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Rent: ${stores[index].rent}",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
