import 'package:flutter/material.dart';
import 'package:e_mechanic/screens/customer_home.dart';
import 'package:e_mechanic/screens/services.dart';

class NavigationHandler {
  static void handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Navigate to Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerHomeScreen()),
        );
        break;
      case 1:
        // Navigate to Services screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ServicesScreen()),
        );
        break;
      case 2:
        // Navigate to Settings screen
        // Implement your navigation logic here
        break;
      case 3:
        // Navigate to Profile screen
        // Implement your navigation logic here
        break;
      default:
        // Do nothing
        break;
    }
  }
}
