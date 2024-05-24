import 'package:e_mechanic/shop/product_detail_screen.dart';
import 'package:e_mechanic/shop/shop_navbar.dart';
import 'package:flutter/material.dart';
// Import the product detail screen

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Spare Parts'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, 'cart');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 3 / 4, // Adjust to control the card aspect ratio
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductItem(
              name: products[index]['name'],
              price: products[index]['price'].toDouble(),
              imageUrl: products[index]['imageUrl'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      name: products[index]['name'],
                      price: products[index]['price'].toDouble(),
                      imageUrl: products[index]['imageUrl'],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: shopBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, 'cart');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, 'customer_home');
          }
        },
        currentIndex: 0,
      ),
    );
  }
}

final List<Map<String, dynamic>> products = [
  {
    'name': 'Brake Pad',
    'price': 30.0,
    'imageUrl': 'assets/images/brakepad.jpg',
  },
  {
    'name': 'Oil Filter',
    'price': 10.0,
    'imageUrl': 'assets/images/filter.jpg',
  },
  {
    'name': 'Brake Pad',
    'price': 30.0,
    'imageUrl': 'assets/images/brakepad.jpg',
  },
  {
    'name': 'Oil Filter',
    'price': 10.0,
    'imageUrl': 'assets/images/filter.jpg',
  },
  {
    'name': 'Brake Pad',
    'price': 30.0,
    'imageUrl': 'assets/images/brakepad.jpg',
  },
  {
    'name': 'Oil Filter',
    'price': 10.0,
    'imageUrl': 'assets/images/filter.jpg',
  },
  {
    'name': 'Brake Pad',
    'price': 30.0,
    'imageUrl': 'assets/images/brakepad.jpg',
  },
  {
    'name': 'Oil Filter',
    'price': 10.0,
    'imageUrl': 'assets/images/filter.jpg',
  },
  // Add more products here
];

class ProductItem extends StatelessWidget {
  final String name;
  final double price;
  final String imageUrl;
  final VoidCallback onTap;

  const ProductItem({
    Key? key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '\$$price',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'product_detail');
                    },
                    child: Text('Add to Cart'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
