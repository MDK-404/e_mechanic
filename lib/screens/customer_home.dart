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
            // Settings selected
        } else if (index == 2) {
            // Profile selected
        }
    }

    void _navigateToScreen(String screenName) {
        // Navigate to new screen
        print('Navigate to $screenName');
        // Navigator.pushNamed(context, screenName);
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Customer Home Screen'),
                centerTitle: true,
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
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
            body: Column(
                children: [
                    // First row with one container: "Emergency Vehicle Assistance"
                    Expanded(
                        child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.grey, width: 2.0),
                            ),
                            child: GestureDetector(
                                onTap: () {
                                    _navigateToScreen('/emergencyVehicleAssistance');
                                },
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        // Image
                                        Image.asset(
                                            'assets/images/map.jpg',
                                            width: 120, // Increase the width
                                            height: 120, // Increase the height
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                            'Emergency Vehicle Assistance',
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ),
                    // Second row with two containers: "AutoShop" and "Book Appointment"
                    Expanded(
                        child: Row(
                            children: [
                                // Container 1: "AutoShop"
                                Expanded(
                                    child: AspectRatio(
                                        aspectRatio: 1.0, // This ensures a square container
                                        child: Container(
                                            margin: EdgeInsets.only(right: 4.0, left: 12.0),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                border: Border.all(color: Colors.grey, width: 2.0),
                                            ),
                                            child: GestureDetector(
                                                onTap: () {
                                                    _navigateToScreen('/autoShop');
                                                },
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                        // Image
                                                        Image.asset(
                                                            'assets/images/autoparts.png',
                                                            width: 100, // Adjust the width as desired
                                                            height: 100, // Adjust the height as desired
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                            'AutoShop',
                                                            style: TextStyle(
                                                                fontSize: 18.0,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                                // Container 2: "Book Appointment"
                                Expanded(
                                    child: AspectRatio(
                                        aspectRatio: 1.0, // This ensures a square container
                                        child: Container(
                                            margin: EdgeInsets.only(left: 4.0, right: 12.0),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                border: Border.all(color: Colors.grey, width: 2.0),
                                            ),
                                            child: GestureDetector(
                                                onTap: () {
                                                    _navigateToScreen('/bookAppointment');
                                                },
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                        // Image
                                                        Image.asset(
                                                            'assets/images/mechanic.png',
                                                            width: 100, // Adjust the width as desired
                                                            height: 100, // Adjust the height as desired
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                            'Book Appointment',
                                                            style: TextStyle(
                                                                fontSize: 18.0,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }
}
