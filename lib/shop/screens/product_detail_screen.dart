import 'package:e_mechanic/shop/models/productmodels.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  Future<void> addToCart(Product product) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final cartCollection = FirebaseFirestore.instance.collection('cart');
    try {
      // Add product to the cart with mechanic's UID as shopId
      await cartCollection.doc().set({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'shopName': product.shopName, // Ensure fallback
        'shopId': product.shopId, // Mechanic's UID
        'userId': uid, // Current user's ID
      });

      print('Product added to cart successfully!');
    } catch (e) {
      print('Error adding product to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () {
              Navigator.pushNamed(context, 'product_list');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'PKR ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              product.description,
              style: const TextStyle(fontSize: 16.0),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Add to Cart'),
              onPressed: () async {
                await addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added to cart!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
