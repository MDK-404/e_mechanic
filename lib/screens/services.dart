import 'package:e_mechanic/screens/bookappoitnment.dart';
import 'package:e_mechanic/screens/customer_home.dart';
import 'package:e_mechanic/screens/navbar.dart';
import 'package:e_mechanic/screens/navigationhandler.dart';
import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, 'customer_home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, 'services');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, 'customer_profile');
          }
        },
        currentIndex: 1,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card displaying "Services"
          Card(
            elevation: 4.0,
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Services',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Column(
            children: [
              buildServiceRow(context, 'Autoparts', AutopartsScreen()),
              Divider(),
            ],
          ),
          Column(
            children: [
              buildServiceRow(
                  context, 'Book Appointments', BookAppointmentScreen()),
              Divider(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildServiceRow(
      BuildContext context, String serviceName, Widget destinationScreen) {
    return GestureDetector(
      onTap: () {
        // Navigate to destination screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                serviceName,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Icon(Icons.arrow_forward_ios), // Arrow icon
          ],
        ),
      ),
    );
  }
}

class AutopartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Autoparts'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Autoparts Screen'), // Placeholder for Autoparts screen
      ),
    );
  }
}
