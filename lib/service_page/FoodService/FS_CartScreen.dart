import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    _openBoxes();
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
  }

  void _calculateTotalCalories() {
    totalCalories = 0;
    itemCounts.forEach((productId, count) {
      final product = FDbox!.values.firstWhereOrNull(
              (element) => element.productId == productId);
      if (product != null) {
        // Static calorie data
        final calories = _getCaloriesForProduct(product.productTitle);
        totalCalories += calories * count;
      }
    });
  }

  double _getCaloriesForProduct(String productTitle) {
    // Static calorie data
    const calorieData = {
      'Veggie Pizza': 150.0,
      'Steak': 200.0,
      'Grilled Salmon': 150.0,
      'Beef Burger': 75.0,
      // Add more products and their calorie information here
    };

    return calorieData[productTitle] ?? 0;
  }

  void _onFloatingButtonPressed() {
    if (_cartBox!.values.length <= 2) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Insufficient Calories'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This much calories are not enough to complete your appetite. Try adding more items to your cart.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToCheckout();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      _navigateToCheckout();
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
        onPressed: _onFloatingButtonPressed,
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
            Text('Calories: ${_getCaloriesForProduct(productDetails.productTitle)} cal'),
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

  double _getCaloriesForProduct(String productTitle) {
    const calorieData = {
      'Veggie Pizza': 150.0,
      'Steak': 200.0,
      'Grilled Salmon': 150.0,
      'Beef Burger': 75.0,
      // Add more products and their calorie information here
    };

    return calorieData[productTitle] ?? 0;
  }
}
