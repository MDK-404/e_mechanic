import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YourProductsScreen extends StatefulWidget {
  @override
  _YourProductsScreenState createState() => _YourProductsScreenState();
}

class _YourProductsScreenState extends State<YourProductsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? mechanicId;

  @override
  void initState() {
    super.initState();
    _fetchMechanicId();
  }

  Future<void> _fetchMechanicId() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          mechanicId = user.uid;
        });
      }
    } catch (e) {
      print('Error fetching mechanic ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to MechanicDashboard instead of the previous screen
            Navigator.pushReplacementNamed(context, 'mechanic_dashboard');
          },
        ),
      ),
      body: mechanicId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('products')
                  .where('userId', isEqualTo: mechanicId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No products uploaded.'));
                }

                final products = snapshot.data!.docs;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    var data = product.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            child: data['image'] != null
                                ? Image.network(data['image'],
                                    fit: BoxFit.cover)
                                : const Icon(Icons.image, size: 80),
                          ),
                          ListTile(
                            title: Text(data['productName'] ?? 'No Name'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Price: PKR ${data['price'] ?? 0}'),
                                Text('Stock: ${data['stockAvailable'] ?? 0}'),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _editProduct(context, product.id, data),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProduct(product.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _editProduct(BuildContext context, String productId,
      Map<String, dynamic> productData) async {
    TextEditingController priceController =
        TextEditingController(text: productData['price']?.toString());
    TextEditingController quantityController =
        TextEditingController(text: productData['stockAvailable']?.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${productData['productName']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('products').doc(productId).update({
                  'price': double.tryParse(priceController.text) ?? 0,
                  'stockAvailable': int.tryParse(quantityController.text) ?? 0,
                });
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product.')),
      );
    }
  }
}
