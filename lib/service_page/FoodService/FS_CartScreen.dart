import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:ecub_s1_v2/models/Cart_Db.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';

class FS_CartScreen extends StatefulWidget {
  @override
  _FS_CartScreenState createState() => _FS_CartScreenState();
}

class _FS_CartScreenState extends State<FS_CartScreen> {
  Box<Cart_Db>? _cartBox;
  Box<Food_db>? FDbox;
  Map<String, int> itemCounts = {};
  double totalAmount = 0;
  double totalCalories = 0;
  bool _isSubscriptionActive = false;
  Map<String, dynamic>? subscriptionPack;

  @override
  void initState() {
    super.initState();
    _openBoxes();
    _checkSubscriptionStatus();
  }

  Future<void> _openBoxes() async {
    _cartBox = await Hive.openBox<Cart_Db>('cartItems');
    FDbox = await Hive.openBox<Food_db>('foodDbBox');

    setState(() {
      _initializeItemCounts();
      _calculateTotalAmount();
      _calculateTotalCalories();
    });
  }

  Future<void> _checkSubscriptionStatus() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final packDoc = await FirebaseFirestore.instance
        .collection('fs_cart')
        .doc(userEmail)
        .collection('packs')
        .doc('info')
        .get();

    if (packDoc.exists && packDoc.data()?['active'] == "cart") {
      setState(() {
        _isSubscriptionActive = true;
        subscriptionPack = packDoc.data();
      });
    }
  }

  void _initializeItemCounts() {
    if (_cartBox != null) {
      for (var item in _cartBox!.values) {
        itemCounts[item.ItemId] = item.ItemCount.toInt();
      }
    }
  }

  void _incrementCount(String productId) {
    setState(() {
      itemCounts[productId] = (itemCounts[productId] ?? 0) + 1;
      _updateCartItem(productId, itemCounts[productId]!);
    });

    _calculateTotalAmount();
    _calculateTotalCalories();
  }

  void _decrementCount(String productId) {
    setState(() {
      if (itemCounts[productId] != null && itemCounts[productId]! > 0) {
        itemCounts[productId] = itemCounts[productId]! - 1;
        if (itemCounts[productId] == 0) {
          _deleteCartItem(productId);
        } else {
          _updateCartItem(productId, itemCounts[productId]!);
        }
      }
    });
    _calculateTotalAmount();
    _calculateTotalCalories();
  }

  void _deleteItem(String productId) {
    setState(() {
      itemCounts.remove(productId);
      _deleteCartItem(productId);
    });
    _calculateTotalAmount();
    _calculateTotalCalories();
  }

  void _updateCartItem(String productId, int count) {
    var cartItem = _cartBox!.values.firstWhere((item) => item.ItemId == productId);
    cartItem.ItemCount = count.toDouble();
    cartItem.save();
  }

  void _deleteCartItem(String productId) {
    var cartItemKey = _cartBox!.keys.firstWhere((key) {
      var item = _cartBox!.get(key);
      return item != null && item.ItemId == productId;
    });
    _cartBox!.delete(cartItemKey);
  }

  void _calculateTotalAmount() {
    totalAmount = 0;
    itemCounts.forEach((productId, count) {
      final product = FDbox!.values.firstWhereOrNull(
              (element) => element.productId == productId);
      if (product != null) {
        totalAmount += product.productPrice * count;
      }
    });

    if (_isSubscriptionActive && subscriptionPack != null) {
      totalAmount += subscriptionPack!['price'];
    }
  }

  void _calculateTotalCalories() {
    totalCalories = 0;
    itemCounts.forEach((productId, count) {
      final product = FDbox!.values.firstWhereOrNull(
              (element) => element.productId == productId);
      if (product != null) {
        totalCalories += product.calories * count;
      }
    });

    if (_isSubscriptionActive && subscriptionPack != null) {
      totalCalories += subscriptionPack!['calories'];
    }
  }

  void _navigateToCheckout() {
    final itemsWithCount = itemCounts.entries
        .where((entry) => entry.value > 0)
        .map((entry) => {
      'id': entry.key,
      'count': entry.value,
    })
        .toList();

    Navigator.pushNamed(
      context,
      '/fs_checkout',
      arguments: {
        'itemsWithCount': itemsWithCount,
        'totalAmount': totalAmount,
        'totalCalories': totalCalories,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D5EF9),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cart Items',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _cartBox == null || FDbox == null
                  ? Center(child: CircularProgressIndicator())
                  : ValueListenableBuilder(
                valueListenable: _cartBox!.listenable(),
                builder: (context, Box<Cart_Db> items, _) {
                  if (items.isEmpty && _isSubscriptionActive == false) {
                    return Center(child: Text('No items in the cart.'));
                  } else {
                    return ListView.builder(
                      itemCount: items.length + (_isSubscriptionActive ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < items.length) {
                          var item = items.getAt(index);
                          if (item == null) {
                            return Center(child: Text('Item not found.'));
                          }

                          var productId = item.ItemId;
                          var productDetails = FDbox!.values.firstWhereOrNull(
                                  (element) => element.productId == productId);

                          if (productDetails == null) {
                            return Center(child: Text('Product not found.'));
                          }

                          itemCounts[productId] =
                              itemCounts[productId] ?? item.ItemCount.toInt();

                          return GestureDetector(
                            onTap: () {},
                            child: CartItemCard(
                              productDetails: productDetails,
                              itemCount: itemCounts[productId]!,
                              onIncrement: () => _incrementCount(productId),
                              onDecrement: () => _decrementCount(productId),
                              onDelete: () => _deleteItem(productId),
                            ),
                          );
                        } else if (_isSubscriptionActive) {
                          return SubscriptionPackCard(
                            subscriptionPack: subscriptionPack!,
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total Calories: $totalCalories cal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCheckout,
        child: Icon(Icons.check),
        backgroundColor: Color(0xFF0D5EF9),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final Food_db productDetails;
  final int itemCount;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  CartItemCard({
    required this.productDetails,
    required this.itemCount,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            productDetails.productImg,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(productDetails.productTitle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ₹ ${productDetails.productPrice}'),
            Text('Calories: ${productDetails.calories} cal'),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: onDecrement,
                ),
                Text('$itemCount'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: onIncrement,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionPackCard extends StatelessWidget {
  final Map<String, dynamic> subscriptionPack;

  SubscriptionPackCard({required this.subscriptionPack});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.card_membership, size: 64, color: Colors.blue),
        title: Text('Subscription Pack'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${subscriptionPack['packName']} pack'),
            Text('Price: ₹ ${subscriptionPack['totalPrice']}'),
          ],
        ),
      ),
    );
  }
}
