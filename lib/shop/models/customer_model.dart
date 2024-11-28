import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String customerid; //customer id
  final String name;
  final String profilePicture;

  Customer(
      {required this.customerid,
      required this.name,
      required this.profilePicture});

  factory Customer.fromFirestore(Map<String, dynamic> data, String id) {
    return Customer(
      customerid: id,
      name: data['name'] ?? 'Unknown',
      profilePicture:
          data['profileImageURL'] ?? 'https://via.placeholder.com/50',
    );
  }
}

Future<Customer?> fetchCustomer(String customerId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .get();

    if (doc.exists) {
      return Customer.fromFirestore(doc.data()!, doc.id);
    }
  } catch (e) {
    print('Error fetching customer data: $e');
  }
  return null;
}
