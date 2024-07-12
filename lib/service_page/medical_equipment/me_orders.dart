import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MeOrders extends StatelessWidget {
  MeOrders({super.key});

  final User? user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> fetchOrders() {
    if (user != null && user?.email != null) {
      return FirebaseFirestore.instance
          .collection('me_orders')
          .doc(user?.email)
          .collection('orders')
          .snapshots();
    } else {
      return Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Equipment Orders'),
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('me_orders')
              .doc(user?.email)
              .collection('orders')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final items = snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                //get keys to list
                List<String> keys = data['order_summary'].keys.toList();
                //create a list of items
                data = data['order_summary'];
                List<Item> items = [];
                for (int i = 0; i < keys.length; i++) {
                  print(data[keys[i]]['name']);
                  items.add(Item(
                      name: data[keys[i]]['name'],
                      quantity: data[keys[i]]['quantity'],
                      store: data[keys[i]]['storeName']));
                }
                return items;
              }).toList();
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Order ${index + 1}'),
                        ),
                        Column(
                          children: items[index].map((item) {
                            return ListTile(
                              title: Text(item.name),
                              subtitle: Text('Store: ${item.store}'),
                              trailing: Text('Quantity: ${item.quantity}'),
                              //add store name
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}

class Item {
  final String name;
  final int quantity;
  final String store;
  Item({
    required this.name,
    required this.quantity,
    required this.store,
  });
}
