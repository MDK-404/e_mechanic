import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/screens/customer_home.dart';
import 'package:e_mechanic/screens/main_screen.dart';
import 'package:e_mechanic/screens/mechanic_dashboard.dart';
import 'package:e_mechanic/screens/customer_login.dart';
import 'package:e_mechanic/screens/mechanic_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
        var currentUser = auth.currentUser!;
        var phoneNumber = currentUser.phoneNumber;
        // Check if user exists in the customer collection
        FirebaseFirestore.instance
            .collection('customers')
            .doc(phoneNumber)
            .get()
            .then((customerSnapshot) {
          if (customerSnapshot.exists) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => CustomerHomeScreen()));
          } else {
            // Check if user exists in the mechanic collection
            FirebaseFirestore.instance
                .collection('mechanics')
                .doc(phoneNumber)
                .get()
                .then((mechanicSnapshot) {
              if (mechanicSnapshot.exists) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MechanicDashboard()));
              } else {
                // User not found in either collection, redirect to main screen
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MainScreen()));
              }
            });
          }
        });
      });
    } else {
      Timer(Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
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
            // Your SplashScreen UI components here
          ],
        ),
      ),
    );
  }
}
