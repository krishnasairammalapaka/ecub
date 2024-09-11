import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearHotel extends StatefulWidget {
  @override
  _NearHotelState createState() => _NearHotelState();
}

class _NearHotelState extends State<NearHotel> {
  GoogleMapController? mapController;
  Position? _userPosition;
  List<Marker> _markers = [];
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchHotels();
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userPosition = position;
    });
  }

  Future<void> _fetchHotels() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('fs_hotels').get();
      snapshot.docs.forEach((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // Safely fetch latitude and longitude (null check)
        double? latitude = data['latitude'] != null ? double.parse(data['latitude'].toString()) : null;
        double? longitude = data['longitude'] != null ? double.parse(data['longitude'].toString()) : null;

        // Safely fetch the hotel name, using an empty string if null
        String hotelName = data['hotelName'] ?? 'Unknown Hotel';

        // Ensure latitude and longitude are not null before proceeding
        if (latitude != null && longitude != null && _userPosition != null) {
          double distanceInMeters = Geolocator.distanceBetween(
            _userPosition!.latitude, _userPosition!.longitude,
            latitude, longitude,
          );
          double distanceInKm = distanceInMeters / 1000;

          // Add marker to map
          _markers.add(Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: 'Hotel: $hotelName',
              snippet: '${distanceInKm.toStringAsFixed(2)} km away',
            ),
          ));
        }
      });
    } catch (e) {
      print('Error fetching hotel data: $e');
    } finally {
      setState(() {
        _isLoading = false; // Data fetched, stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Hotels')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : _userPosition == null
          ? Center(child: Text("Failed to get location"))
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: Set.from(_markers),
        initialCameraPosition: CameraPosition(
          target: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          zoom: 12,
        ),
      ),
    );
  }
}
