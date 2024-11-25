import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  OrderConfirmationScreen({required this.product});

  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> placeOrder(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Customer';
    if (uid == null) return;

    final orderNumber = Random().nextInt(1000000);

    await FirebaseFirestore.instance.collection('orders').add({
      'orderNumber': orderNumber,
      'customerId': uid,
      'customerName': userName,
      'customerAddress': addressController.text,
      'customerPhone': phoneController.text,
      'productName': product['name'],
      'productPrice': product['price'],
      'shopName': product['shopName'],
      'shopId': product['shopId'], // Mechanic's ID stored
      'status': 'Pending',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order #$orderNumber placed successfully!')),
    );

    Navigator.pop(context); // Go back to the cart screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Shipping Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => placeOrder(context),
              child: const Text('Place Order (Cash on Delivery)'),
            ),
          ],
        ),
      ),
    );
  }
}
