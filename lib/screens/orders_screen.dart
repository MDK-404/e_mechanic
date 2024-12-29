import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/screens/order_detail_screen.dart';
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
            .orderBy('status') // Order by status (Pending first)
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

      // Refresh the UI
      setState(() {
        final orderIndex = orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          orders[orderIndex] = orders[orderIndex].reference.get()
              as DocumentSnapshot; // Update order in the list
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order: $e')),
      );
    }
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
                          final customerName = order['customerName'];
                          final customerPhone = order['customerPhone'];
                          final customerAddress = order['customerAddress'];
                          final productName = order['productName'];
                          final price = order['totalPrice'];
                          final quantity = order['quantity'];
                          final productImage = order['image'];
                          final orderStatus = order['status'];

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              color: Colors.orangeAccent,
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(productImage),
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
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Customer: $customerName\nPrice: PKR ${price}\nQuantity: $quantity\nStatus: $orderStatus',
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
                                            _navigateToChat(
                                              order['customerId'],
                                              customerName,
                                              productImage,
                                            );
                                          },
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderDetailsScreen(
                                                  customerName: customerName,
                                                  customerPhone: customerPhone,
                                                  customerAddress:
                                                      customerAddress,
                                                  productName: productName,
                                                  quantity: quantity,
                                                  totalPrice: price *
                                                      quantity.toDouble(),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text('View',
                                              style: TextStyle(fontSize: 12)),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize:
                                                Size(screenWidth * 0.2, 40),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: orderStatus == 'confirmed'
                                              ? null
                                              : () {
                                                  _updateOrderStatus(orderId);
                                                },
                                          child: Text(
                                            orderStatus == 'confirmed'
                                                ? 'Confirmed'
                                                : 'Confirm',
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
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
