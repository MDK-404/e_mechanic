import 'package:e_mechanic/screens/mechanic_navbar.dart';
import 'package:flutter/material.dart';

class MechanicDashboard extends StatefulWidget {
  const MechanicDashboard({Key? key}) : super(key: key);

  @override
  _MechanicDashboardState createState() => _MechanicDashboardState();
}

class _MechanicDashboardState extends State<MechanicDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mechanic Dashboard'),
      ),
      body: Center(),
      bottomNavigationBar: MechanicBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
          } else if (index == 1) {
            Navigator.pushNamed(context, 'addproducts');
          } else if (index == 2) {
            Navigator.pushNamed(context, 'mechanic_profile');
          }
        },
        currentIndex: 0,
      ),
    );
  }
}
