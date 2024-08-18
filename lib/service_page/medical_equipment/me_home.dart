import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_item_details.dart';
// import 'package:ecub_s1_v2/service_page/medical_equipment/me_items.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_items2.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:hive_flutter/adapters.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:ecub_s1_v2/translation.dart';

class Category {
  final String name;
  final String image;

  Category({required this.name, required this.image});
}

class MeHomePage extends StatefulWidget {
  MeHomePage({super.key});

  @override
  State<MeHomePage> createState() => _MeHomePageState();
}

class _MeHomePageState extends State<MeHomePage> {
  List<int> values = [];
  List<String> itemKeys = [];
  List<String> Imagelt = [];
  List<String> Imagelt2 = [];
  List<String> productNames = [];
  List<String> categoryNames = [];
  List<String> desc = [];

  @override
  void initState() {
    super.initState();
    predict(getClick());
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

  void fetchItemKeys() async {
    // Fetch documents from the subcollection
    var querySnapshot = await FirebaseFirestore.instance
        .collection('medical_eqipment_categories')
        .get();
    List<String> tempKeys = [];
    List<String> images = [];
    for (var doc in querySnapshot.docs) {
      // if (doc.data()['name'] == widget.categoryName) {
      Map<String, dynamic> items = doc.data()['items'] ?? {};
      items.forEach((key, value) {
        tempKeys.add(key);
        print(value);
        images.add(value);
      });
      // }
    }
    tempKeys = tempKeys.toSet().toList();
    images = images.toList();

    setState(() {
      Imagelt = images;
      itemKeys = tempKeys;
    });

    //get product names from values
    List<String> productNames = [];
    for (int i = 0; i < values.length; i++) {
      productNames.add(products[values[i]]);
    }

    //get category names from product names
    List<String> categoryNames = [];
    for (int i = 0; i < productNames.length; i++) {
      categoryNames.add(categories[productNames[i]]!);
    }

    setState(() {
      this.productNames = productNames;
      this.categoryNames = categoryNames;
    });

    List<String> Imagelt2 = [];
    for (int i = 0; i < productNames.length; i++) {
      for (int j = 0; j < itemKeys.length; j++) {
        if (itemKeys[j] == productNames[i]) {
          Imagelt2.add(Imagelt[j]);
        }
      }
    }

    setState(() {
      this.Imagelt2 = Imagelt2;
    });
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

  getClick() async {
    var box = await Hive.openBox('clickData');
    if (box.isEmpty) {
      box.add(0);
      box.add(0);
      box.add(0);
    }
    return ([box.values.toList()]);
  }

  predict(Future<dynamic> input) async {
    try {
      final interpreter =
          await Interpreter.fromAsset('assets/ml_models/model.tflite');
      interpreter.allocateTensors();
      final List<dynamic> inputList = [await input];
      var output = List.filled(3 * 16, 0).reshape([3, 16]);
      interpreter.run(inputList, output);
      // print(output);
      // list for getting valutes that are >0.5
      List<int> values = [];
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 16; j++) {
          if (output[i][j] > 0.5) {
            if (!values.contains(j)) {
              values.add(j);
            }
          }
        }
      }
      // print(values);
      setState(() {
        this.values = values;
      });
      fetchItemKeys();
    } on Exception catch (e) {
      print('Failed to load model. $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: Translate.translateText('Medical Equipment '),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Text(snapshot.data!)
                : Text('Medical Equipment ');
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
      body: Column(
        children: [
          // future_carouselSlider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FutureBuilder<String>(
                  future: Translate.translateText(
                      "Quality Instruments.\nTrusted Care."),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? Text(
                            snapshot.data!,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            "Quality Instruments.\nTrusted Care.",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                  },
                ),
              ],
            ),
          ),
          // const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/me_ad.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<String>(
                future: Translate.translateText("Available categories"),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Text(
                          snapshot.data!,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          'Available categories',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        );
                },
              )),
          future_grid_layout(),
          const SizedBox(height: 10),
          FutureBuilder<String>(
            future: Translate.translateText("Recommended Produts"),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Text(
                      snapshot.data!,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Text(
                      'Recommended Produts',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    );
            },
          ),
          //gridview builder
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 10,
              ),
              itemCount: productNames.length, // Number of items in the grid
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MeItemDetails(
                                itemName: productNames[index],
                                itemImage: Imagelt2[index],
                                categoryName: categoryNames[index],
                              )),
                    );
                  },
                  child: Card(
                    // Wrap GridTile with Card for elevation and shape
                    color: Colors.grey[200],
                    elevation: 5, // Shadow depth
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    child: GridTile(
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.network(Imagelt2[index],
                                  fit: BoxFit.cover), // Category image
                            ),
                          ),
                          Padding(
                            // Add padding around the text
                            padding: EdgeInsets.all(8.0),
                            child: FutureBuilder<String>(
                              future:
                                  Translate.translateText(productNames[index]),
                              builder: (context, snapshot) {
                                return snapshot.hasData
                                    ? Text(
                                        snapshot.data!,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(productNames[index],
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  FutureBuilder<QuerySnapshot<Object?>> future_carouselSlider() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('medical_eqipment_categories')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final categories = snapshot.data!.docs.map((doc) {
            return Category(
              name: doc['name'],
              image: doc['image_url'],
            );
          }).toList();
          return CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 2.0,
              enlargeCenterPage: true,
            ),
            items: categories.map((category) {
              return Builder(
                builder: (BuildContext context) {
                  return InkWell(
                    onTap: () {
                      predict(getClick());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MeItems2(categoryName: category.name),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue[100],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.network(
                              category.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                          FutureBuilder<String>(
                            future: Translate.translateText(category.name),
                            builder: (context, snapshot) {
                              return snapshot.hasData
                                  ? Text(
                                      snapshot.data!,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text(
                                      category.name,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  FutureBuilder<QuerySnapshot<Object?>> future_grid_layout() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('medical_eqipment_categories')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          // Convert each document into a Category object
          final categories = snapshot.data!.docs.map((doc) {
            return Category(
              name: doc['name'],
              image: doc['image_url'],
              // Assuming there's an 'imageUrl' field
            );
          }).toList();
          return grid_lay(categories);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  grid_lay(List<Category> categories) {
    return Container(
      height: 150,
      // Wrap GridView with Expanded
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns in the grid
            crossAxisSpacing: 5, // Space between columns
            mainAxisSpacing: 10, // Space between rows
          ),
          itemCount: categories.length, // Number of items in the grid
          itemBuilder: (context, index) {
            // Accessing each category by index
            Category category = categories[index];
            return InkWell(
              onTap: () {
                predict(getClick());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeItems2(categoryName: category.name),
                  ),
                );
              },
              child: Card(
                // Wrap GridTile with Card for elevation and shape
                color: Colors.grey[200],
                elevation: 5, // Shadow depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: GridTile(
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(category.image,
                              fit: BoxFit.cover), // Category image
                        ),
                      ),
                      Padding(
                        // Add padding around the text
                        padding: EdgeInsets.all(8.0),
                        child: FutureBuilder<String>(
                          future: Translate.translateText(category.name),
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? Text(snapshot.data!,
                                    textAlign: TextAlign.center)
                                : Text(category.name,
                                    textAlign: TextAlign.center);
                          },
                        ), // Category name
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
