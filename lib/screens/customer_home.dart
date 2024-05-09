import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatefulWidget {
    @override
    _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
    int _selectedIndex = 0; // BottomNavigationBar ke current selection track karne ke liye

    void _onItemTapped(int index) {
        setState(() {
            _selectedIndex = index;
        });

        // Navigation based on selected index
        if (index == 0) {
            // Home selected
            // Aap yahan different screens ko navigate karwa sakte hain
        } else if (index == 1) {
            // Services selected
        } else if (index == 2) {
            // Settings selected
        } else if (index == 3) {
            // Profile selected
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            // appBar: AppBar(
            //     backgroundColor: Colors.black,
            //     elevation: 0.0,
         //   ),
            body: Stack(
                children: [
                    // Google Maps ki image ko set karne ke liye Container
                    Positioned.fill(
                        child: Image.asset(
                            'assets/images/map1.jpg', // Google map ki image ka path
                            fit: BoxFit.cover, // Image ko container mein fill karne ke liye
                        ),
                    ),
                    // Text aur circular image ko show karne ke liye Positioned widget
                    Positioned(
                        top: 0.0, // App bar se distance adjust karne ke liye
                        left: 0, // Screen ki left side se shuru karne ke liye
                        right: 0, // Screen ki right side tak extend karne ke liye
                        child: Card(
                            elevation: 6.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Colors.white,
                            child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Row(
                                            children: [
                                                Icon(
                                                    Icons.car_rental,
                                                    color: Colors.black,
                                                    size: 24.0,
                                                ),
                                                SizedBox(width: 8.0),
                                                Text(
                                                    'Hello (username)',
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                    ),
                                                ),
                                                Spacer(), // Space fill karne ke liye
                                                // Circular image ke liye
                                                CircleAvatar(
                                                    radius: 24.0,
                                                    backgroundImage: AssetImage(
                                                        'assets/images/customer_login.jpeg',
                                                    ),
                                                ),
                                            ],
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                            'Find a mechanic now',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ),
                    // Bottom right corner mein button
                    Positioned(
                        bottom: 20.0,
                        right: 20.0,
                        child: ElevatedButton(
                            onPressed: () {
                                // Button click par action
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // Button ka color
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                ),
                            ),
                            child: Text(
                                'Request Service',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                ),
                            ),
                        ),
                    ),
                ],
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.black, 
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey
                ,// Bottom navigation bar ka color black
                items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.build),
                        label: 'Services',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.settings),
                        label: 'Settings',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Profile',
                    ),
                ],
            ),
        );
    }
}
