import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String productName;
  final int quantity;
  final double totalPrice;

  const OrderDetailsScreen({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer Name: $customerName',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Phone: $customerPhone', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Address: $customerAddress',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Product: $productName', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Quantity: $quantity', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Total Price: PKR $totalPrice',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
