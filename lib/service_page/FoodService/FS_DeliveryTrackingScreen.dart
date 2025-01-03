import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FS_DeliveryTrackingScreen extends StatefulWidget {
  const FS_DeliveryTrackingScreen({super.key});

  @override
  _FS_DeliveryTrackingScreenState createState() => _FS_DeliveryTrackingScreenState();
}

class _FS_DeliveryTrackingScreenState extends State<FS_DeliveryTrackingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  LatLng _currentLocation = LatLng(0.0, 0.0);
  String? _deliveryBoyId;
  String? _orderId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchArguments();
  }

  void _fetchArguments() {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _orderId = arguments?['Orderid'] as String?;
    if (_orderId != null) {
      _fetchDeliveryBoyId();
    }
  }

  Future<void> _fetchDeliveryBoyId() async {
    try {
      final orderDoc = await _firestore.collection('orders').doc(_orderId).get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data();
        _deliveryBoyId = orderData?['del_agent'];
        _listenToLocationUpdates();
      }
    } catch (e) {
      print('Error fetching delivery boy ID: $e');
    }
  }

  void _listenToLocationUpdates() {
    if (_deliveryBoyId != null) {
      _firestore
          .collection('orders')
          .doc(_orderId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          final lat = data?['current_latitude'] ?? 0.0;
          final lng = data?['current_longitude'] ?? 0.0;
          
          setState(() {
            _currentLocation = LatLng(lat, lng);
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(_currentLocation)
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Delivery'),
      ),
      body: _currentLocation.latitude == 0.0 && _currentLocation.longitude == 0.0
        ? Center(child: CircularProgressIndicator())
        : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentLocation.latitude != 0.0 && _currentLocation.longitude != 0.0) {
                _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation));
              }
            },
            markers: {
              Marker(
                markerId: MarkerId('delivery_boy'),
                position: _currentLocation,
                infoWindow: InfoWindow(title: 'Delivery Boy'),
              ),
            },
          ),
    );
  }
}