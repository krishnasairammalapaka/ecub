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
  }

  void _deleteItem(String productId) {
    setState(() {
      itemCounts.remove(productId);
      _deleteCartItem(productId);
    });
    _calculateTotalAmount();
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

  void _onFloatingButtonPressed() {
        if (_cartBox!.values.length <= 2) {
            List<Food_db> foodItems = FDbox!.values.toList();
      foodItems.shuffle();       List<Food_db> selectedItems = foodItems.take(2).toList();

            showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Insufficient Calories'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFoodTile(context, selectedItems[0]),
                      _buildFoodTile(context, selectedItems[1]),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'This much calories are not enough to complete your appetite.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();                   _navigateToCheckout();                 },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
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
        },
      );
    }
  }

  Widget _buildFoodTile(BuildContext context, Food_db foodItem) {
    return Container(
      width: 120,
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              foodItem.productImg,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(
            foodItem.productTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '₹ ${foodItem.productPrice}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              _addToCart(foodItem);               Navigator.of(context).pop();             },
            icon: Icon(Icons.shopping_cart),
            label: Text('Add'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(Food_db foodItem) {
                setState(() {
      var existingItem = _cartBox!.values.firstWhereOrNull(
            (item) => item.ItemId == foodItem.productId,
      );

      if (existingItem == null) {
        _cartBox!.add(Cart_Db(ItemId: foodItem.productId, ItemCount: 1, UserId: '1', key: 0));
      } else {
        existingItem.ItemCount += 1;
        existingItem.save();
      }

            _initializeItemCounts();
      _calculateTotalAmount();
    });
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
      },
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
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
              onPressed: () {

              },
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
                          onTap: () {

                          },
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFloatingButtonPressed,
        child: Icon(Icons.check),
        backgroundColor: Colors.red,
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









