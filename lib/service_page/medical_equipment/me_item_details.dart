import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MeItemDetails extends StatefulWidget {
  final String itemName;
  final String itemImage;
  final String categoryName;

  const MeItemDetails({
    Key? key,
    required this.itemName,
    required this.itemImage,
    required this.categoryName,
  }) : super(key: key);

  @override
  _MeItemDetailsState createState() => _MeItemDetailsState();
}

class _MeItemDetailsState extends State<MeItemDetails> {
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

  Future<bool> ItemInCart(String name) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      // Reference to the specific item in the user's cart
      DocumentReference itemRef = FirebaseFirestore.instance
          .collection('me_cart')
          .doc(user.email)
          .collection('items')
          .doc(name);
          DocumentSnapshot itemSnapshot = await itemRef.get();
          if (itemSnapshot.exists) {
            return true;
          }
          else {
            return false;
            }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                // title: Text(widget.itemName, style: GoogleFonts.lato(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: <Color>[
                            Color.fromARGB(10, 0, 0, 0),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Image.network(
                                    widget.itemImage,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Image.network(
                        widget.itemImage,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.itemName,
                      style: GoogleFonts.lato(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Description',
                      style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'This is a description of the item. It can be a long description or a short one. It can contain details about the item, such as its features, specifications, and more.',
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Price',
                          style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                        const SizedBox(width: 10),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Rs. 1000',
                              style: GoogleFonts.lato(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    //add to cart
                    storeList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton storeList(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.shopping_cart),
      label: Text('Add to Cart'), // Fixed: Changed 'child' to 'label'
      onPressed: () async {
        final categoryName = widget.categoryName;
        // Display the modal with the list of stores
        showModalBottomSheet(
          context: context,
          // future builder
          builder: (context) {
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection(
                      'medical_eqipment_categories') // Fixed typo in collection name
                  .doc(categoryName)
                  .collection('data')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  final stores = snapshot.data!.docs.map((doc) {
                    return Stores(
                      name: doc['Name'],
                      address: doc['Address'],
                      rating: doc['Rating'],
                    );
                  }).toList();
                  // print the length
                  print(stores.length);
                  return ListView.builder(
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                        child: Card(
                          elevation: 5, // Adds shadow under the card
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15), // Rounded corners
                          ),
                          child: InkWell(
                            onTap: () {
                              // Add the item to the cart
                              // print
                              addItemToCart(
                                widget.itemName,
                                stores[index].name,
                                stores[index].address,
                                stores[index].rating.toString(),
                                widget.itemImage,
                              );
                              Navigator.pop(context);
                            },
                            child: ListTile(
                              leading: Icon(Icons.store, color: Colors.red),
                              title: Text(
                                stores[index].name,
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold, // Bold text for name
                                ),
                              ),
                              subtitle: Text(stores[index].address),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor, // Background color of the tag
                                  borderRadius: BorderRadius.circular(
                                      20), // Rounded corners for the tag
                                ),
                                child: Text(
                                  "${stores[index].rating}⭐",
                                  style: TextStyle(
                                    color: Colors.white, // White text color
                                  ),
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
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
      ),
    );
  }
}


class Stores {
  final String name;
  final String address;
  final double rating;

  Stores({
    required this.name,
    required this.address,
    required this.rating,
  });
}

