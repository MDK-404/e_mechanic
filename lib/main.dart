import 'package:e_mechanic/screens/customer_home.dart';
import 'package:e_mechanic/screens/customer_login.dart';
import 'package:e_mechanic/screens/main_screen.dart';
//import 'package:e_mechanic/screens/otp.dart';
import 'package:e_mechanic/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Mechanic',
      theme: ThemeData(
        // Light mode theme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
        brightness: Brightness.light, // Light mode ki brightness set karna
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        // Dark mode theme
        brightness: Brightness.dark, // Dark mode ki brightness set karna
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      themeMode: ThemeMode.system, // System ke mode ke hisaab se change karega
      home: const SplashScreen(),
      routes: {
        'splash': (context) => const SplashScreen(),
        'mainscreen': (context) => MainScreen(),
        'customerLogin': (context) => CustomerLogin(),
        //'otp': (context) => MyVerify(verificationid: 'verificationid',),
        'customer_home': (context) => CustomerHomeScreen(),
      },
    );
  }
}
