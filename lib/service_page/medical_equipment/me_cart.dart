import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Mecart extends StatefulWidget {
  const Mecart({Key? key}) : super(key: key);

  @override
  State<Mecart> createState() => _MecartState();
}

class _MecartState extends State<Mecart> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  String searchQuery = "";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Buy'), // nav bar intialization
            Tab(text: 'Rent'),
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
          ? const Center(child: Text("Please login to view your cart."))
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
                  return const Center(child: Text("Your cart is empty."));
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
                              child: Text("Please login to view your cart."))
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
                                  return const Center(
                                      child:
                                          Text("Error fetching cart items."));
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
                                      child: Text("Your cart is empty."));
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
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                  'Store: ${item['storeName']}',
                                                  style:
                                                      TextStyle(fontSize: 14)),
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
                                                        .collection('me_cart')
                                                        .doc(user?.email)
                                                        .collection('items')
                                                        .doc(item.id)
                                                        .update({
                                                      'quantity':
                                                          FieldValue.increment(
                                                              1)
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Order Summary'),
                                content: Container(
                                  width: double
                                      .maxFinite, // Ensures the dialog is wide enough
                                  child: ListView.builder(
                                    shrinkWrap:
                                        true, // Important to ensure it doesn't take infinite height
                                    itemCount: snapshot.data?.docs.length ?? 0,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var doc = snapshot.data?.docs[index];
                                      var name = doc?[
                                          'name']; // Assuming 'name' field exists
                                      var quantity = doc?['quantity']
                                          .toString(); // Assuming 'quantity' field exists
                                      var imageUrl = doc?[
                                          'imageUrl']; // Assuming 'imageUrl' field exists

                                      return Row(
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            width: 50, // Adjust size as needed
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(
                                              width:
                                                  10), // Spacing between image and text
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
                                      FirebaseFirestore.instance
                                          .collection('me_orders')
                                          .doc(user?.email)
                                          .collection('orders')
                                          .add({
                                        'order_summary': generateOrderSummary(
                                            snapshot.data?.docs ?? []),
                                      });
                                      //clear the cart
                                      FirebaseFirestore.instance
                                          .collection('me_cart')
                                          .doc(user?.email)
                                          .collection('items')
                                          .get()
                                          .then((snapshot) {
                                        for (DocumentSnapshot ds
                                            in snapshot.docs) {
                                          ds.reference.delete();
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text('Confirm'),
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
                        child: Text('Proceed to Place Order'),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class RentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('one Second.'),
    );
  }
}
