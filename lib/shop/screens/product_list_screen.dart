import 'package:flutter/material.dart';
import '../models/productmodels.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService productService = ProductService();
  List<Product> products = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final fetchedProducts = await productService.fetchProducts();
    setState(() {
      products = fetchedProducts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = products.where((product) {
      return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, 'cart');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text('No products found'))
                      : ListView.builder(
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.0,
                              ),
                              child: ListTile(
                                leading: Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                ),
                                title: Text(product.name),
                                subtitle:
                                    Text('${product.price.toStringAsFixed(2)}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailScreen(product: product),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, 'product_list');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, 'cart');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, 'customer_home');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Home',
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../models/productmodels.dart';
// import '../services/product_service.dart';
// import 'product_detail_screen.dart';

// class ProductListScreen extends StatefulWidget {
//   @override
//   _ProductListScreenState createState() => _ProductListScreenState();
// }

// class _ProductListScreenState extends State<ProductListScreen> {
//   final ProductService productService = ProductService();
//   List<Product> products = [];
//   String searchQuery = '';
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchProducts();
//   }

//   Future<void> fetchProducts() async {
//     final fetchedProducts = await productService.fetchProducts();
//     setState(() {
//       products = fetchedProducts;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<Product> filteredProducts = products.where((product) {
//       return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
//           product.description.toLowerCase().contains(searchQuery.toLowerCase());
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Auto Shop'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.shopping_cart),
//             onPressed: () {
//               Navigator.pushNamed(context, 'cart');
//             },
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     onChanged: (value) {
//                       setState(() {
//                         searchQuery = value;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       hintText: 'Search products...',
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: filteredProducts.isEmpty
//                       ? const Center(child: Text('No products found'))
//                       : ListView.builder(
//                           itemCount: filteredProducts.length,
//                           itemBuilder: (context, index) {
//                             final product = filteredProducts[index];
//                             return Card(
//                               margin: const EdgeInsets.symmetric(
//                                 horizontal: 10.0,
//                                 vertical: 5.0,
//                               ),
//                               child: ListTile(
//                                 leading: Image.network(
//                                   product.imageUrl,
//                                   fit: BoxFit.cover,
//                                   width: 50,
//                                   height: 50,
//                                 ),
//                                 title: Text(product.name),
//                                 subtitle: Text(
//                                     '\$${product.price.toStringAsFixed(2)}'),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           ProductDetailScreen(product: product),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0,
//         onTap: (index) {
//           if (index == 0) {
//             Navigator.pushReplacementNamed(context, 'product_list');
//           } else if (index == 1) {
//             Navigator.pushReplacementNamed(context, 'cart');
//           } else if (index == 2) {
//             Navigator.pushReplacementNamed(context, 'customer_home');
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Shop',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: 'Cart',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Home',
//           ),
//         ],
//       ),
//     );
//   }
// }
