import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/screens/customer_home.dart';
import 'package:e_mechanic/screens/main_screen.dart';
import 'package:e_mechanic/screens/mechanic_dashboard.dart';
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
    navigateUser();
  }

  void navigateUser() {
    Timer(Duration(seconds: 5), () async {
      if (auth.currentUser != null) {
        var currentUser = auth.currentUser!;
        var phoneNumber = currentUser.phoneNumber;
        // Check if user exists in the customer collection
        DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
            .collection('customers')
            .doc(phoneNumber)
            .get();
        if (customerSnapshot.exists) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CustomerHomeScreen()));
        } else {
          // Check if user exists in the mechanic collection
          DocumentSnapshot mechanicSnapshot = await FirebaseFirestore.instance
              .collection('mechanics')
              .doc(phoneNumber)
              .get();
          if (mechanicSnapshot.exists) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => MechanicDashboard()));
          } else {
            // User not found in either collection, redirect to main screen
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MainScreen()));
          }
        }
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      }
    });
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
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => MainScreen()),
                // );
                navigateUser();
              },
              child: Text(
                "Let's get started",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
