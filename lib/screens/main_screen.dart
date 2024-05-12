import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_mechanic/provider/user_type_provider.dart'; // Import UserTypeProvider
import 'package:e_mechanic/screens/customer_login.dart';
// import 'package:e_mechanic/screens/mechanic_login.dart';
import 'package:e_mechanic/utils/shared_preferences.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.orange,
                width: 2.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                spreadRadius: 4,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'E',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      color: Colors.orange,
                    ),
                  ),
                  TextSpan(
                    text: '-Mechanic',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50),
            Container(
              height: 250,
              margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/customer_login.jpeg',
                    width: 250,
                    height: 100,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Set userType to customer
                      SharedPreferencesUtils.setUserType('customer');
                      Navigator.pushNamed(context, 'customerLogin');
                    },
                    child: Text(
                      'Customer Login',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Container(
              height: 250,
              margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/mechanic.png',
                    width: 250,
                    height: 100,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Set userType to mechanic
                      SharedPreferencesUtils.setUserType('mechanic');
                      Navigator.pushNamed(context, 'customerLogin');
                    },
                    child: Text(
                      'Mechanic Login',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
