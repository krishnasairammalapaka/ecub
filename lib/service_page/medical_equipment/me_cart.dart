import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecub_s1_v2/components/pay_home_food.dart';
import 'package:ecub_s1_v2/components/pay_home_med.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';

class Mecart extends StatefulWidget {
  const Mecart({Key? key}) : super(key: key);

  @override
  State<Mecart> createState() => _MecartState();
}

String searchQuery = "";
final User? user = FirebaseAuth.instance.currentUser;

class _MecartState extends State<Mecart> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double totalPrice = 0.0;
  @override
  void initState() {
    super.initState();
    calculateTotalPrice();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void calculateTotalPrice() async {
    double total = 0.0;
    QuerySnapshot cartItems = await FirebaseFirestore.instance
        .collection('me_cart')
        .doc(user?.email)
        .collection('items')
        .get();

    print(total);
    cartItems.docs.forEach((doc) {
      total += double.parse(doc.get('price')) * doc['quantity'];
      // total += doc['price'] * doc['quantity'];
    });

    setState(() {
      totalPrice = total;
    });
    print(totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: Translate.translateText("Cart"),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Text(
                    snapshot.data!,
                  )
                : Text("Cart");
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            FutureBuilder<String>(
              future: Translate.translateText("Buy"),
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Tab(text: snapshot.data!)
                    : Tab(text: 'Buy');
              },
            ), // nav bar intialization
            FutureBuilder<String>(
              future: Translate.translateText("Rent"),
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Tab(text: snapshot.data!)
                    : Tab(text: 'Rent');
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/me_orders');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              items_tile(),
            ],
          ),
          RentPage(),
        ],
      ),
    );
  }

  Map<String, Map<String, dynamic>> generateOrderSummary(
      List<DocumentSnapshot> docs) {
    if (docs.isEmpty) return {};

    var summary = <String, Map<String, dynamic>>{};
    for (var doc in docs) {
      var name = doc['name'];
      var store = doc['storeName'];
      var quantity = doc['quantity'];
      // Fix: Update each document as a separate entry in the summary map
      summary[doc.id] = {
        'name': name,
        'storeName': store,
        'quantity': quantity,
      };
    }
    return summary;
  }

  // ignore: non_constant_identifier_names
  Expanded items_tile() {
    return Expanded(
      child: user == null
          ? const Center(child: Text("Please login to view your cart"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('me_cart')
                  .doc(user?.email)
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error fetching cart items."));
                }

                if (snapshot.data?.docs.isEmpty ?? true) {
                  return Center(
                    child: FutureBuilder<String>(
                      future: Translate.translateText("Your cart is Empty"),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? Text(snapshot.data!)
                            : Text("Your Cart is empty");
                      },
                    ),
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder<String>(
                        future: Translate.translateText("Search"),
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    labelText: snapshot.data!,
                                    suffixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value.toLowerCase();
                                    });
                                  },
                                )
                              : TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    labelText: "Search",
                                    suffixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value.toLowerCase();
                                    });
                                  },
                                );
                        },
                      ),
                    ),
                    Expanded(
                      child: user == null
                          ? Center(
                              child: FutureBuilder<String>(
                                future: Translate.translateText(
                                    "Please login to view the cart"),
                                builder: (context, snapshot) {
                                  return snapshot.hasData
                                      ? Text(snapshot.data!)
                                      : Text("please login to view the cart");
                                },
                              ),
                            )
                          : StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('me_cart')
                                  .doc(user?.email)
                                  .collection('items')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: FutureBuilder<String>(
                                      future: Translate.translateText(
                                          "error while fetching the cart"),
                                      builder: (context, snapshot) {
                                        return snapshot.hasData
                                            ? Text(snapshot.data!)
                                            : Text(
                                                "error while fetching the cart");
                                      },
                                    ),
                                  );
                                }
                                var filteredDocs = searchQuery.isEmpty
                                    ? snapshot.data?.docs ?? []
                                    : snapshot.data?.docs.where((doc) {
                                          var itemName = doc['name']
                                              .toString()
                                              .toLowerCase();
                                          return itemName.contains(searchQuery);
                                        }).toList() ??
                                        [];

                                if (filteredDocs.isEmpty) {
                                  return Center(
                                    child: FutureBuilder<String>(
                                      future: Translate.translateText(
                                          "Your cart is Empty"),
                                      builder: (context, snapshot) {
                                        return snapshot.hasData
                                            ? Text(snapshot.data!)
                                            : Text("Your Cart is empty");
                                      },
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: filteredDocs.length,
                                  itemBuilder: (context, index) {
                                    var item = filteredDocs[index];
                                    return Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(10),
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(item['imageUrl'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover),
                                        ),
                                        title: FutureBuilder<String>(
                                          future: Translate.translateText(
                                              item['name']),
                                          builder: (context, snapshot) {
                                            return snapshot.hasData
                                                ? Text(
                                                    snapshot.data!,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold, // Makes text bold
                                                    ),
                                                  )
                                                : Text(
                                                    item['name'],
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold, // Makes text bold
                                                    ),
                                                  );
                                          },
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: FutureBuilder<String>(
                                                future: Translate.translateText(
                                                    ' Store: ${item['name']}'),
                                                builder: (context, snapshot) {
                                                  return snapshot.hasData
                                                      ? Text(
                                                          snapshot.data!,
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        )
                                                      : Text(
                                                          'Store: ${item['storeName']}',
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        );
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: FutureBuilder<String>(
                                                future: Translate.translateText(
                                                    'Price:'),
                                                builder: (context, snapshot) {
                                                  return snapshot.hasData
                                                      ? Text(
                                                          '${snapshot.data!} \₹${item['price']}',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.green),
                                                        )
                                                      : Text(
                                                          'Price: \₹${item['price'].toString()}',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.green),
                                                        );
                                                },
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                      Icons.remove_circle,
                                                      color: Colors
                                                          .red), // Custom icon color
                                                  onPressed: () {
                                                    int currentQuantity =
                                                        item['quantity'];
                                                    if (currentQuantity > 1) {
                                                      FirebaseFirestore.instance
                                                          .collection('me_cart')
                                                          .doc(user?.email)
                                                          .collection('items')
                                                          .doc(item.id)
                                                          .update({
                                                        'quantity': FieldValue
                                                            .increment(-1)
                                                      });
                                                    } else {
                                                      FirebaseFirestore.instance
                                                          .collection('me_cart')
                                                          .doc(user?.email)
                                                          .collection('items')
                                                          .doc(item.id)
                                                          .delete();
                                                    }
                                                    calculateTotalPrice();
                                                  },
                                                ),
                                                FutureBuilder<String>(
                                                  future: Translate.translateText(
                                                      'Quantity: ${item['quantity']}'),
                                                  builder: (context, snapshot) {
                                                    return snapshot.hasData
                                                        ? Text(snapshot.data!)
                                                        : Text(
                                                            'Quantity: ${item['quantity']}');
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.add_circle,
                                                      color: Colors
                                                          .green), // Custom icon color
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection('me_cart')
                                                        .doc(user?.email)
                                                        .collection('items')
                                                        .doc(item.id)
                                                        .update({
                                                      'quantity':
                                                          FieldValue.increment(
                                                              1)
                                                    });
                                                    calculateTotalPrice();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete_outline,
                                              color: Colors.grey[
                                                  600]), // Custom icon color
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('me_cart')
                                                .doc(user?.email)
                                                .collection('items')
                                                .doc(item.id)
                                                .delete();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FutureBuilder<String>(
                        future: Translate.translateText('Total Price:'),
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? Text(
                                  '${snapshot.data!} \₹${totalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  'Total Price: \₹${totalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                );
                        },
                      ),
                    ),
                    // place_order_button(context, snapshot),
                    placeOrderButton1(context, snapshot),
                  ],
                );
              },
            ),
    );
  }

  Padding placeOrderButton1(
      BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: SlideAction(
        text: 'Slide to Place Order', // Text displayed on the slider
        onSubmit: () {
          // Show dialog first to confirm the action
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: FutureBuilder<String>(
                  future: Translate.translateText("confirm order"),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? Text(
                            snapshot.data!,
                          )
                        : Text("Confirm order");
                  },
                ),
                content: FutureBuilder<String>(
                  future: Translate.translateText(
                      "Are you sure you want to place this order?"),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? Text(
                            snapshot.data!,
                          )
                        : Text('Are you sure you want to place this order?');
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    child: FutureBuilder<String>(
                      future: Translate.translateText("Cancel"),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? Text(
                                snapshot.data!,
                              )
                            : Text('Cancel');
                      },
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close the dialog
                    },
                  ),
                  TextButton(
                    child: FutureBuilder<String>(
                      future: Translate.translateText("Confirm"),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? Text(
                                snapshot.data!,
                              )
                            : Text('Confirm');
                      },
                    ),
                    onPressed: () {
                      // Place the order
                      Navigator.pop(context);
                      FirebaseFirestore.instance
                          .collection('me_orders')
                          .doc(user?.email)
                          .collection('orders')
                          .add({
                        'order_summary':
                            generateOrderSummary(snapshot.data?.docs ?? []),
                      }).then((_) {
                        // Clear the cart after placing the order
                        FirebaseFirestore.instance
                            .collection('me_cart')
                            .doc(user?.email)
                            .collection('items')
                            .get()
                            .then((snapshot) {
                          for (DocumentSnapshot ds in snapshot.docs) {
                            ds.reference.delete();
                          }
                        });
                      });
                      Navigator.of(dialogContext).pop();
                      calculateTotalPrice();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PayHomeMed(
                                  price: totalPrice,
                                )),
                      ); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
          return null;
        },
        sliderButtonIcon: Icon(
            Icons.arrow_circle_right_outlined), // Icon inside the slider button
      ),
    );
  }

  Padding place_order_button(
      BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: FutureBuilder<String>(
                  future: Translate.translateText("Order Summary"),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? Text(
                            snapshot.data!,
                          )
                        : Text('Order Summary');
                  },
                ),
                content: Container(
                  width: double.maxFinite, // Ensures the dialog is wide enough
                  child: ListView.builder(
                    shrinkWrap:
                        true, // Important to ensure it doesn't take infinite height
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      var doc = snapshot.data?.docs[index];
                      var name = doc?['name']; // Assuming 'name' field exists
                      var quantity = doc?['quantity']
                          .toString(); // Assuming 'quantity' field exists
                      var imageUrl =
                          doc?['imageUrl']; // Assuming 'imageUrl' field exists

                      return Row(
                        children: [
                          Image.network(
                            imageUrl,
                            width: 50, // Adjust size as needed
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 10), // Spacing between image and text
                          Expanded(
                            child: Text("$name x $quantity"),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      calculateTotalPrice();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PayHomeMed(
                                  price: totalPrice,
                                )),
                      );
                      // FirebaseFirestore.instance
                      //     .collection('me_orders')
                      //     .doc(user?.email)
                      //     .collection('orders')
                      //     .add({
                      //   'order_summary':
                      //       generateOrderSummary(snapshot.data?.docs ?? []),
                      // });
                      // //clear the cart
                      // FirebaseFirestore.instance
                      //     .collection('me_cart')
                      //     .doc(user?.email)
                      //     .collection('items')
                      //     .get()
                      //     .then((snapshot) {
                      //   for (DocumentSnapshot ds in snapshot.docs) {
                      //     ds.reference.delete();
                      //   }
                      // });
                      Navigator.pop(context);
                    },
                    child: FutureBuilder<String>(
                      future: Translate.translateText("Confirm"),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? Text(
                                snapshot.data!,
                              )
                            : Text('Confirm');
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.lightGreen[600], // Text color
        ),
        child: FutureBuilder<String>(
          future: Translate.translateText("Proceed to Place order"),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Text(
                    snapshot.data!,
                  )
                : Text('Proceed to Place order');
          },
        ),
      ),
    );
  }
}

