import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/screens/customer_home.dart';
import 'package:e_mechanic/screens/main_screen.dart';
import 'package:e_mechanic/screens/mechanic_dashboard.dart';
import 'package:e_mechanic/shop/models/customer_model.dart';
import 'package:e_mechanic/shop/services/fcm_service.dart';
import 'package:e_mechanic/shop/services/notifications_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final auth = FirebaseAuth.instance;
  NotificationService notificationService = NotificationService();
  @override
  void initState() {
    _initializeApp();
    super.initState();
    notificationService.requestNotificationPermission();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    navigateUser();
    FcmService.firebaseInit();
  }

  Future<void> _initializeApp() async {
    User? user = FirebaseAuth.instance.currentUser;
    await _saveDeviceToken(user);
    // Add navigation logic if needed
  }

  Future<void> _saveDeviceToken(User? user) async {
    if (user != null) {
      FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        try {
          // Check if the user exists in the 'mechanics' collection
          DocumentReference mechanicDocRef =
              FirebaseFirestore.instance.collection('mechanics').doc(user.uid);
          DocumentSnapshot mechanicDocSnapshot = await mechanicDocRef.get();

          if (mechanicDocSnapshot.exists) {
            // Save token in the 'mechanics' collection
            await mechanicDocRef.update({'deviceToken': token});
            print("Device token saved in mechanics collection: $token");
          } else {
            // Check if the user exists in the 'customers' collection
            DocumentReference customerDocRef = FirebaseFirestore.instance
                .collection('customers')
                .doc(user.uid);
            DocumentSnapshot customerDocSnapshot = await customerDocRef.get();

            if (customerDocSnapshot.exists) {
              // Save token in the 'customers' collection
              await customerDocRef.update({'deviceToken': token});
              print("Device token saved in customers collection: $token");
            } else {
              print(
                  "User not found in either mechanics or customers collections.");
            }
          }
        } catch (e) {
          print("Error saving device token: $e");
        }
      }
    }
  }

  void navigateUser() {
    Timer(const Duration(seconds: 3), () async {
      if (auth.currentUser != null) {
        var currentUser = auth.currentUser!;
        var uid = currentUser.uid; // Use UID instead of phone number

        try {
          // Check if user exists in the customer collection
          DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
              .collection('customers')
              .doc(uid)
              .get();
          if (customerSnapshot.exists) {
            // Navigate to customer home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CustomerHomeScreen()),
            );
          } else {
            // Check if user exists in the mechanic collection
            DocumentSnapshot mechanicSnapshot = await FirebaseFirestore.instance
                .collection('mechanics')
                .doc(uid)
                .get();
            if (mechanicSnapshot.exists) {
              // Navigate to mechanic dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MechanicDashboard()),
              );
            } else {
              // User not found in either collection, redirect to main screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            }
          }
        } catch (e) {
          // Handle errors (e.g., network issues)
          print('Error fetching user data: $e');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      } else {
        // No user is logged in, redirect to main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
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
            ),
            // SizedBox for spacing
            const SizedBox(height: 10),
            // Welcome text
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 30,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            // SizedBox for spacing
            const SizedBox(height: 10),
            // Let's get started text button
            TextButton(
              onPressed: () {
                navigateUser();
              },
              child: const Text(
                "Let's get started",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
