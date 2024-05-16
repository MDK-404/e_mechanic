import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  late File? _image1;
  late File? _image2;
  late File? _image3;

  final picker = ImagePicker();

  String shopName = '';

  @override
  // void initState() {
  //   super.initState();
  //   fetchShopName();
  // }

  // Future<void> fetchShopName() async {
  //   final auth = FirebaseAuth.instance;
  //   User? user = auth.currentUser;
  //   String mechanicPhoneNumber = user!.phoneNumber!;

  //   DocumentSnapshot mechanicSnapshot = await FirebaseFirestore.instance
  //       .collection('mechanics')
  //       .doc(mechanicPhoneNumber)
  //       .get();

  //   setState(() {
  //     shopName = mechanicSnapshot.get('shopName') ?? '';
  //   });
  // }

  Future getImage(int imageNumber) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        switch (imageNumber) {
          case 1:
            _image1 = File(pickedFile.path);
            break;
          case 2:
            _image2 = File(pickedFile.path);
            break;
          case 3:
            _image3 = File(pickedFile.path);
            break;
        }
      } else {
        print('No image selected.');
      }
    });
  }

  void _saveProduct() async {
    // Save product logic remains the same
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop Name: $shopName',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            // Add other form fields and buttons...
             SizedBox(height: 20),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: null,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: stockController,
              decoration: InputDecoration(labelText: 'Stock Available'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Text('Upload Product Images'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => getImage(1),
                  child: Text('Image 1'),
                ),
                ElevatedButton(
                  onPressed: () => getImage(2),
                  child: Text('Image 2'),
                ),
                ElevatedButton(
                  onPressed: () => getImage(3),
                  child: Text('Image 3'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProduct,
              child: Text('Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}
