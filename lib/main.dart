import 'package:ecub_s1_v2/firebase_options.dart';
import 'package:ecub_s1_v2/pages/home/auth.dart';
import 'package:ecub_s1_v2/pages/home/home.dart';
import 'package:ecub_s1_v2/pages/intro/intro.dart';
import 'package:ecub_s1_v2/pages/sign_pages/forget_password.dart';
import 'package:ecub_s1_v2/pages/sign_pages/login_page.dart';
import 'package:ecub_s1_v2/pages/sign_pages/registration_page.dart';
import 'package:ecub_s1_v2/coming_soon.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_cart.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_home.dart';
import 'package:ecub_s1_v2/service_page/medical_equipment/me_orders.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        '/signup': (context) => RegistrationPage(),
        '/forget_password': (context) => ForgetPassword(),
        '/home': (context) => HomePage(),
        '/dc': (context) => ComingSoon(),
        '/cs': (context) => ComingSoon(),
        '/rb': (context) => ComingSoon(),
        '/fo': (context) => ComingSoon(),
        '/me': (context) => MeHomePage(),
        '/me_cart': (context) => Mecart(),
        '/me_orders': (context) => MeOrders(),
      },
    );
  }
}
