import 'package:e_mechanic/shop/screens/customer_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_mechanic/shop/models/productmodels.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final TextEditingController reviewController = TextEditingController();
  int selectedRating = 0;

  Future<void> addToCart(Product product) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final cartCollection = FirebaseFirestore.instance.collection('cart');
    try {
      await cartCollection.doc().set({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'shopName': product.shopName, // mechanics shop name
        'shopId': product.shopId, // mechanics id/mechanics shop id
        'userId': uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added to cart successfully!')),
      );
    } catch (e) {
      print('Error adding product to cart: $e');
    }
  }

  Future<void> submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || reviewController.text.isEmpty || selectedRating == 0)
      return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userName = userDoc.data()?['name'] ?? 'Anonymous';
    final userPic =
        userDoc.data()?['profilePicture'] ?? 'https://via.placeholder.com/50';

    final reviewCollection =
        FirebaseFirestore.instance.collection('productreviews');
    try {
      await reviewCollection.add({
        'productId': widget.product.id,
        'userId': user.uid,
        'name': userName,
        'userPic': userPic,
        'review': reviewController.text,
        'rating': selectedRating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      reviewController.clear();
      setState(() {
        selectedRating = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  Widget buildReviewsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productreviews')
          .where('productId', isEqualTo: widget.product.id)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("Error fetching reviews: ${snapshot.error}");
          return const Text('Error fetching reviews.');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No reviews yet.',
              style: TextStyle(fontSize: 16.0));
        }

        final reviews = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    review['userPic'] ?? 'https://via.placeholder.com/50'),
              ),
              title: Text(review['name'] ?? 'Anonymous'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review['review']),
                  Row(
                    children: List.generate(
                      5,
                      (starIndex) => Icon(
                        Icons.star,
                        color: starIndex < (review['rating'] ?? 0)
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildReviewInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Your Review',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: List.generate(
            5,
            (index) => IconButton(
              icon: Icon(
                Icons.star,
                color: index < selectedRating ? Colors.orange : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selectedRating = index + 1;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: reviewController,
          decoration: const InputDecoration(
            labelText: 'Write your review',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: submitReview,
          child: const Text('Submit Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            side: const BorderSide(
              color: Color.fromRGBO(255, 152, 0, 1),
            ),
          ),
        ),
      ],
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.product.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align items to the top
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2, // Allow up to 2 lines for the name
                        overflow:
                            TextOverflow.ellipsis, // Truncate if still too long
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0), // Space between the name and button
                ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart, color: Colors.orange),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(color: Colors.orange),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    side: const BorderSide(
                      color: Color.fromRGBO(255, 152, 0, 1),
                    ),
                  ),
                  onPressed: () => addToCart(widget.product),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'PKR ${widget.product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20.0, color: Colors.orange),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.product.description,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shop: ${widget.product.shopName}',
                    style: const TextStyle(fontSize: 16.0)),
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerChatScreen(
                          mechanicId: widget.product.shopId, //  mechanic ID
                          shopName: widget.product.shopName, // shop name
                          mechanicImageUrl:
                              widget.product.imageUrl, //  mechanic's image URL
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 32.0, thickness: 1.0),
            const Text(
              'Reviews',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            buildReviewsSection(),
            const SizedBox(height: 16.0),
            buildReviewInputSection(),
          ],
        ),
      ),
    );
  }
}
