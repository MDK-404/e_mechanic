import 'package:e_mechanic/screens/add_products.dart';
import 'package:e_mechanic/screens/appoinment.dart';
import 'package:e_mechanic/screens/customer_home.dart';
import 'package:e_mechanic/screens/customer_login.dart';
import 'package:e_mechanic/screens/customer_profile.dart';
import 'package:e_mechanic/screens/main_screen.dart';
import 'package:e_mechanic/screens/mechanic_dashboard.dart';
import 'package:e_mechanic/screens/mechanic_login.dart';
import 'package:e_mechanic/screens/mechanic_otp.dart';
import 'package:e_mechanic/screens/mechanic_profile.dart';
import 'package:e_mechanic/screens/otp.dart';
import 'package:e_mechanic/screens/services.dart';
import 'package:e_mechanic/screens/splash_screen.dart';
import 'package:e_mechanic/shop/screens/cart_screen.dart';
import 'package:e_mechanic/shop/screens/product_detail_screen.dart';
import 'package:e_mechanic/shop/screens/product_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        'splash': (context) => const SplashScreen(),
        'mainscreen': (context) => MainScreen(),
        'customerLogin': (context) => CustomerLogin(),
        'customer_home': (context) => CustomerHomeScreen(),
        'customer_profile': (context) => CustomerProfile(),
        'mechanic_dashboard': (context) => MechanicDashboard(),
        'mechanic_profile': (context) => MechanicProfile(),
        'mechanic_login': (context) => MechanicLogin(),
        'addproducts': (context) => AddProductScreen(),
        'appoitnment': (context) => AppointmentScreen(),
        'services': (context) => ServicesScreen(),
        'cart': (context) => CartScreen(),
        'product_list': (context) => ProductListScreen(),
        'mechanic_otp': (context) => OTPVerification(
              verificationid: 'verificationid',
            ),

        // below otp verification route is  for user
        'otp': (context) => MyVerify(
              verificationid: 'verificationid',
            ),
      },
    );
  }
}
