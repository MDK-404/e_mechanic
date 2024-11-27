import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  OrderConfirmationScreen({required this.product});

  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  Future<void> placeOrder(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userName = nameController.text.isNotEmpty
        ? nameController.text
        : FirebaseAuth.instance.currentUser?.displayName ?? 'Customer';

    if (uid == null) return;

    final orderNumber = Random().nextInt(1000000);
    final totalPrice = product['price'] + 100; // Adding shipping cost.

    await FirebaseFirestore.instance.collection('orders').add({
      'orderNumber': orderNumber,
      'customerId': uid,
      'customerName': userName,
      'customerAddress': addressController.text,
      'customerPhone': phoneController.text,
      'productName': product['name'],
      'productPrice': product['price'],
      'shippingCost': 100,
      'totalPrice': totalPrice,
      'shopName': product['shopName'],
      'shopId': product['shopId'],
      'status': 'Pending',
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Confirmed!', style: GoogleFonts.poppins()),
        content: Text(
          'Your order #$orderNumber has been placed successfully. It will be delivered in 2-3 days.\n\n'
          'Total: ₹$totalPrice',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = product['price'] + 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Summary
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.network(
                      product['imageUrl'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'PKR ${product['price']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'From: ${product['shopName']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Input Fields
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                labelStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                labelStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Shipping Address',
                border: OutlineInputBorder(),
                labelStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Payment Method
            Text(
              'Payment Method',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            RadioListTile(
              value: 'cod',
              groupValue: 'cod', // Only one option available for now.
              onChanged: (value) {},
              title: Text('Cash on Delivery', style: GoogleFonts.poppins()),
            ),
            RadioListTile(
              value: 'online',
              groupValue: 'cod', // Keeps 'Cash on Delivery' selected
              onChanged: null, // Disables the "Online Payment" option
              title: Text(
                'Online Payment (Coming Soon)',
                style: GoogleFonts.poppins(
                  color: Colors.grey, // Optional: Make the text appear disabled
                ),
              ),
            ),

            // Price Summary
            const SizedBox(height: 16.0),
            Text(
              'Shipping Cost: PKR 100',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            Text(
              'Total: PKR $totalPrice',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24.0),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => placeOrder(context),
                child: Text(
                  'Confirm Order',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
