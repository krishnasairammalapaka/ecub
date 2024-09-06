import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Import your models and pages
import 'firebase_options.dart';
import 'package:ecub_s1_v2/pages/home/auth.dart';
import 'package:ecub_s1_v2/pages/intro/intro.dart';
import 'package:ecub_s1_v2/pages/sign_pages/forget_password.dart';
import 'package:ecub_s1_v2/pages/sign_pages/login_page.dart';
import 'package:ecub_s1_v2/pages/sign_pages/registration_page.dart';
import 'package:ecub_s1_v2/coming_soon.dart';
import 'package:ecub_s1_v2/pages/home/home.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_CartScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_CheckoutScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_DeliveryTrackingScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_DishesScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_FavoriteScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_HomeScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_ProductScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_Profile.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_RestaurantScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_Search.dart';
import 'package:ecub_s1_v2/service_page/FoodService/FS_CategoryScreen.dart';
import 'package:ecub_s1_v2/service_page/FoodService/SubscriptionModule/FS_S_Checkout.dart';
import 'package:ecub_s1_v2/service_page/FoodService/SubscriptionModule/FS_S_Desc.dart';
import 'package:ecub_s1_v2/service_page/FoodService/SubscriptionModule/FS_S_Home.dart';
import 'package:ecub_s1_v2/service_page/FoodService/SubscriptionModule/FS_S_PackChange.dart';
import 'package:ecub_s1_v2/service_page/FoodService/SubscriptionModule/FS_S_PackCheck.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_cart.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_home.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_orders.dart';

import 'package:ecub_s1_v2/models/Food_db.dart';
import 'package:ecub_s1_v2/models/Cart_Db.dart';
import 'package:ecub_s1_v2/models/Favourites_DB.dart';
import 'package:ecub_s1_v2/models/CheckoutHistory_DB.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();





Future<void> syncFoodDbWithFirestore() async {
  CollectionReference foodCollection = FirebaseFirestore.instance.collection('fs_food_items1');
  var foodBox = await Hive.openBox<Food_db>('foodDbBox');

  QuerySnapshot querySnapshot = await foodCollection.get();
  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;

    // Create a Food_db instance from Firestore data
    Food_db foodItem = Food_db(
      productId: data['productId'] ?? '',
      productTitle: data['productTitle'] ?? '',
      productPrice: data['productPrice'] ?? 0.0,
      productImg: data['productImg'] ?? '',
      productDesc: data['productDesc'] ?? '',
      productOwnership: data['productOwnership'] ?? '',
      productRating: data['productRating'] ?? 3.0,
      productOffer: 0.0,
      productMainCategory: data['productMainCategory'] ?? '',
      productPrepTime: data['productPrepTime'] ?? '',
      productType: data['productType'] ?? '',
      calories: 150,
    );
    // Store the item in the Hive box
    foodBox.put(doc.id, foodItem);
  }
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");

  if (message.notification != null) {
    OrderNotification({
      'title': message.notification!.title,
      'description': message.notification!.body
    });
  }
}


void OrderNotification(Map<String, dynamic> data) async {
  var androidDetails = AndroidNotificationDetails(
    'channelId',
    'channelName',
    channelDescription: 'Your channel description',
    importance: Importance.max,
    priority: Priority.high,
  );

  var notificationDetails = NotificationDetails(android: androidDetails);

  // Customize title and body based on the status update
  String title = data['title'] ?? 'Order Status Updated';
  String body = data['description'] ?? 'Your order status has changed.';

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
  );
}


Future<void> _requestPermissions() async {
  // Request geolocation permission
  PermissionStatus locationPermissionStatus = await Permission.location.request();
  if (!locationPermissionStatus.isGranted) {
    print('Location permission denied.');
    return;
  }

  // Request notification permission
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('Notification permission denied.');
    return;
  }

  print('Permissions granted.');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();



  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _requestPermissions();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Flutter local notifications setup
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await Hive.initFlutter();

  // Register Hive adapters and open Hive boxes
  Hive.registerAdapter<Cart_Db>(CartDbAdapter());
  Hive.registerAdapter<Food_db>(FooddbAdapter());
  Hive.registerAdapter<Favourites_DB>(FavouritesDBAdapter());
  Hive.registerAdapter<CheckoutHistory_DB>(CheckoutHistoryDBAdapter());

  await Hive.openBox('Cart_Db');
  await Hive.openBox('user_data');
  await Hive.openBox('appdb');
  await Hive.openBox<Food_db>('foodDbBox');

  // Sync Firestore data with Hive local database
  await syncFoodDbWithFirestore();

  var user = FirebaseAuth.instance.currentUser;

  String? email = user?.email;
  if (email != null) {
    FirestoreNotificationService.initializeFirestoreListener(email);
  }

  runApp(const MyApp());
}


class FirestoreNotificationService {
  static void initializeFirestoreListener(String userId) {
    FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        print('Document change detected: ${change.type}');
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          print('Data received: $data');
          if (data != null && data['status'] != null) {
            String newStatus = data['status'];
            print('Status changed to: $newStatus');
            OrderNotification({
              'title': 'Order Status Updated',
              'description': 'Your order status has changed to $newStatus.'
            });
          } else {
            print('Status is null or data is null.');
          }
        }
      }
    });
  }


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
