import 'package:ecub_s1_v2/firebase_options.dart';
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


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  // ignore: unused_local_variable
  var box=await Hive.openBox('user_data');

  // ------------- Food Service ---------------
  Hive.registerAdapter<Cart_Db>(CartDbAdapter());
  Hive.registerAdapter<Food_db>(FooddbAdapter());
  Hive.registerAdapter<Hotels_Db>(HotelsDbAdapter());
  Hive.registerAdapter<Favourites_DB>(FavouritesDBAdapter());
  Hive.registerAdapter<CheckoutHistory_DB>(CheckoutHistoryDBAdapter());



  await Hive.openBox('Cart_Db');

  // Open boxes
  var appBox = await Hive.openBox("appdb");
  var loginBox = await Hive.openBox("login_state");
  var foodBox = await Hive.openBox<Food_db>('foodDbBox');
  var hotelBox = await Hive.openBox<Hotels_Db>('hotelDbBox');



  // Store static data only if the box is empty
  if (foodBox.isEmpty) {
    var foodDBItems = [
      Food_db(
        productId: '1',
        productTitle: 'Steak',
        productPrice: 120.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/steak.png',
        productDesc:
            'Delicious and juicy steak with garlic and butter, served with asparagus.',
        productOwnership: 'ks-bakers',
        productRating: 4.1,
        productOffer: 10,
        productMainCategory: "biriyani",
        productPrepTime: "20 - 30 mins",
        productType: "restaurant",
        calories: 600,
      ),
      Food_db(
        productId: '2',
        productTitle: 'Chicken Quinoa',
        productPrice: 80.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/quinoa.png',
        productDesc:
            'Healthy and flavorful dish with grilled chicken, quinoa, and Mediterranean spices.',
        productOwnership: 'chennai-bakers',
        productRating: 4.7,
        productOffer: 5,
        productMainCategory: "chicken",
        productPrepTime: "20 - 30 mins",
        productType: "restaurant",
        calories: 450,
      ),
      Food_db(
        productId: '3',
        productTitle: 'French Fries',
        productPrice: 40.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/frfi.jpeg',
        productDesc: 'Crispy and golden french fries.',
        productOwnership: 'chennai-bakers',
        productRating: 4.1,
        productOffer: 5,
        productMainCategory: "side-dish",
        productPrepTime: "20 - 30 mins",
        productType: "restaurant",
        calories: 300,
      ),
      Food_db(
        productId: '4',
        productTitle: 'Chicken Quinoa',
        productPrice: 45.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/quinoa.png',
        productDesc:
            'Healthy and flavorful dish with grilled chicken, quinoa, and Mediterranean spices.',
        productOwnership: 'chennai-bakers',
        productRating: 4.0,
        productOffer: 5,
        productMainCategory: "chicken",
        productPrepTime: "20 - 30 mins",
        productType: "restaurant",
        calories: 450,
      ),
      Food_db(
        productId: '5',
        productTitle: 'Veggie Pizza',
        productPrice: 60.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/pizza.jpg',
        productDesc:
            'Classic pizza topped with fresh vegetables, mozzarella cheese, and tomato sauce.',
        productOwnership: 'ks-bakers',
        productRating: 4.8,
        productOffer: 15,
        productMainCategory: "pizza",
        productPrepTime: "15 - 20 mins",
        productType: "restaurant",
        calories: 500,
      ),
      Food_db(
        productId: '6',
        productTitle: 'Pasta Carbonara',
        productPrice: 70.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/pasta.jpg',
        productDesc:
            'Creamy pasta carbonara with bacon, parmesan cheese, and black pepper.',
        productOwnership: 'chennai-bakers',
        productRating: 4.3,
        productOffer: 10,
        productMainCategory: "pasta",
        productPrepTime: "25 - 30 mins",
        productType: "restaurant",
        calories: 550,
      ),
      Food_db(
        productId: '7',
        productTitle: 'Grilled Salmon',
        productPrice: 150.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/Salmon.jpg',
        productDesc:
            'Freshly grilled salmon fillet served with lemon butter sauce and vegetables.',
        productOwnership: 'ks-bakers',
        productRating: 4.9,
        productOffer: 20,
        productMainCategory: "seafood",
        productPrepTime: "30 - 35 mins",
        productType: "restaurant",
        calories: 400,
      ),
      Food_db(
        productId: '8',
        productTitle: 'Caesar Salad',
        productPrice: 50.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/salad.jpg',
        productDesc:
            'Crispy romaine lettuce, croutons, parmesan cheese, and Caesar dressing.',
        productOwnership: 'chennai-bakers',
        productRating: 4.3,
        productOffer: 5,
        productMainCategory: "salad",
        productPrepTime: "10 - 15 mins",
        productType: "restaurant",
        calories: 350,
      ),
      Food_db(
        productId: '9',
        productTitle: 'Beef Burger',
        productPrice: 90.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/burger.jpg',
        productDesc:
            'Juicy beef patty with lettuce, tomato, cheese, and special sauce in a sesame bun.',
        productOwnership: 'ks-bakers',
        productRating: 4.7,
        productOffer: 10,
        productMainCategory: "burger",
        productPrepTime: "20 - 25 mins",
        productType: "restaurant",
        calories: 700,
      ),
      Food_db(
        productId: '10',
        productTitle: 'Chocolate Cake',
        productPrice: 60.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/cake.jpg',
        productDesc:
            'Rich and moist chocolate cake with a creamy chocolate frosting.',
        productOwnership: 'chennai-bakers',
        productRating: 4.9,
        productOffer: 20,
        productMainCategory: "dessert",
        productPrepTime: "45 - 50 mins",
        productType: "restaurant",
        calories: 600,
      ),
      Food_db(
        productId: '11',
        productTitle: 'Apple Pie',
        productPrice: 55.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/apple_pie.jpg',
        productDesc:
            'Classic homemade apple pie with a flaky crust and sweet apple filling.',
        productOwnership: 'home-chef-sara',
        productRating: 4.1,
        productOffer: 10,
        productMainCategory: "dessert",
        productPrepTime: "60 - 70 mins",
        productType: "homemade",
        calories: 450,
      ),
      Food_db(
        productId: '12',
        productTitle: 'Lasagna',
        productPrice: 90.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/lasagna.jpg',
        productDesc:
            'Layered lasagna with rich meat sauce, creamy ricotta, and melted mozzarella.',
        productOwnership: 'home-chef-john',
        productRating: 4.2,
        productOffer: 15,
        productMainCategory: "pasta",
        productPrepTime: "80 - 90 mins",
        productType: "homemade",
        calories: 800,
      ),
      Food_db(
        productId: '13',
        productTitle: 'Chicken Curry',
        productPrice: 70.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/chicken_curry.jpg',
        productDesc:
            'Spicy and flavorful chicken curry made with fresh spices and herbs.',
        productOwnership: 'home-chef-anita',
        productRating: 4.7,
        productOffer: 10,
        productMainCategory: "chicken",
        productPrepTime: "45 - 55 mins",
        productType: "homemade",
        calories: 500,
      ),
      Food_db(
        productId: '14',
        productTitle: 'Vegetable Stir-fry',
        productPrice: 50.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/veg_stirfry.jpg',
        productDesc:
            'Fresh and crunchy vegetable stir-fry with a tangy soy sauce.',
        productOwnership: 'home-chef-lee',
        productRating: 4.6,
        productOffer: 5,
        productMainCategory: "vegetarian",
        productPrepTime: "25 - 35 mins",
        productType: "homemade",
        calories: 300,
      ),
      Food_db(
        productId: '15',
        productTitle: 'Banana Bread',
        productPrice: 40.00,
        productImg: 'https://raw.githubusercontent.com/karuppan-the-pentester/ImagesDB/master/assets/foods/banana_bread.jpg',
        productDesc:
            'Moist and flavorful banana bread with a hint of cinnamon.',
        productOwnership: 'home-chef-emma',
        productRating: 4.4,
        productOffer: 10,
        productMainCategory: "dessert",
        productPrepTime: "50 - 60 mins",
        productType: "homemade",
        calories: 350,
      ),
    ];

    for (var item in foodDBItems) {
      foodBox.add(item);
    }
  }

  if (hotelBox.isEmpty) {
    var hotelDbItems = [
      Hotels_Db(
          hotelId: "1",
          hotelName: "KS Bakers",
          hotelMail: "ksbakers@gmail.com",
          hotelAddress: "KodomBakkam",
          hotelPhoneNo: "8778997952",
          hotelUsername: "ks-bakers",
          hotelType: "restaurant"),
      Hotels_Db(
          hotelId: "2",
          hotelName: "Chennai Bakers",
          hotelMail: "chennaibakers@gmail.com",
          hotelAddress: "POES Garden",
          hotelPhoneNo: "8778997952",
          hotelUsername: "chennai-bakers",
          hotelType: "restaurant"),
      Hotels_Db(
          hotelId: "8",
          hotelName: "Sangai Bakers",
          hotelMail: "sangaibakers@gmail.com",
          hotelAddress: "Chintai Chandranagar",
          hotelPhoneNo: "8778997952",
          hotelUsername: "sangai-bakers",
          hotelType: "restaurant"),
      Hotels_Db(
          hotelId: "9",
          hotelName: "Trichy Bakers",
          hotelMail: "Trichybakers@gmail.com",
          hotelAddress: "Trichy",
          hotelPhoneNo: "8778997952",
          hotelUsername: "trichy-bakers",
          hotelType: "restaurant"),
      Hotels_Db(
          hotelId: "3",
          hotelName: "Home Chef Sara",
          hotelMail: "sara@gmail.com",
          hotelAddress: "Saravanampatti",
          hotelPhoneNo: "9876543210",
          hotelUsername: "home-chef-sara",
          hotelType: "homemade"),
      Hotels_Db(
          hotelId: "4",
          hotelName: "Home Chef John",
          hotelMail: "john@gmail.com",
          hotelAddress: "Coimbatore",
          hotelPhoneNo: "9876543211",
          hotelUsername: "home-chef-john",
          hotelType: "homemade"),
      Hotels_Db(
          hotelId: "5",
          hotelName: "Home Chef Anita",
          hotelMail: "anita@gmail.com",
          hotelAddress: "Salem",
          hotelPhoneNo: "9876543212",
          hotelUsername: "home-chef-anita",
          hotelType: "homemade"),
      Hotels_Db(
          hotelId: "6",
          hotelName: "Home Chef Lee",
          hotelMail: "lee@gmail.com",
          hotelAddress: "Erode",
          hotelPhoneNo: "9876543213",
          hotelUsername: "home-chef-lee",
          hotelType: "homemade"),
      Hotels_Db(
          hotelId: "7",
          hotelName: "Home Chef Emma",
          hotelMail: "emma@gmail.com",
          hotelAddress: "Madurai",
          hotelPhoneNo: "9876543214",
          hotelUsername: "home-chef-emma",
          hotelType: "homemade"),
    ];

    for (var item in hotelDbItems) {
      hotelBox.add(item);
    }
  }

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
      
      },
    );
  }
}
