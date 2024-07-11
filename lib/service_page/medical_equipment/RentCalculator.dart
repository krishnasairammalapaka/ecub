import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RentCalculator extends StatefulWidget {
  final String shopName;
  final String productName; // Add productName
  final String shopAddress; // Add shopAddress

  const RentCalculator({
    Key? key,
    required this.shopName,
    required this.productName, // Initialize productName
    required this.shopAddress, // Initialize shopAddress
  }) : super(key: key);

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
                  'Select Delivery Date:',
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
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 240, 105, 105)),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
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
                    'Total Rent: \Rs $_totalRent',
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
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue,
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
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
        shopAddress: 'Example Address' // Example address
        ),
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
    ),
  ));
}
