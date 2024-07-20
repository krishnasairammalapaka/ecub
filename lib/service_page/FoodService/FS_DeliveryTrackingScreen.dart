import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class FS_DeliveryTrackingScreen extends StatelessWidget {
  final LatLng _initialPosition = LatLng(37.77483, -122.41942);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: MarkerId('scooter'),
                position: _initialPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
              ),
            },
          ),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            top: 50,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.my_location, color: Colors.black),
              onPressed: () {
                // Logic to center map on user's location
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.black),
                      SizedBox(width: 10),
                      Text("10-15 min", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.black),
                      SizedBox(width: 10),
                      Text("Chintal Chandranagar", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF0D5EF9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('assets/delivery_person.png'),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("XXXXXX", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("AAAAAA", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.call, color: Colors.white),
                          onPressed: () {
                            // Logic to call the delivery person
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
