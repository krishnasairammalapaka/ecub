import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MeItems extends StatefulWidget {
  final String categoryName;
  const MeItems({super.key, required this.categoryName});

  @override
  State<MeItems> createState() => _MeItemsState();
}

class _MeItemsState extends State<MeItems> {
  List<String> itemKeys = [];
  List<String> Imagelt = [];
  int _selectedIndex = 0; // To store the selected index

  @override
  void initState() {
    super.initState();
    fetchItemKeys();
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

  Future<void> addItemToCart(String name, String storeName, String address,
      String rating, String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      // Reference to the specific item in the user's cart
      DocumentReference itemRef = FirebaseFirestore.instance
          .collection('me_cart')
          .doc(user.email)
          .collection('items')
          .doc("${name}_$storeName");

      DocumentSnapshot itemSnapshot = await itemRef.get();
      if (itemSnapshot.exists) {
        int currentQuantity = itemSnapshot['quantity'];
        await itemRef.update({'quantity': currentQuantity + 1});
      } else {
        await itemRef.set({
          'name': name,
          'storeName': storeName,
          'address': address,
          'rating': rating,
          'imageUrl': imageUrl,
          'quantity': 1,
        });
      }
      // Show success dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(itemSnapshot.exists
              ? 'Item quantity updated'
              : 'Item added to cart'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          duration: const Duration(
              seconds: 2), // Set the duration for the snackbar to be visible
          behavior: SnackBarBehavior
              .floating, // Make the snackbar float above the bottom navigation bar
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text(widget.categoryName),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: SizedBox(
            height: 80.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemKeys.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex =
                            index; // Update the selected index on tap
                      });
                    },
                    splashColor: Colors.transparent,
                    highlightColor:
                        Colors.red.withOpacity(0.5), // Highlight color on tap
                    child: Chip(
                      backgroundColor: _selectedIndex == index
                          ? Colors.red[700]
                          : null, // Change background color if selected
                      label: Text(
                        itemKeys[index],
                        style: TextStyle(
                          color: _selectedIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('medical_eqipment_categories')
            .doc(widget.categoryName)
            .collection('data')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final items = snapshot.data!.docs.map((doc) {
              return Item(
                name: doc['Name'],
                address: doc['Address'],
                rating: doc['Rating'],
              );
            }).toList();
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: InteractiveViewer(
                              panEnabled:
                                  false, // Set it to false to prevent panning.
                              boundaryMargin: EdgeInsets.all(80),
                              minScale: 0.5,
                              maxScale: 4,
                              child: Image.network(
                                Imagelt[
                                    _selectedIndex], // Use the correct image URL field
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            8.0), // Rounded square corners
                        child: Image.network(
                          Imagelt[
                              _selectedIndex], // Assuming each item has an imageUrl field
                          width: 50.0, // Set your desired width
                          height: 50.0, // Set your desired height
                          fit: BoxFit.cover, // Cover the bounds of the box
                        ),
                      ),
                    ),
                    title: Text(
                      items[index].name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: FutureBuilder<String>(
                      future: Translate.translateText(items[index].address),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          return Text(snapshot.data!);
                        } else {
                          // Return a default Text widget if there's no data
                          return Text(items[index].address);
                        }
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize
                          .min, // To minimize the row's size to its children size
                      children: [
                        Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: FutureBuilder<String>(
                              future: Translate.translateText(
                                  '${items[index].rating} ⭐'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data!,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  );
                                } else {
                                  // Return a default Text widget if there's no data
                                  return Text(
                                    '${items[index].rating} ⭐',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  );
                                }
                              },
                            )),
                        IconButton(
                          icon: Icon(Icons.add_shopping_cart,
                              color: Colors.green),
                          onPressed: () {
                            addItemToCart(
                              itemKeys[_selectedIndex],
                              items[index].name,
                              items[index].address,
                              items[index].rating.toString(),
                              Imagelt[
                                  _selectedIndex], // Assuming there's an imageUrl field in your Item class
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class Item {
  final String name;
  final String address;
  final double rating;

  Item({
    required this.name,
    required this.address,
    required this.rating,
  });
}
