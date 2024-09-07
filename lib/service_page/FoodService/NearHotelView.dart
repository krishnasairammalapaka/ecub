import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearHotel extends StatefulWidget {
  @override
  _NearHotelState createState() => _NearHotelState();
}

class _NearHotelState extends State<NearHotel> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = LatLng(0, 0); // Default initial position

  @override
  void initState() {
    super.initState();
    _fetchLocationFromFirestore();
  }

  // Fetch longitude and latitude from Firestore
  Future<void> _fetchLocationFromFirestore() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('fs_hotels')
        .doc('fs_hotels') // Change to your Firestore document ID
        .get();

    if (documentSnapshot.exists) {
      double latitude = documentSnapshot['latitude'];
      double longitude = documentSnapshot['longitude'];

      setState(() {
        _initialPosition = LatLng(latitude, longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 15, // Set zoom level
        ),
        markers: {
          Marker(
            markerId: MarkerId('locationMarker'),
            position: _initialPosition,
            infoWindow: InfoWindow(
              title: 'Marked Location',
            ),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
