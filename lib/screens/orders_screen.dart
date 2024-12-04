import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/shop/models/customer_model.dart';
import 'package:e_mechanic/shop/screens/mechanic_chatscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> orders = []; // List to hold the fetched orders

  @override
  void initState() {
    super.initState();
    _fetchOrders(); // Fetch orders when the screen is loaded
  }

  // Function to fetch orders
  Future<void> _fetchOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final ordersSnapshot = await _firestore
            .collection('orders')
            .where('shopId',
                isEqualTo: user.uid) // Fetch orders for the current shop
            .where('status', isEqualTo: 'Pending') // Only pending orders
            .get();

        setState(() {
          orders = ordersSnapshot.docs; // Update the orders list in the state
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch orders: $e')));
      }
    }
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

  // Function to update order status to 'confirmed'
  Future<void> _updateOrderStatus(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update(
          {'status': 'confirmed'}); // Update order status to 'confirmed'

      // Send push notification (example message)
      sendNotificationToCustomer(orderId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order: $e')),
      );
    }
  }

  // Function to send a push notification
  Future<void> sendNotificationToCustomer(String orderId) async {
    // Placeholder for sending notifications.
    print('Sending notification for order $orderId');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: SafeArea(
        child: orders.isEmpty
            ? Center(
                child: Text(
                  'No orders found.',
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
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final orderId = order.id;
                          final customerId = order['customerId'];
                          final productName = order['productName'];
                          final price = order['productPrice'];
                          final quantity = order['quantity'];

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

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.orangeAccent,
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(profileImage),
                                          radius: 35,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                productName,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Customer: $customerName\nPrice: PKR ${price}\nQuantity: $quantity',
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
                                                  color: Colors.orangeAccent),
                                              onPressed: () {
                                                _navigateToChat(customerId,
                                                    customerName, profileImage);
                                              },
                                            ),
                                            SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                _updateOrderStatus(orderId);
                                              },
                                              child: Text(
                                                'Confirm',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                minimumSize:
                                                    Size(screenWidth * 0.2, 40),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
