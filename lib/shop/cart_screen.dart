import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  // Dummy cart items
  final List<Map> cartItems = [
    {'name': 'Brake Pad', 'price': 30, 'quantity': 1},
    {'name': 'Oil Filter', 'price': 10, 'quantity': 2},
  ];

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cartItems[index]['name']),
                  subtitle: Text('Quantity: ${cartItems[index]['quantity']}'),
                  trailing: Text(
                      '\$${cartItems[index]['price'] * cartItems[index]['quantity']}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Total: \$$total', style: TextStyle(fontSize: 24)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Checkout logic here
              },
              child: Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}
