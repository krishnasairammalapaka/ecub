import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecub_s1_v2/service_page/medical_equipment/RentCalculator.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_item_desc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MeItemDetails extends StatefulWidget {
  final String itemName;
  final String itemImage;
  final String categoryName;
  // final String rent;

  const MeItemDetails({
    Key? key,
    required this.itemName,
    required this.itemImage,
    required this.categoryName,
    // required this.rent,
  }) : super(key: key);

  @override
  _MeItemDetailsState createState() => _MeItemDetailsState();
}

class _MeItemDetailsState extends State<MeItemDetails> {
  Future<void> addItemToCart(String name, String storeName, String address,
      String rating, String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
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
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                    const SizedBox(height: 30),
                    Text(
                      'For Description  and price click on select store',
                      style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        storeListBuy(context, 'Select Store', Colors.green[400],
                            Icons.ads_click_outlined),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _currentSortOption = 'Prize';
  ElevatedButton storeListBuy(
      BuildContext context, String label, Color? color, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () async {
        final categoryName = widget.categoryName;
        store_list(context, categoryName);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<dynamic> store_list(BuildContext context, String categoryName) {
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
                store_list(context, categoryName);
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
                                      itemName: widget.itemName,
                                      imageUrl: widget.itemImage,
                                      price: stores[index].prize.toString(),
                                      storeAddress: stores[index].address,
                                      rent: stores[index].rent,
                                      // rent: stores[index].rent,
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: Icon(Icons.store, color: Colors.red),
                                title: Text(
                                  stores[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(stores[index].address),
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

class Stores {
  final String name;
  final String address;
  final double rating;
  final int prize;
  final String rent;

  Stores({
    required this.name,
    required this.address,
    required this.rating,
    required this.prize,
    required this.rent,
  });
}
