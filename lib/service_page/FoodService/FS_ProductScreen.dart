import 'package:ecub_s1_v2/models/Cart_Db.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Favourites_DB.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CartDB {
  final Box<Cart_Db> _cartBox = Hive.box<Cart_Db>('cartItems');

  Future<void> addToCart(String userId, String itemId, double itemCount) async {
    bool itemExists = _cartBox.values.any(
            (cartItem) => cartItem.UserId == userId && cartItem.ItemId == itemId);

    if (itemExists) {
      Cart_Db existingItem = _cartBox.values.firstWhere(
            (cartItem) => cartItem.UserId == userId && cartItem.ItemId == itemId,
      );
      existingItem =
          existingItem.copyWith(ItemCount: existingItem.ItemCount + itemCount);
      await _cartBox.put(existingItem.key, existingItem);
    } else {
      final newItem = Cart_Db(
        UserId: userId,
        ItemId: itemId,
        ItemCount: itemCount,
        key: DateTime.now().millisecondsSinceEpoch,
      );
      await _cartBox.add(newItem);
    }
  }

  Future<List<Cart_Db>> getCartItems(String userId) async {
    List<Cart_Db> userCartItems =
    _cartBox.values.where((cartItem) => cartItem.UserId == userId).toList();
    return userCartItems;
  }

  Future<void> removeFromCart(int key) async {
    await _cartBox.delete(key);
  }

  Future<void> clearCart(String userId) async {
    List<Cart_Db> userCartItems =
    _cartBox.values.where((cartItem) => cartItem.UserId == userId).toList();
    for (var item in userCartItems) {
      await _cartBox.delete(item.key);
    }
  }
}

class FS_ProductScreen extends StatefulWidget {
  @override
  _FS_ProductScreenState createState() => _FS_ProductScreenState();
}

class _FS_ProductScreenState extends State<FS_ProductScreen> {
  late Box<Cart_Db> _cartBox;
  Box<Food_db>? FDbox;

  late Box<Favourites_DB> _favouritesBox;

  int count = 1;
  late int pricePerItem;
  late String productId;
  late String ShopUsername;
  bool isProductInCart = false;
  bool isProductFavorite = false;

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  Future<void> _openBoxes() async {
    _cartBox = await Hive.openBox<Cart_Db>('cartItems');
    FDbox = await Hive.openBox<Food_db>('foodDbBox');
    _favouritesBox = await Hive.openBox<Favourites_DB>('favouritesDbBox');
    _checkIfProductInCart();
    _checkIfProductFavorite();
    setState(() {});
  }

  void _checkIfProductInCart() {
    final existingItems = _cartBox.values.toList();
    final existingItemIndex =
    existingItems.indexWhere((item) => item.ItemId == productId);

    if (existingItemIndex != -1) {
      setState(() {
        isProductInCart = true;
      });
    }
  }

  void _checkIfProductFavorite() {
    final existingItems = _favouritesBox.values.toList();
    final existingItemIndex =
    existingItems.indexWhere((item) => item.ItemId == productId);

    if (existingItemIndex != -1) {
      setState(() {
        isProductFavorite = true;
      });
    }
  }

  void addToCart() async {
    final existingItems = _cartBox.values.toList();
    final existingItemIndex =
    existingItems.indexWhere((item) => item.ItemId == productId);

    if (existingItemIndex != -1) {
      final existingItem = _cartBox.values.elementAt(existingItemIndex);
      final newItem =
      existingItem.copyWith(ItemCount: existingItem.ItemCount + count);
      await _cartBox.put(existingItem.key, newItem);
    } else {
      final newItem = Cart_Db(
        UserId: '1',
        ItemId: productId,
        ItemCount: count.toDouble(),
        key: DateTime.now().millisecondsSinceEpoch,
      );
      await _cartBox.add(newItem);
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Added to cart')));
    setState(() {
      isProductInCart = true;
    });
  }

  void toggleFavorite() async {
    print('Favourites before toggle: ${_favouritesBox.values.toList()}');

    if (isProductFavorite) {
      final favoriteItemIndex =
      _favouritesBox.values.toList().indexWhere((item) => item.ItemId == productId);
      if (favoriteItemIndex != -1) {
        final favoriteItemKey = _favouritesBox.keyAt(favoriteItemIndex);
        await _favouritesBox.delete(favoriteItemKey);
      }
    } else {
      final newItem = Favourites_DB(
        UserId: '1',
        ItemId: productId,
        key: DateTime.now().millisecondsSinceEpoch,
      );
      await _favouritesBox.add(newItem);
    }

    print('Favourites after toggle: ${_favouritesBox.values.toList()}');

    setState(() {
      isProductFavorite = !isProductFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    productId = args['id'];
    pricePerItem = args['price'];
    ShopUsername = args['shop'];

    return Scaffold(
      appBar: AppBar(
        title: Text(args['title'] ?? 'Product Details'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/fs_cart');
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/cart.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image:
                    AssetImage(args['image'] ?? 'assets/defaultImage.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    args['title'] ?? 'Product Title',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isProductFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isProductFavorite ? Colors.red : null,
                    ),
                    onPressed: toggleFavorite,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹ ${args['price'] ?? 'N/A'}",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                args['description'] ?? 'Product description goes here.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/hotel_profile');
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/hotel_prof.png'),
                      radius: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      ShopUsername,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    'You might also like',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
                child: FDbox == null
                    ? Center(child: CircularProgressIndicator())
                    : ValueListenableBuilder(
                  valueListenable: FDbox!.listenable(),
                  builder: (context, Box<Food_db> items, _) {
                    if (items.isEmpty) {
                      return Center(child: Text('No items found.'));
                    } else {
                      List<Food_db> sortedItems =
                      items.values.toList();
                      sortedItems.sort((a, b) =>
                          b.productRating.compareTo(a.productRating));

                      List<Food_db> popularItems = sortedItems
                          .where((item) => item.productRating < 4.4)
                          .toList();


                      popularItems.shuffle();

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: popularItems.length,
                        itemBuilder: (context, index) {
                          var item = popularItems[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/fs_product',
                                  arguments: {
                                    'id': item.productId,
                                    'title': item.productTitle,
                                    'price': item.productPrice.toInt(),
                                    'image': item.productImg,
                                    'description': item.productDesc,
                                    'shop': item.productOwnership,
                                  });
                            },
                            child: Container(
                              width: 150,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            item.productImg),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    item.productTitle,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '₹ ${item.productPrice}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),

              SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (count > 1) {
                        count--;
                      }
                    });
                  },
                  icon: Icon(Icons.remove_circle_outline),
                  iconSize: 30,
                ),
                Text(
                  '$count',
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      count++;
                    });
                  },
                  icon: Icon(Icons.add_circle_outline),
                  iconSize: 30,
                ),
              ],
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isProductInCart ? null : addToCart,
                child: Text(
                  isProductInCart ? 'Already Added' : 'Add to Cart',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
