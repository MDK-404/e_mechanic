import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/productmodels.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> fetchProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] is String)
              ? double.tryParse(data['price']) ?? 0.0
              : (data['price'] as num).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}
