import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String name;
  final double price;
  final String imageUrl;

  const ProductDetailScreen({
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageUrl),
            SizedBox(height: 16.0),
            Text(name, style: TextStyle(fontSize: 24.0)),
            Text('\$$price', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, 'cart'); // Navigate to cart or wherever needed
              },
              child: Text('Add to cart'),
            ),
          ],
        ),
      ),
    );
  }
}
