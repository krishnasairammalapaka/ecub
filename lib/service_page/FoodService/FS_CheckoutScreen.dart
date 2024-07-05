import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecub_s1_v2/models/Cart_Db.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:intl/intl.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:ecub_s1_v2/models/CheckoutHistory_DB.dart';

class FS_CheckoutScreen extends StatefulWidget {
  @override
  _FS_CheckoutScreenState createState() => _FS_CheckoutScreenState();
}

class _FS_CheckoutScreenState extends State<FS_CheckoutScreen> {
  Box<Cart_Db>? _cartBox;
  Box<Food_db>? FDbox;
  Box<CheckoutHistory_DB>? _checkoutHistoryBox;
  double totalAmount = 0;
  String userName = 'Karuppasamy Karuppiah';
  String userAddress = '123 Main Street, Springfield';
  String userPhoneNumber = '+918778997952';
  String selectedPaymentOption = 'Cash on Delivery';

  final twilioFlutter = TwilioFlutter(
    accountSid: 'ACd609662616433afac55654bd43d55f46',
    authToken: '4770c2b10a830ae10b0027026dcbe029',
    twilioNumber: '+18085155636',
  );

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  Future<void> _openBoxes() async {
    await Hive.initFlutter();
    _cartBox = await Hive.openBox<Cart_Db>('cartItems');
    FDbox = await Hive.openBox<Food_db>('foodDbBox');
    _checkoutHistoryBox = await Hive.openBox<CheckoutHistory_DB>('checkoutHistory');
    _calculateTotalAmount();
    setState(() {});
  }

  void _calculateTotalAmount() {
    totalAmount = 0;
    for (var item in _cartBox!.values) {
      var product = FDbox!.values.firstWhere((element) => element.productId == item.ItemId);
      totalAmount += item.ItemCount * product.productPrice;
    }
  }

  void _showEditUserDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempName = userName;
        String tempAddress = userAddress;
        String tempPhoneNumber = userPhoneNumber;

        return AlertDialog(
          title: Text('Edit User Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => tempName = value,
                controller: TextEditingController(text: tempName),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Address'),
                onChanged: (value) => tempAddress = value,
                controller: TextEditingController(text: tempAddress),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) => tempPhoneNumber = value,
                controller: TextEditingController(text: tempPhoneNumber),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  userName = tempName;
                  userAddress = tempAddress;
                  userPhoneNumber = tempPhoneNumber;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Confirmation'),
          content: Text('Your order will be placed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _confirmOrder();
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmOrder() async {
    // Send confirmation SMS using TwilioFlutter
    await twilioFlutter.sendSMS(
      toNumber: userPhoneNumber,
      messageBody: 'Your order has been placed successfully. Total amount: ₹ $totalAmount',
    );

    // Transfer cart data to checkout history
    for (var item in _cartBox!.values) {

      final newItem = CheckoutHistory_DB(
        UserId: '1',
        ItemId: item.ItemId,
        ItemCount: item.ItemCount,
        TimeStamp: "",
        key: DateTime.now().millisecondsSinceEpoch,
      );
      await _checkoutHistoryBox!.add(newItem);
    }

    // Clear the cart
    await _cartBox!.clear();
    setState(() {});

    // Navigate to the profile page
    Navigator.pushNamed(context, '/fs_profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        title: Text(
          'Checkout',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _cartBox == null || FDbox == null || !FDbox!.isOpen
                  ? Center(child: CircularProgressIndicator())
                  : ValueListenableBuilder(
                valueListenable: _cartBox!.listenable(),
                builder: (context, Box<Cart_Db> items, _) {
                  if (items.isEmpty) {
                    return Center(child: Text('No items in the cart.'));
                  } else {
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        var item = items.getAt(index);
                        if (item == null) {
                          return Center(child: Text('Item not found.'));
                        }

                        var productId = item.ItemId;

                        var productDetails = FDbox!.values.firstWhere(
                                (element) => element.productId == productId);

                        return CheckoutItemCard(
                          productDetails: productDetails,
                          itemCount: item.ItemCount.toInt(),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              'User Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(userName),
              subtitle: Text('$userAddress\n$userPhoneNumber'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _showEditUserDetailsDialog,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Total Amount: ₹ $totalAmount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Payment Options:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedPaymentOption,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPaymentOption = newValue!;
                });
              },
              items: <String>['Cash on Delivery', 'Online Payment', 'Card Payment']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Uncomment the following block if you need to handle online or card payment options
            // if (selectedPaymentOption == 'Card Payment') ...[
            //   SizedBox(height: 16),
            //   ElevatedButton(
            //     onPressed: () {
            //       Navigator.pushNamed(context, '/card');
            //     },
            //     child: Text('Enter Card Details'),
            //   ),
            // ]
            // else if (selectedPaymentOption == 'Online Payment') ...[
            //   SizedBox(height: 16),
            //   ElevatedButton(
            //     onPressed: () {
            //       Navigator.pushNamed(context, '/card');
            //     },
            //     child: Text('Enter Card Details'),
            //   ),
            // ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOrderConfirmationDialog,
        child: Icon(Icons.check),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class CheckoutItemCard extends StatelessWidget {
  final Food_db productDetails;
  final int itemCount;

  CheckoutItemCard({
    required this.productDetails,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.asset(productDetails.productImg),
        title: Text(productDetails.productTitle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ₹ ${productDetails.productPrice}'),
            Text('Quantity: $itemCount'),
          ],
        ),
      ),
    );
  }
}
