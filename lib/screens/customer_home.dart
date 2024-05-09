import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatefulWidget {
    @override
    _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
    int _selectedIndex = 0;

    void _onItemTapped(int index) {
        setState(() {
            _selectedIndex = index;
        });

        // Navigation based on selected index
        if (index == 0) {
            // Home selected
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
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.black,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
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
            body: Stack(
                children: [
                    // Placeholder image covering the full screen
                    Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/map.jpg'),
                                fit: BoxFit.cover,
                            ),
                        ),
                    ),
                    // Top text with "Hello (username), Find mechanic now"
                    Positioned(
                        top: 70.0, // Adjust the distance from the top as needed
                        left: 20.0,
                        child: Row(
                            children: [
                                Icon(
                                    Icons.car_rental,
                                    color: Colors.black,
                                    size: 24.0,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                    'Hello (username), Find mechanic now',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                    ),
                                ),
                            ],
                        ),
                    ),
                    // Bottom right corner "Request Service" button
                    Positioned(
                        bottom: 20.0,
                        right: 20.0,
                        child: ElevatedButton(
                            onPressed: () {
                                print('Request Service');
                            },
                            child: Text('Request Service'),
                        ),
                    ),
                ],
            ),
        );
    }
}
