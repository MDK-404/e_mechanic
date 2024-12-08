import 'dart:math';
import 'package:e_mechanic/shop/models/productmodels.dart';
import 'package:e_mechanic/shop/services/send_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  OrderConfirmationScreen({required this.product});

  @override
  _OrderConfirmationScreenState createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  late int totalPrice;
  late int maxStock;
  bool isPlacingOrder = false; // Flag to track order placement status

  @override
  void initState() {
    super.initState();
    quantityController.text = '1'; // Default quantity
    maxStock = widget.product['stockAvailable'] ?? 0;
    totalPrice =
        ((widget.product['price'] * int.parse(quantityController.text)) + 100)
            .toInt(); // Calculate initial total price
  }

  void updateQuantity(int newQuantity) {
    if (newQuantity > maxStock) {
      quantityController.text = maxStock.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You cannot order more than the available stock (${maxStock}).',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    } else if (newQuantity < 1) {
      quantityController.text = '1';
    } else {
      quantityController.text = newQuantity.toString();
    }
    updateTotalPrice();
  }

  void updateTotalPrice() {
    setState(() {
      totalPrice =
          ((widget.product['price'] * int.tryParse(quantityController.text)!) +
                  100)
              .toInt();
    });
  }

  // Update product stock
  Future<void> updateProductStock(int quantity) async {
    try {
      await _firestore
          .collection(
              'products') // Replace with your actual product collection name
          .doc(widget.product[
              'productId']) // Replace with the product document ID field
          .update({
        'stockAvailable': FieldValue.increment(-quantity),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update stock. Please try again.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  /// new code uupdated
  // Mechanic ka FCM token retrieve karne ka function
  Future<String?> _getMechanicToken(String shopId) async {
    final mechanicId = widget.product['shopId'];
    final doc = await _firestore.collection('mechanics').doc(mechanicId).get();
    return doc.data()?['deviceToken'];
  }

  Future<void> sendOrderNotification(String mechanicId, String orderId) async {
    try {
      // Firestore se mechanic ka device token fetch karein
      final doc = await FirebaseFirestore.instance
          .collection('mechanics')
          .doc(mechanicId)
          .get();
      final fcmToken = doc.data()?['deviceToken'];

      if (fcmToken != null) {
        await SendNotificaitonService.sendNotificationUsingApi(
          token: fcmToken,
          title: 'New Order Received',
          body: 'A customer has placed an order. Tap to view details.',
          data: {
            'screen': 'OrdersScreen',
            'orderId': orderId,
          },
        );
      } else {
        print('No FCM token found for this mechanic');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> placeOrder(BuildContext context) async {
    setState(() {
      isPlacingOrder = true; // Show loader
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final userName = nameController.text.isNotEmpty
          ? nameController.text
          : FirebaseAuth.instance.currentUser?.displayName ?? 'Customer';

      // Check for empty fields
      if (nameController.text.trim().isEmpty ||
          phoneController.text.trim().isEmpty ||
          addressController.text.trim().isEmpty) {
        setState(() {
          isPlacingOrder = false; // Hide loader
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please fill in all the required fields (Name, Phone, and Address).',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
        return;
      }

      if (uid == null) return;

      final orderNumber = Random().nextInt(1000000);
      final quantity = int.tryParse(quantityController.text) ?? 0;

      // Add order to Firestore
      await _firestore.collection('orders').add({
        'orderNumber': orderNumber,
        'customerId': uid,
        'customerName': userName,
        'customerAddress': addressController.text,
        'customerPhone': phoneController.text,
        'productName': widget.product['name'],
        'productId': widget.product['productId'],
        'image': widget.product['imageUrl'],
        'productPrice': widget.product['price'],
        'quantity': quantity,
        'shippingCost': 100,
        'totalPrice': totalPrice,
        'shopName': widget.product['shopName'],
        'shopId': widget.product['shopId'],
        'status': 'Pending',
      });
      await sendOrderNotification(
          widget.product['shopId'], orderNumber.toString());

      // Update product stock
      await updateProductStock(quantity);

      // Remove item from cart
      final cartSnapshot = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: uid)
          .where('name', isEqualTo: widget.product['name'])
          .limit(1)
          .get();

      if (cartSnapshot.docs.isNotEmpty) {
        final cartDoc = cartSnapshot.docs.first;
        await _firestore.collection('cart').doc(cartDoc.id).delete();
      }

      // setState(() {
      //   isPlacingOrder = false; // Hide loader
      // });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Order Confirmed!', style: GoogleFonts.poppins()),
          content: Text(
            'Your order #$orderNumber has been placed successfully. It will be delivered in 2-3 days.\n\n'
            'Total: PKR $totalPrice',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'product_list');
              },
              child: Text('OK', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order. Please try again later.'),
        ),
      );
    } finally {
      setState(() {
        isPlacingOrder = false; // Hide loader regardless of success or failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      widget.product['imageUrl'],
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
                            widget.product['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'PKR ${widget.product['price']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'From: ${widget.product['shopName']}',
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

            // Quantity Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        int currentQuantity =
                            int.parse(quantityController.text);
                        updateQuantity(currentQuantity - 1);
                      },
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: quantityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          int? newQuantity = int.tryParse(value);
                          if (newQuantity != null) {
                            updateQuantity(newQuantity);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        int currentQuantity =
                            int.parse(quantityController.text);
                        updateQuantity(currentQuantity + 1);
                      },
                    ),
                  ],
                ),
              ],
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
            Text(
              'Payment Method',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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

            const SizedBox(height: 16.0),
            // Price Summary
            Text(
              'Shipping Cost: PKR 100',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Total: PKR $totalPrice',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16.0),

            // Order Button with Loader
            Center(
              child: ElevatedButton(
                onPressed: isPlacingOrder ? null : () => placeOrder(context),
                child: isPlacingOrder
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text('Place Order', style: GoogleFonts.poppins()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
