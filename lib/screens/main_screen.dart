import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  String userType = ""; // UserType variable declare karo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        // AppBar mein decoration set karna
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.orange, // Border color set karna
                width: 2.0,
              ),
              // Border ki width set karna
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white
                    .withOpacity(0.5), // Shadow ka color aur opacity
                spreadRadius: 4, // Shadow ka spread radius
                blurRadius: 8, // Shadow ka blur radius
                offset: Offset(0, 4), // Shadow ki position set karna
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
                      color: Colors.orange, // E ko orange color set karna
                    ),
                  ),
                  TextSpan(
                    text: '-Mechanic',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      color:
                          Colors.black, // Baaki text ko white color set karna
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
            // Customer section container
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
                      Navigator.pushNamed(context, 'bookappointment');
                      userType = "customer"; // Customer type select karo
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
            // Mechanic section container
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
                      Navigator.pushNamed(context, 'mechanic_login');
                      userType = "mechanic";

                      // Mechanic type select karo
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
