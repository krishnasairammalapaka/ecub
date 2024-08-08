import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RentCalculator extends StatefulWidget {
  final String shopName;
  final String productName; // Add productName
  final String image_url; // Add shopAddress
  final String price;
  final String shopAddress;

  const RentCalculator({
    super.key,
    required this.shopName,
    required this.productName, // Initialize productName
    required this.shopAddress,
    required this.image_url, // Initialize shopAddress
    required this.price,
  });

  @override
  _RentCalculatorState createState() => _RentCalculatorState();
}

class _RentCalculatorState extends State<RentCalculator> {
  bool _isWeekly = true;
  int _numberOfWeeks = 0;
  int _numberOfMonths = 0;
  double _totalRent = 0.0;
  double _weeklyRate = 100.0;
  double _monthlyRate = 400.0;
  DateTime? _selectedDeliveryDate;
  DateTime? _deadlineDate;
  bool _detailsSubmitted = false;

  void _calculateTotalRent() {
    setState(() {
      if (_isWeekly) {
        _totalRent = _numberOfWeeks * _weeklyRate;
      } else {
        _totalRent = _numberOfMonths * _monthlyRate;
      }
      _detailsSubmitted = true;
    });
  }

  Future<void> addItemToCart(
      String name, String storeName, String address, String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      DocumentReference itemRef = FirebaseFirestore.instance
          .collection('me_cart_rent')
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
      // pop navigator
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeliveryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDeliveryDate) {
      setState(() {
        _selectedDeliveryDate = picked;
        _calculateDeadline();
      });
    }
  }

  void _calculateDeadline() {
    if (_selectedDeliveryDate != null) {
      if (_isWeekly && _numberOfWeeks > 0) {
        _deadlineDate =
            _selectedDeliveryDate!.add(Duration(days: _numberOfWeeks * 7));
      } else if (!_isWeekly && _numberOfMonths > 0) {
        _deadlineDate = DateTime(
          _selectedDeliveryDate!.year,
          _selectedDeliveryDate!.month + _numberOfMonths,
          _selectedDeliveryDate!.day,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String deadlineText =
        _deadlineDate != null ? DateFormat.yMMMd().format(_deadlineDate!) : '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.image_url,
                height: 200,
                width: 200,
                // fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                '',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Shop Name: ${widget.shopName}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Product Name: ${widget.productName}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Address: ${widget.shopAddress}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _isWeekly,
                  onChanged: (value) {
                    setState(() {
                      _isWeekly = value ?? false;
                      _calculateDeadline();
                    });
                  },
                ),
                Text('Weekly Rent'),
                SizedBox(width: 20),
                Checkbox(
                  value: !_isWeekly,
                  onChanged: (value) {
                    setState(() {
                      _isWeekly = !(value ?? true);
                      _calculateDeadline();
                    });
                  },
                ),
                Text('Monthly Rent'),
              ],
            ),
            SizedBox(height: 20),
            if (_isWeekly)
              TextField(
                decoration: InputDecoration(
                  // on tap outside
                  hintText: 'Enter number of weeks',
                  border: OutlineInputBorder(),
                  
                  labelText: 'Number of Weeks',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _numberOfWeeks = int.tryParse(value) ?? 0;
                    _calculateDeadline();
                  });
                },
              )
            else
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter number of months',
                  border: OutlineInputBorder(),
                  labelText: 'Number of Months',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _numberOfMonths = int.tryParse(value) ?? 0;
                    _calculateDeadline();
                  });
                },
              ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Select Starting Date:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _calculateTotalRent();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Color.fromARGB(255, 240, 105, 105)),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                child: Text(
                  'Calculate Total Rent',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_detailsSubmitted)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Rent: ₹ $_totalRent',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (_selectedDeliveryDate != null)
                    Text(
                      'Delivery Date: ${DateFormat.yMMMd().format(_selectedDeliveryDate!)}',
                      style: TextStyle(fontSize: 18),
                    ),
                  if (_deadlineDate != null)
                    Text(
                      'Deadline: $deadlineText',
                      style: TextStyle(fontSize: 18),
                    ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        addItemToCart(
                          widget.productName,
                          widget.shopName,
                          widget.shopAddress,
                          widget.image_url,
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Colors.blue,
                        ),
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        ),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      child: Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RentCalculator(
      shopName: 'Example Shop', // Example shop name
      productName: 'Example Product', // Example product name
      shopAddress: 'Example Address',
      image_url: '', // Example address
      price: '100',
    ),
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
    ),
  ));
}
