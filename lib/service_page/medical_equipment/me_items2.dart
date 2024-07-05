// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_item_details.dart';
import 'package:flutter/material.dart';

class MeItems2 extends StatefulWidget {
  final String categoryName;

  MeItems2({super.key, required this.categoryName});

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
        title: Text(widget.categoryName),
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
              onTap: () {
                // Navigate to the item details page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeItemDetails(
                      itemName: itemKeys[index],
                      itemImage: Imagelt[index],
                      categoryName: widget.categoryName,
                    ),
                  ),
                );
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
                    child: Text(
                      itemKeys[index], // Item name
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
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
}
