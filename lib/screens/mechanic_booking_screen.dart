import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/shop/models/customer_model.dart';
import 'package:e_mechanic/shop/screens/mechanic_chatscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> bookings = []; // List to hold the fetched bookings

  @override
  void initState() {
    super.initState();
    _fetchBookings(); // Fetch bookings when the screen is loaded
  }

  // Function to fetch bookings
  Future<void> _fetchBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final bookingsSnapshot = await _firestore
            .collection('bookings')
            .where('mechanicId',
                isEqualTo: user.uid) // Fetch bookings for the current mechanic
            .where('status', isEqualTo: 'pending') // Only pending bookings
            .get();

        setState(() {
          bookings =
              bookingsSnapshot.docs; // Update the bookings list in the state
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch bookings: $e')));
      }
    }
  }

  String formatDate(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy').format(dateTime); // Format: 04 Dec 2024
  }

  // Function to navigate to the chat screen
  Future<void> _navigateToChat(
      String customerId, String customerName, String profilePicture) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MechanicChatScreen(
          customerId: customerId,
          customerName: customerName,
          customerImageUrl: profilePicture,
        ),
      ),
    );
  }

  // Function to update booking status to 'confirmed'
  Future<void> _updateBookingStatus(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update(
          {'status': 'confirmed'}); // Update booking status to 'confirmed'

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Bookings')),
      body: SafeArea(
        child: bookings.isEmpty
            ? Center(
                child: Text(
                  'No bookings found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          final bookingId = booking.id;
                          final customerId = booking['userId'];
                          final services =
                              List<String>.from(booking['services']);
                          final Timestamp dateTimestamp = booking['date'];

                          return FutureBuilder<Customer?>(
                            future: fetchCustomer(customerId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData) {
                                return Center(
                                    child: Text('Customer not found'));
                              }

                              final customer = snapshot.data!;
                              final customerName = customer.name;
                              final profileImage = customer.profilePicture;

                              return Card(
                                color: Colors.orangeAccent,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // CircleAvatar(
                                      //   backgroundImage:
                                      //       NetworkImage(profileImage),
                                      //   radius: 35,
                                      // ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Services:',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 4),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: services
                                                  .map((service) => Text(
                                                        '- $service',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black),
                                                      ))
                                                  .toList(),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Customer: $customerName\nDate: ${formatDate(dateTimestamp)}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.chat,
                                                color: Colors.blue),
                                            onPressed: () {
                                              _navigateToChat(customerId,
                                                  customerName, profileImage);
                                            },
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              _updateBookingStatus(bookingId);
                                            },
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              // backgroundColor: Colors
                                              //     .orangeAccent, // Transparent background
                                              // shadowColor:
                                              //     Colors.black, // No shadow
                                              // elevation: 0,
                                              minimumSize:
                                                  Size(screenWidth * 0.2, 40),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
