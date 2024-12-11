import 'package:e_mechanic/screens/mechanic_navbar.dart';
import 'package:e_mechanic/screens/mechanic_products_sceen.dart';
import 'package:e_mechanic/screens/mechanics_chats_displayscreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MechanicDashboard extends StatefulWidget {
  @override
  _MechanicDashboardState createState() => _MechanicDashboardState();
}

class _MechanicDashboardState extends State<MechanicDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? mechanicShopName;
  String? mechanicImageUrl;

  int orderCount = 0;
  int bookingCount = 0;
  int emergencyRequestCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchMechanicInfo();
    _fetchCounts();
  }

  // Function to log out the user
  Future<void> _logout() async {
    try {
      await _auth.signOut(); // Logs out from Firebase
      Navigator.pushReplacementNamed(
          context, 'mainscreen'); // Navigates to main screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchMechanicInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if the user is logged in and print the uid
      print('Logged in User UID: ${user.uid}');

      try {
        // Fetch mechanic details from the 'mechanics' collection based on the user ID
        final mechanicSnapshot =
            await _firestore.collection('mechanics').doc(user.uid).get();

        if (mechanicSnapshot.exists) {
          final mechanicData = mechanicSnapshot.data() as Map<String, dynamic>;
          final mechanicName = mechanicData['shopName'] ?? 'No Name Found';
          final mechanicImage =
              mechanicData['profileImageUrl'] ?? 'default_image_url';

          print('Mechanic Name: $mechanicName');
          print('Mechanic Image: $mechanicImage');

          setState(() {
            mechanicShopName = mechanicName;
            mechanicImageUrl = mechanicImage;
          });
        } else {
          print('Mechanic not found!');
        }
      } catch (e) {
        print('Error fetching mechanic data: $e');
      }
    }
  }

  Future<void> _fetchCounts() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Fetch orders count
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('shopId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Pending')
          .get();
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('mechanicId', isEqualTo: user.uid)
          .get();
      final emergencySnapshot = await _firestore
          .collection('emergencyrequest')
          .where('mechanicId', isEqualTo: user.uid)
          .get();

      setState(() {
        orderCount = ordersSnapshot.docs.length;
        bookingCount = bookingsSnapshot.docs.length;
        emergencyRequestCount = emergencySnapshot.docs.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
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
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Your Products'),
              onTap: () {
                Navigator.pushReplacementNamed(context, 'mechanic_products');
              },
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Mechanic Shop Info Card
            Card(
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: mechanicImageUrl != null
                          ? NetworkImage(mechanicImageUrl!)
                          : const AssetImage(
                                  'assets/images/customer_login.jpeg')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        mechanicShopName ?? 'Mechanic Shop',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Dashboard Sections
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Orders Card
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'order_screen');
                    },
                    child: DashboardCard(
                      title: 'Orders',
                      count: orderCount,
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Bookings Card
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'bookings_screen');
                    },
                    child: DashboardCard(
                      title: 'Bookings',
                      count: bookingCount,
                      icon: Icons.calendar_today,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Emergency Requests Card
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'emergency_screen');
                    },
                    child: DashboardCard(
                      title: 'Emergency Requests',
                      count: emergencyRequestCount,
                      icon: Icons.warning,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MechanicBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            // Home (Current Screen)
          } else if (index == 1) {
            Navigator.pushNamed(context, 'addproducts');
          } else if (index == 2) {
            Navigator.pushNamed(context, 'mechanic_chat_list_screen');
          } else if (index == 3) {
            Navigator.pushNamed(context, 'mechanic_profile');
          }
        },
        currentIndex: 0,
      ),
    );
  }
}

// Custom Card Widget
class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
