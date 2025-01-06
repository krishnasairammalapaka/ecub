import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';

class MeOrders extends StatefulWidget {
  const MeOrders({super.key});

  @override
  State<MeOrders> createState() => _MeOrdersState();
}

class _MeOrdersState extends State<MeOrders> {
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

  // Add map launcher function
  Future<void> _launchMaps() async {
    try {
      // Static coordinates
      final startLat = 9.5121;  // Current location
      final startLng = 77.6340;
      final destLat = 9.5636;   // Store location
      final destLng = 77.6822;

      final url = 'google.navigation:q=$destLat,$destLng&origin=$startLat,$startLng';
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback to maps launcher
        MapsLauncher.launchCoordinates(destLat, destLng);
      }
    } catch (e) {
      print('Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Equipment Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Get document data with null safety
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>? ?? {};
              
              return Card(
                margin: EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        data['name'] ?? 'Unknown Item', // Changed from itemName to name
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: ₹${data['price']?.toString() ?? '0'}'),
                          Text('Quantity: ${data['quantity']?.toString() ?? '1'}'),
                          Text('Status: ${data['status'] ?? 'Processing'}'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: ElevatedButton.icon(
                        onPressed: _launchMaps,  // Connect to map launcher
                        icon: Icon(Icons.location_on),
                        label: Text('Track Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 45),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Item {
  final String name;
  final int quantity;
  final String store;
  final String price;
  Item({
    required this.name,
    required this.quantity,
    required this.store,
    required this.price,
  });
}