class RentPage extends StatefulWidget {
  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  @override
  Widget build(BuildContext context) {
    return user == null
        ? Center(
            child: FutureBuilder<String>(
              future: Translate.translateText("Please login to view the cart"),
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Text(
                        snapshot.data!,
                      )
                    : Text('Please login to view cart');
              },
            ),
          )
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('me_cart_rent')
                .doc(user?.email)
                .collection('items')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Error fetching cart items."));
              }

              if (snapshot.data?.docs.isEmpty ?? true) {
                return const Center(child: Text("Your cart is empty"));
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "Search",
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: user == null
                        ? const Center(
                            child: Text("Please login to view your cart"))
                        : StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('me_cart_rent')
                                .doc(user?.email)
                                .collection('items')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text("Error fetching cart items."));
                              }
                              var filteredDocs = searchQuery.isEmpty
                                  ? snapshot.data?.docs ?? []
                                  : snapshot.data?.docs.where((doc) {
                                        var itemName = doc['name']
                                            .toString()
                                            .toLowerCase();
                                        return itemName.contains(searchQuery);
                                      }).toList() ??
                                      [];

                              if (filteredDocs.isEmpty) {
                                return const Center(
                                    child: Text("Your cart is empty"));
                              }

                              return ListView.builder(
                                itemCount: filteredDocs.length,
                                itemBuilder: (context, index) {
                                  var item = filteredDocs[index];
                                  return Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(10),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(item['imageUrl'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover),
                                      ),
                                      title: Text(
                                        item['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight
                                              .bold, // Makes text bold
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                                'Store: ${item['storeName']}',
                                                style: TextStyle(fontSize: 14)),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove_circle,
                                                    color: Colors
                                                        .red), // Custom icon color
                                                onPressed: () {
                                                  int currentQuantity =
                                                      item['quantity'];
                                                  if (currentQuantity > 1) {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'me_cart_rent')
                                                        .doc(user?.email)
                                                        .collection('items')
                                                        .doc(item.id)
                                                        .update({
                                                      'quantity':
                                                          FieldValue.increment(
                                                              -1)
                                                    });
                                                  } else {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'me_cart_rent')
                                                        .doc(user?.email)
                                                        .collection('items')
                                                        .doc(item.id)
                                                        .delete();
                                                  }
                                                },
                                              ),
                                              Text(
                                                  'Quantity: ${item['quantity']}'),
                                              IconButton(
                                                icon: Icon(Icons.add_circle,
                                                    color: Colors
                                                        .green), // Custom icon color
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'me_cart_rent')
                                                      .doc(user?.email)
                                                      .collection('items')
                                                      .doc(item.id)
                                                      .update({
                                                    'quantity':
                                                        FieldValue.increment(1)
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete_outline,
                                            color: Colors.grey[
                                                600]), // Custom icon color
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('me_cart_rent')
                                              .doc(user?.email)
                                              .collection('items')
                                              .doc(item.id)
                                              .delete();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
  }
}
