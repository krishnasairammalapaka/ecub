import 'package:collection/collection.dart';
import 'package:ecub_s1_v2/translation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecub_s1_v2/models/Favourites_DB.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/components/bottom_nav_fs.dart';

class FS_FavoriteScreen extends StatefulWidget {
  @override
  _FS_FavoriteScreenState createState() => _FS_FavoriteScreenState();
}

class _FS_FavoriteScreenState extends State<FS_FavoriteScreen> with RouteAware {
  int _selectedIndex = 2; // Index for the Favorite screen
  Box<Favourites_DB>? _favouritesBox;
  Box<Food_db>? FDbox;

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    ModalRoute.of(context)!.settings.arguments;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openBoxes() async {
    _favouritesBox = await Hive.openBox<Favourites_DB>('favouritesDbBox');
    FDbox = await Hive.openBox<Food_db>('foodDbBox');
    setState(() {});
  }

  void _deleteFavoriteItem(String productId) {
    var favoriteItemKey = _favouritesBox!.keys.firstWhere((key) {
      var item = _favouritesBox!.get(key);
      return item != null && item.ItemId == productId;
    });
    _favouritesBox!.delete(favoriteItemKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _favouritesBox == null || FDbox == null
                  ? Center(child: CircularProgressIndicator())
                  : ValueListenableBuilder(
                      valueListenable: _favouritesBox!.listenable(),
                      builder: (context, Box<Favourites_DB> items, _) {
                        if (items.isEmpty) {
                          return Center(
                              child: FutureBuilder<String>(
                            future:
                                Translate.translateText('No favorite items.'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else {
                                return snapshot.hasData
                                    ? Text(snapshot.data!)
                                    : Text('No favorite items.');
                              }
                            },
                          ));
                        } else {
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              var item = items.getAt(index);
                              if (item == null) {
                                return Center(
                                    child: FutureBuilder<String>(
                                  future: Translate.translateText(
                                      'No Items Found.'),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else {
                                      return snapshot.hasData
                                          ? Text(snapshot.data!)
                                          : Text('No Items Found.');
                                    }
                                  },
                                ));
                              }

                              var productId = item.ItemId;
                              var productDetails = FDbox!.values
                                  .firstWhereOrNull((element) =>
                                      element.productId == productId);

                              if (productDetails == null) {
                                return Center(
                                    child: FutureBuilder<String>(
                                  future: Translate.translateText(
                                      'Products Not found.'),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else {
                                      return snapshot.hasData
                                          ? Text(snapshot.data!)
                                          : Text('products Not Found.');
                                    }
                                  },
                                ));
                              }

                              return GestureDetector(
                                onTap: () {},
                                child: FutureBuilder<List<String?>>(
                                  future: Future.wait([
                                    Translate.translateText(
                                        productDetails.productTitle),
                                    Translate.translateText(
                                        productDetails.productOwnership),
                                    Translate.translateText(productDetails
                                        .productRating
                                        .toString()), // Assuming rating is numeric
                                    Translate.translateText(productDetails
                                        .productPrepTime), // If this needs translation
                                  ]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Transform.scale(
                                        scale:
                                            0.5, // Adjust the scale factor as needed
                                        child: CircularProgressIndicator(),
                                      ); // Show loading indicator while translating
                                    } else if (snapshot.hasData &&
                                        snapshot.data!.every(
                                            (element) => element != null)) {
                                      return RestaurantCard(
                                        name: snapshot.data![
                                            0]!, // Translated product title
                                        location: snapshot.data![
                                            1]!, // Translated product ownership
                                        rating: double.tryParse(
                                                snapshot.data![2]!) ??
                                            productDetails
                                                .productRating, // Translated rating
                                        deliveryTime: snapshot
                                            .data![3]!, // Translated prep time
                                        imageUrl: productDetails.productImg,
                                        isHomeMade:
                                            productDetails.productType ==
                                                'home-made',
                                        onDelete: () =>
                                            _deleteFavoriteItem(productId),
                                      );
                                    } else {
                                      // Fallback to original details if translation fails
                                      return RestaurantCard(
                                        name: productDetails.productTitle,
                                        location:
                                            productDetails.productOwnership,
                                        rating: productDetails.productRating,
                                        deliveryTime:
                                            productDetails.productPrepTime,
                                        imageUrl: productDetails.productImg,
                                        isHomeMade:
                                            productDetails.productType ==
                                                'home-made',
                                        onDelete: () =>
                                            _deleteFavoriteItem(productId),
                                      );
                                    }
                                  },
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
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String deliveryTime;
  final String imageUrl;
  final bool isHomeMade;
  final VoidCallback onDelete;

  RestaurantCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.deliveryTime,
    required this.imageUrl,
    required this.isHomeMade,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(location),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow[700]),
                      SizedBox(width: 5),
                      Text('$rating'),
                      SizedBox(width: 10),
                      Icon(Icons.timer, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(deliveryTime),
                    ],
                  ),
                  if (isHomeMade)
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Home-made',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
