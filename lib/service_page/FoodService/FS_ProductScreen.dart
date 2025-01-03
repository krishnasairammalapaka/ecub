import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/models/Cart_Db.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Favourites_DB.dart';
import 'package:ecub_s1_v2/translation.dart';
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
  const FS_ProductScreen({super.key});

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
  List<Comment> comments = []; // List to hold comments
  String sortOrder = 'newest'; // Default sort order
  double averageRating = 0.0;
  int totalRatings = 0;
  int totalReviews = 0;

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
    final foodItem =
        FDbox?.values.firstWhere((food) => food.productId == productId);
    final String? itemOwnership = foodItem?.productOwnership;

    final existingItems = _cartBox.values.toList();

    if (existingItems.isNotEmpty) {
      final firstItemOwnership = FDbox?.values
          .firstWhere((food) => food.productId == existingItems.first.ItemId)
          .productOwnership;
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

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: FutureBuilder<String>(
      future: Translate.translateText("Added to cart"),
      builder: (context, snapshot) {
        return snapshot.hasData ? Text(snapshot.data!) : Text("Added to cart");
      },
    )));
    setState(() {
      isProductInCart = true;
    });
  }

  void showOwnershipConflictDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: FutureBuilder<String>(
            future: Translate.translateText("Ownership conflit"),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Text(snapshot.data!)
                  : Text("Ownership conflit");
            },
          ),
          content: FutureBuilder<String>(
            future: Translate.translateText(
                "The products in your Cart are from a diiferent hotel.Do you want to reset the cart"),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Text(snapshot.data!)
                  : Text(
                      "The products in your Cart are from a diiferent hotel.Do you want to reset the cart");
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: FutureBuilder<String>(
                future: Translate.translateText("Cancel"),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Text(snapshot.data!)
                      : Text("Cancel");
                },
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Clear the cart
                await _cartBox.clear();
                setState(() {});
                addToCart(); // Add the new item to the cart
              },
              child: FutureBuilder<String>(
                future: Translate.translateText("Reset cart"),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Text(snapshot.data!)
                      : Text("Reset cart");
                },
              ),
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


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    productId = args['id'];
    pricePerItem = args['price'];
    ShopUsername = args['shop'];

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: Translate.translateText(args['title']),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!);
            } else {
              return Text(args['title']);
            }
          },
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: _cartBox.listenable(),
            builder: (context, Box<Cart_Db> box, _) {
              int totalItems = getTotalCartItemsCount();
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart, size: 40),
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
                        image: NetworkImage(
                            args['image'] ?? 'assets/defaultImage.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<String>(
                        future: Translate.translateText(args['title']),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data ?? 'Product Title',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return Text(
                              args['title'] ?? 'Product Title',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
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
                  FutureBuilder<String>(
                    future: Translate.translateText(args['description']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data ?? 'Product description goes here.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        );
                      } else {
                        return Text(
                          args['description'] ??
                              'Product description goes here.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        );
                      }
                    },
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
                            Navigator.pushNamed(context, '/fs_hotel',
                                arguments: {
                                  'id': '1',
                                  'username': ShopUsername,
                                  'name': ShopUsername,
                                });
                          },
                          child: FutureBuilder<String>(
                            future: Translate.translateText(ShopUsername),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              } else {
                                return Text(
                                  ShopUsername,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(width: 10),
                      FutureBuilder<String>(
                        future: Translate.translateText("You Might also like"),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data!,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis),
                            );
                          } else {
                            return Text(
                              'You might also like',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: FDbox == null
                        ? Center(child: CircularProgressIndicator())
                        : ValueListenableBuilder(
                            valueListenable: FDbox!.listenable(),
                            builder: (context, Box<Food_db> items, _) {
                              if (items.isEmpty) {
                                return Center(
                                    child: FutureBuilder<String>(
                                  future:
                                      Translate.translateText("No Items Found"),
                                  builder: (context, snapshot) {
                                    return snapshot.hasData
                                        ? Text(snapshot.data!)
                                        : Text("No Items Found");
                                  },
                                ));
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
                                        Navigator.pushNamed(
                                            context, '/fs_product',
                                            arguments: {
                                              'id': item.productId,
                                              'title': item.productTitle,
                                              'price':
                                                  item.productPrice.toInt(),
                                              'image': item.productImg,
                                              'description': item.productDesc,
                                              'shop': item.productOwnership,
                                            });
                                      },
                                      child: Container(
                                        width: 150,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 5),
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
                                                  image: NetworkImage(
                                                      item.productImg),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            FutureBuilder<String>(
                                              future: Translate.translateText(
                                                  item.productTitle),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Text(
                                                    snapshot.data!,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  );
                                                } else {
                                                  return Text(
                                                    item.productTitle,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  );
                                                }
                                              },
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

                  ReviewWidget(
                    productId: productId,
                  ),

                  SizedBox(height: 20),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(comment.profilePhotoUrl),
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
                  // Rest of your UI...
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
                      isProductInCart ? 'Already Added' : 'Add to Cart',
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
    final foodItem =
        FDbox?.values.firstWhere((food) => food.productId == productId);
    final String? itemOwnership = foodItem?.productOwnership;

    final existingItems = _cartBox.values.toList();
    if (existingItems.isNotEmpty) {
      final firstItemOwnership = FDbox?.values
          .firstWhere((food) => food.productId == existingItems.first.ItemId)
          .productOwnership;
      if (firstItemOwnership != itemOwnership) {
        return false;
      }
    }
    return true;
  }

  int getTotalCartItemsCount() {
    final cartItems = _cartBox.values.toList();
    int totalCount = 0;

    for (var item in cartItems) {
      totalCount += item.ItemCount.toInt();
    }

    return totalCount;
  }
}

class Comment {
  final String profilePhotoUrl;
  final String userName;
  final String commentText;
  final int rating;
  final DateTime timestamp;

  Comment({
    required this.profilePhotoUrl,
    required this.userName,
    required this.commentText,
    required this.rating,
    required this.timestamp,
  });
}

class ReviewWidget extends StatefulWidget {
  final String productId;
  const ReviewWidget({super.key, required this.productId});

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  double overallRating = 0.0;
  int totalReviews = 0;
  Map<int, double> starPercentages = {};
  bool hasError = false;
  bool isempty = false;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('fs_comments')
          .where("foodId", isEqualTo: widget.productId)
          .get();

      if (snapshot.docs.isEmpty) {
        // Handle the case when no reviews are found
        setState(() {
          overallRating = 0.0;
          totalReviews = 0;
          starPercentages = {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0};
          isempty = true;
        });
        return; // Exit the function early since there's no data to process
      }

      int totalRatings = 0;
      num totalStars = 0;

      for (final DocumentSnapshot doc in snapshot.docs) {
        totalRatings++;
        totalStars += doc['rating']!;
      }

      if (totalRatings > 0) {
        overallRating = totalStars / totalRatings;
      }

      // Calculate percentage of each star rating
      for (int i = 1; i <= 5; i++) {
        int count = snapshot.docs.where((doc) => doc['rating'] == i).length;
        starPercentages[i] = (count / totalRatings) * 100;
      }

      setState(() {
        totalReviews = totalRatings;
        hasError = false; // Reset error state
      });
    } catch (error) {
      setState(() {
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isempty) {
      // No reviews found
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                '$overallRating',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              for (int i = 0; i < overallRating.round(); i++)
                Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              for (int i = 0; i < 5 - overallRating.round(); i++)
                Icon(
                  Icons.star_border,
                  color: Colors.amber,
                ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '$totalReviews Ratings and $totalReviews Reviews',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 10),
          for (int i = 5; i >= 1; i--)
            Row(
              children: [
                Text('${starPercentages[i]?.toStringAsFixed(1) ?? 0}%'),
                SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (starPercentages[i] ?? 0) / 100,
                  ),
                ),
              ],
            ),
          SizedBox(height: 10),
          Center(child: Text('No comments yet.')),
        ],
      );
    } else if (hasError) {
      return Center(child: Text('Error fetching comments.'));
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                '$overallRating',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              for (int i = 0; i < overallRating.round(); i++)
                Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              for (int i = 0; i < 5 - overallRating.round(); i++)
                Icon(
                  Icons.star_border,
                  color: Colors.amber,
                ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '$totalReviews Ratings and $totalReviews Reviews',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 10),
          for (int i = 5; i >= 1; i--)
            Row(
              children: [
                Text('${starPercentages[i]?.toStringAsFixed(1) ?? 0}%'),
                SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (starPercentages[i] ?? 0) / 100,
                  ),
                ),
              ],
            ),
          SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('fs_comments')
                .where("foodId", isEqualTo: widget.productId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final String username = doc['userName'] ?? 'Anonymous';
                      final double rating = doc['rating'];
                      final String comment = doc['comments'] ?? '';
                      final String timestamp = doc['timestamp'];

                      return ListTile(
                        title: Text(username),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                for (int i = 0; i < rating; i++)
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                for (int i = 0; i < 5 - rating; i++)
                                  Icon(
                                    Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                              ],
                            ),
                            Text(comment),
                            Text(timestamp,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No comments yet.'));
                }
              } else if (snapshot.hasError) {
                return Center(child: Text('Error fetching comments.'));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      );
    }
  }
}
