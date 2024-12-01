import 'package:e_mechanic/shop/screens/order_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> removeFromCart(String productId) async {
    final cartCollection = FirebaseFirestore.instance.collection('cart');

    await cartCollection.doc(productId).delete();
  }

  void navigateToOrderConfirmation(DocumentSnapshot cartItem) {
    final data = cartItem.data() as Map<String, dynamic>;

    if (data['stockAvailable'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product stock information is missing.'),
        ),
      );
      return;
    }

    // Add `doc.id` to the product map
    final productWithId = {
      ...data,
      'productId': data['productId'] // Include the Firestore document ID
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(product: productWithId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Center(child: Text('You are not logged in.'));
    }

    final cartCollection = FirebaseFirestore.instance.collection('cart');

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data?.docs ?? [];

          if (cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final data = cartItem.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading:
                      Image.network(data['imageUrl'], width: 50, height: 50),
                  title: Text(data['name']),
                  subtitle: Text('PKR ${data['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeFromCart(cartItem.id),
                  ),
                  onTap: () => navigateToOrderConfirmation(cartItem),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
