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
  late double pricePerItem;
  late String productId;
  late String ShopUsername;
  bool isProductInCart = false;
  bool isProductFavorite = false;
  List<Comment> comments = []; // List to hold comments
  String sortOrder = 'newest'; // Default sort order

  @override
  void initState() {
    super.initState();
    _openBoxes();
    _loadComments(); // Load comments initially
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
    final foodItem = FDbox?.values.firstWhere((food) => food.productId == productId);
    final String? itemOwnership = foodItem?.productOwnership;

    final existingItems = _cartBox.values.toList();

    if (existingItems.isNotEmpty) {
      final firstItemOwnership = FDbox?.values.firstWhere((food) => food.productId == existingItems.first.ItemId).productOwnership;
      if (firstItemOwnership != itemOwnership) {
        showOwnershipConflictDialog();
        return;
      }
    }

    final newItem = Cart_Db(
      UserId: '1',
      ItemId: productId,
      ItemCount: count.toDouble(),
      key: DateTime.now().millisecondsSinceEpoch,
    );
    await _cartBox.add(newItem);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to cart')));
    setState(() {
      isProductInCart = true;
    });
  }

  void showOwnershipConflictDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ownership Conflict'),
          content: Text('The products in your cart are from a different hotel. Do you want to reset the cart and add this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // await clearCart('1'); // Clear the cart
                addToCart(); // Add the new item to the cart
              },
              child: Text('Reset Cart'),
            ),
          ],
        );
      },
    );
  }




  void toggleFavorite() async {
    print('Favourites before toggle: ${_favouritesBox.values.toList()}');

    if (isProductFavorite) {
      final favoriteItemIndex = _favouritesBox.values
          .toList()
          .indexWhere((item) => item.ItemId == productId);
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

  void _loadComments() {
    // Load comments from a data source
    comments = [
      Comment(
        profilePhotoUrl: "assets/user.png",
        userName: 'Karuppasamy',
        commentText: 'This is a great product!',
        rating: 4,
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
      Comment(
        profilePhotoUrl: "assets/user.png",
        userName: 'Karthik Raja',
        commentText: 'Really loved it!',
        rating: 3,
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
      // Add more comments here
    ];
    _sortComments();
  }

  void _sortComments() {
    setState(() {
      if (sortOrder == 'newest') {
        comments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } else if (sortOrder == 'oldest') {
        comments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
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
          ValueListenableBuilder(
            valueListenable: _cartBox.listenable(),
            builder: (context, Box<Cart_Db> box, _) {
              int totalItems = getTotalCartItemsCount();

              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart,size: 40),
                    onPressed: () {
                      Navigator.pushNamed(context, '/fs_cart');
                    },
                  ),
                  if (totalItems > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Color(0xFF0D5EF9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$totalItems',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],

      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100.0),
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
                        image: AssetImage(
                            args['image'] ?? 'assets/defaultImage.png'),
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
                          isProductFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isProductFavorite ? Color(0xFF0D5EF9) : null,
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
                          color: Color(0xFF0D5EF9),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    args['description'] ?? 'Product description goes here.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
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
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/fs_hotel', arguments: {
                              'id': '1',
                              'username':ShopUsername,
                              'name': ShopUsername,
                            });
                          },
                          child: Text(
                            ShopUsername,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                                          color: Color(0xFF0D5EF9),
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

                  SizedBox(height: 20),

                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text('Sort by: '),
                      DropdownButton<String>(
                        value: sortOrder,
                        onChanged: (String? newValue) {
                          setState(() {
                            sortOrder = newValue!;
                            _sortComments();
                          });
                        },
                        items: <String>['newest', 'oldest']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/user.png"),
                        ),
                        title: Text(comment.userName),
                        subtitle: Text(comment.commentText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < comment.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      );
                    },
                  ),

                ],
              ),
            ),
          ),




          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        count = count > 1 ? count - 1 : 1;
                      });
                    },
                    child: Icon(Icons.remove),
                  ),
                  Text('$count'),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        count++;
                      });
                    },
                    child: Icon(Icons.add),
                  ),


                  ElevatedButton(
                    onPressed: isProductInCart
                        ? null
                        : () {
                      if (checkOwnership(productId)) {
                        addToCart();
                      } else {
                        showOwnershipConflictDialog();
                      }
                    },
                    child: Text(
                      isProductInCart
                          ? 'Already Added'
                          : 'Add to Cart',
                      style: TextStyle(fontSize: 18),
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

  bool checkOwnership(String productId) {
    final foodItem = FDbox?.values.firstWhere((food) => food.productId == productId);
    final String? itemOwnership = foodItem?.productOwnership;

    final existingItems = _cartBox.values.toList();
    if (existingItems.isNotEmpty) {
      final firstItemOwnership = FDbox?.values.firstWhere((food) => food.productId == existingItems.first.ItemId).productOwnership;
      if (firstItemOwnership != itemOwnership) {
        return false;
      }
    }
    return true;
  }

  int getTotalCartItemsCount() {
    int totalItems = 0;
    for (var cartItem in _cartBox.values) {
      totalItems += cartItem.ItemCount.toInt();
    }
    return totalItems;
  }



}

class Comment {
  final String userName;
  final String commentText;
  final String profilePhotoUrl;
  final int rating;
  final DateTime timestamp;

  Comment({
    required this.userName,
    required this.commentText,
    required this.profilePhotoUrl,
    required this.rating,
    required this.timestamp
  });
}
