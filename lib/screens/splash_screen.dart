import 'dart:async';
import 'package:e_mechanic/screens/customer_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      Timer(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerHomeScreen()),
        );
      });
    } else {
      Timer(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Background image
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              // width: double.infinity,
            ),
            // SizedBox for spacing
            SizedBox(height: 10),
            // Welcome text
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 30,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            // SizedBox for spacing
            SizedBox(height: 10),
            // Let's get started text button
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
              child: Text(
                "Let's get started",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
