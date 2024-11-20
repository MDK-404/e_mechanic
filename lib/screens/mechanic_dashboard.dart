import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_mechanic/screens/mechanic_navbar.dart';

class MechanicDashboard extends StatefulWidget {
  const MechanicDashboard({Key? key}) : super(key: key);

  @override
  _MechanicDashboardState createState() => _MechanicDashboardState();
}

class _MechanicDashboardState extends State<MechanicDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to log out the user
  Future<void> _logout() async {
    try {
      await _auth.signOut(); // Logs out from Firebase
      Navigator.pushReplacementNamed(
          context, 'main_screen'); // Navigates to main screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanic Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _logout(); // Call the logout function
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Welcome to Mechanic Dashboard!'),
      ),
      bottomNavigationBar: MechanicBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            // Home (Current Screen)
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
