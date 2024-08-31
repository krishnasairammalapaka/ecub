import 'package:ecub_s1_v2/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecub_s1_v2/pages/home/auth.dart';
import 'package:ecub_s1_v2/pages/home/home.dart';
import 'package:ecub_s1_v2/pages/intro/intro.dart';
import 'package:ecub_s1_v2/pages/sign_pages/forget_password.dart';
import 'package:ecub_s1_v2/pages/sign_pages/login_page.dart';
import 'package:ecub_s1_v2/pages/sign_pages/registration_page.dart';
import 'package:ecub_s1_v2/coming_soon.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_CategoryScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/SubscriptionModule/FS_S_Checkout.dart';
import 'package:ecub_s1_v2/service_page/FoodService/SubscriptionModule/FS_S_Desc.dart';
import 'package:ecub_s1_v2/service_page/FoodService/SubscriptionModule/FS_S_Home.dart';
import 'package:ecub_s1_v2/service_page/FoodService/SubscriptionModule/FS_S_PackChange.dart';
import 'package:ecub_s1_v2/service_page/FoodService/SubscriptionModule/FS_S_PackCheck.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_cart.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_home.dart';
// import 'package:ecub_s1_v2/service_page/medical_equipment/me_item_details.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_orders.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
// ---------- Food Service --------
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Hotels_Db.dart';
import 'package:ecub_s1_v2/models/Cart_Db.dart';
import 'package:ecub_s1_v2/models/Favourites_DB.dart';
import 'package:ecub_s1_v2/models/CheckoutHistory_DB.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_DeliveryTrackingScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_Profile.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_FavoriteScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_HomeScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_ProductScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_RestaurantScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_DishesScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_CartScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_CheckoutScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_Search.dart';



Future<void> syncFoodDbWithFirestore() async {
  CollectionReference foodCollection = FirebaseFirestore.instance.collection('fs_food_items1');

  var foodBox = await Hive.openBox<Food_db>('foodDbBox');

  QuerySnapshot querySnapshot = await foodCollection.get();

  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;

    Food_db foodItem = Food_db(
      productId: data['productId'] ?? '',
      productTitle: data['productTitle'] ?? '',
      productPrice: data['productPrice'] ?? 0.0,
      productImg: data['productImg'] ?? '',
      productDesc: data['productDesc'] ?? '',
      productOwnership: data['productOwnership'] ?? '',
      productRating: 0.0,
      productOffer:  0.0,
      productMainCategory: data['productMainCategory'] ?? '',
      productPrepTime: data['productPrepTime'] ?? '',
      productType: data['productType'] ?? '',
      calories: 150,
    );

    // Add or update the item in Hive
    foodBox.put(doc.id, foodItem);
  }
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  // ignore: unused_local_variable
  var box = await Hive.openBox('user_data');

  // ------------- Food Service ---------------
  Hive.registerAdapter<Cart_Db>(CartDbAdapter());
  Hive.registerAdapter<Food_db>(FooddbAdapter());
  Hive.registerAdapter<Favourites_DB>(FavouritesDBAdapter());
  Hive.registerAdapter<CheckoutHistory_DB>(CheckoutHistoryDBAdapter());

  await Hive.openBox('Cart_Db');

  // Open boxes
  var appBox = await Hive.openBox("appdb");
  var loginBox = await Hive.openBox("login_state");
  var foodBox = await Hive.openBox<Food_db>('foodDbBox');

  // Store static data only if the box is empty
  await syncFoodDbWithFirestore();



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      routes: {
        '/intro': (context) => IntroPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/forget_password': (context) => ForgetPassword(),
        '/home': (context) => HomePage(),
        '/dc': (context) => ComingSoon(),
        '/cs': (context) => ComingSoon(),
        '/rb': (context) => ComingSoon(),
        '/fo': (context) => FS_HomeScreen(),
        '/me': (context) => MeHomePage(),
        '/me_cart': (context) => Mecart(),
        '/me_orders': (context) => MeOrders(),

        // #FoodService Module Pages
        '/fs_home': (context) => FS_HomeScreen(),
        '/fs_product': (context) => FS_ProductScreen(),
        '/fs_cart': (context) => FS_CartScreen(),
        '/fs_checkout': (context) => FS_CheckoutScreen(),
        '/fs_delivery': (context) => FS_DeliveryTrackingScreen(),

        '/fs_dishes': (context) => FS_DishesScreen(),
        '/fs_hotel': (context) => FS_RestaurantScreen(),
        '/fs_search': (context) => FS_Search(),
        '/fs_favourite': (context) => FS_FavoriteScreen(),
        '/fs_profile': (context) => FS_Profile(),
        '/fs_category': (context) => FS_CategoryScreen(),

        '/fs_s_home': (context) => FS_S_Home(),
        '/fs_s_desc': (context) => FS_S_Desc(),
        '/fs_s_checkout': (context) => FS_S_Checkout(),
        '/fs_s_packcheck': (context) => FS_S_PackCheck(),
        '/fs_s_packchange': (context) => FS_S_PackChange(),
      },
    );
  }
}
