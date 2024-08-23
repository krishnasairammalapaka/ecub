import 'package:ecub_s1_v2/components/pay_home_food.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecub_s1_v2/models/Cart_Db.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:ecub_s1_v2/models/CheckoutHistory_DB.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FS_CheckoutScreen extends StatefulWidget {
  @override
  _FS_CheckoutScreenState createState() => _FS_CheckoutScreenState();
}

class _FS_CheckoutScreenState extends State<FS_CheckoutScreen> {
  Box<Cart_Db>? _cartBox;
  Box<Food_db>? FDbox;
  Box<CheckoutHistory_DB>? _checkoutHistoryBox;
  double totalAmount = 0;
  int packPPrice = 0;
  String userId = '';
  String userName = '';
  String userAddress = '';
  String userPhoneNumber = '';
  LatLng? userLocation;
  String selectedPaymentOption = 'Cash on Delivery';
  bool hasSubscription = false;
  Map<String, dynamic>? subscriptionPack;

  final twilioFlutter = TwilioFlutter(
    accountSid: 'ACd609662616433afac55654bd43d55f46',
    authToken: '4770c2b10a830ae10b0027026dcbe029',
    twilioNumber: '+18085155636',
  );

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _openBoxes();
  }

  Future<void> _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.email!;
      await _fetchUserDetails();
      await _checkSubscription();
      _calculateTotalAmount();
    }
  }

  Future<void> _openBoxes() async {
    _cartBox = await Hive.openBox<Cart_Db>('cartItems');
    FDbox = await Hive.openBox<Food_db>('foodDbBox');
    _checkoutHistoryBox =
    await Hive.openBox<CheckoutHistory_DB>('checkoutHistory');
    setState(() {});
  }

  Future<void> _fetchUserDetails() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic>? userData =
        userDoc.data() as Map<String, dynamic>?;

        setState(() {
          userName = userData?['firstname'] ?? 'No name';
          userPhoneNumber = userData?['phonenumber'] ?? 'No phone number';

          userAddress = userData?.containsKey('address') == true
              ? userData!['address'] ?? 'Enter address'
              : 'Enter address';
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Future<void> _checkSubscription() async {
    DocumentSnapshot subscriptionDoc = await FirebaseFirestore.instance
        .collection('fs_cart')
        .doc(userId)
        .collection('packs')
        .doc('info')
        .get();

    if (subscriptionDoc.exists) {
      var data = subscriptionDoc.data() as Map<String, dynamic>;
      if (data['active'] == "cart") {
        setState(() {
          packPPrice = data['totalPrice'];
          hasSubscription = true;
          subscriptionPack = data;
        });
        _calculateTotalAmount();
      } else {
        setState(() {
          hasSubscription = false;
          subscriptionPack = null;
        });
      }
    }
  }

  void _calculateTotalAmount() {
    totalAmount = 0;
    if (_cartBox != null && FDbox != null) {
      for (var item in _cartBox!.values) {
        var product = FDbox!.values
            .firstWhere((element) => element.productId == item.ItemId);
        totalAmount += item.ItemCount * product.productPrice;
      }
    }
    if (hasSubscription && subscriptionPack != null) {
      totalAmount += packPPrice;
    }
    setState(() {});
    print(totalAmount);
    print(packPPrice);
  }

  Future<void> _confirmOrder() async {
    // Save order details to Firestore, including address and payment method
    for (var item in _cartBox!.values) {
      final newItem = CheckoutHistory_DB(
        UserId: userId,
        ItemId: item.ItemId,
        ItemCount: item.ItemCount,
        TimeStamp: "",
        key: DateTime.now().millisecondsSinceEpoch,
      );
      await _checkoutHistoryBox!.add(newItem);

      var productDetails = FDbox!.values
          .firstWhere((element) => element.productId == item.ItemId);
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'itemId': item.ItemId,
        'itemCount': item.ItemCount,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
        'itemName': productDetails.productTitle,
        'itemPrice': productDetails.productPrice * item.ItemCount,
        'vendor': productDetails.productOwnership,
        'payment-method': selectedPaymentOption, // Save payment method
        'address': userAddress, // Save address
      });
    }

    await _cartBox!.clear();
    setState(() {});

    await FirebaseFirestore.instance
        .collection('fs_cart')
        .doc(userId)
        .collection('packs')
        .doc('info')
        .update({'active': 'True'});

    // Navigate to the profile page
    // Navigator.pushNamed(context, '/fs_home');
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PayHomeFood(
                        amount: totalAmount,
                      )),
                );
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D5EF9),
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
            if (hasSubscription && subscriptionPack != null) ...[
              Text(
                'Subscription Pack:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SubsCard(
                packName: subscriptionPack!['packName'],
                packPrice: subscriptionPack!['totalPrice'],
              ),
              SizedBox(height: 26),
            ],
            Text(
              'User Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(userName),
              subtitle: Text('$userPhoneNumber'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _showEditUserDetailsDialog,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Address Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(userAddress),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _showEditUserDetailsDialog,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Payment Method:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(selectedPaymentOption),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _showPaymentOptionsDialog,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\₹${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showOrderConfirmationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D5EF9),
                minimumSize: Size.fromHeight(50),
              ),
              child: Text(
                'Confirm Order',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDetailsDialog() {
    // Implement this method to allow users to edit their details
  }

  void _showPaymentOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Cash on Delivery'),
                leading: Radio<String>(
                  value: 'Cash on Delivery',
                  groupValue: selectedPaymentOption,
                  onChanged: (String? value) {
                    setState(() {
                      selectedPaymentOption = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('Online Payment'),
                leading: Radio<String>(
                  value: 'Online Payment',
                  groupValue: selectedPaymentOption,
                  onChanged: (String? value) {
                    setState(() {
                      selectedPaymentOption = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
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
        leading: Image.network(productDetails.productImg),
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

class SubsCard extends StatelessWidget {
  final String packName;
  final int packPrice;

  SubsCard({
    required this.packName,
    required this.packPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.card_membership, size: 64, color: Colors.blue),
        title: Text(packName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ₹ ${packPrice}'),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  final Function(LatLng) onLocationSelected;

  MapScreen({required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Location')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0), // Default position
          zoom: 10,
        ),
        onTap: (LatLng location) {
          onLocationSelected(location);
        },
      ),
    );
  }
}
