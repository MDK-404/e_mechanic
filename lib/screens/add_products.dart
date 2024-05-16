import 'dart:io';
import 'package:e_mechanic/screens/mechanic_navbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  late List<File> _images = [];
  final picker = ImagePicker();

  String shopName = '';
  //late User? _user;

  @override
  // void initState() {
  //   super.initState();
  //   fetchShopName();
  //   _user = FirebaseAuth.instance.currentUser;
  // }

  // Future<void> fetchShopName() async {
  //   final mechanicPhoneNumber = _user!.phoneNumber!;

  //   DocumentSnapshot mechanicSnapshot = await FirebaseFirestore.instance
  //       .collection('mechanics')
  //       .doc(mechanicPhoneNumber)
  //       .get();

  //   setState(() {
  //     shopName = mechanicSnapshot.get('shopName') ?? '';
  //   });
  // }

  Future<List<String>> uploadImages() async {
    try {
      final List<String> imageUrls = [];
      for (final image in _images) {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('product_images/${DateTime.now().millisecondsSinceEpoch}');

        final UploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.whenComplete(() async {
          final url = await storageReference.getDownloadURL();
          imageUrls.add(url);
        });
      }
      return imageUrls;
    } catch (error) {
      print('Error uploading images: $error');
      rethrow;
    }
  }

  Future<void> saveProduct() async {
    final productName = productNameController.text;
    final description = descriptionController.text;
    final stockAvailable = int.tryParse(stockController.text) ?? 0;

    try {
      final List<String> imageUrls = await uploadImages();

      final productData = {
        'productName': productName,
        'description': description,
        'stockAvailable': stockAvailable,
        'images': imageUrls,
      };

      // await FirebaseFirestore.instance
      //     .collection('products')
      //     .doc(_user!.uid)
      //     .collection('products')
      //     .add(productData);

      // Clear text controllers and images list after saving
      productNameController.clear();
      descriptionController.clear();
      stockController.clear();
      _images.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product saved successfully')),
      );
    } catch (error) {
      print('Error saving product: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product')),
      );
    }
  }

  Future<void> pickImages() async {
    try {
      final pickedFiles = await picker.pickMultiImage(
        maxWidth: 800,
      imageQuality: 50,
      maxHeight: 5,
       
      );

      setState(() {
        if (pickedFiles != null) {
          _images = pickedFiles.map((file) => File(file.path)).toList();
        } else {
          print('No images selected.');
        }
      });
    } catch (error) {
      print('Error picking images: $error');
    }
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
            _images.isEmpty
                ? ElevatedButton(
                    onPressed: pickImages,
                    child: Text('Select Images'),
                  )
                : Column(
                    children: [
                      SizedBox(height: 10),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        children: List.generate(_images.length, (index) {
                          return Image.file(_images[index]);
                        }),
                      ),
                    ],
                  ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: saveProduct,
                child: Text('Save Product'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MechanicBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
             Navigator.pushNamed(context, 'mechanic_dashboard');
          } else if (index == 1) {
             Navigator.pushNamed(context, 'mechanic_dashboard');
          } else if (index == 2) {
            Navigator.pushNamed(context, 'addproducts');
          }
          else if(index==3){
            Navigator.pushNamed(context, 'mechanic_profile');
          }
        },
        currentIndex: 2,
      ),
    );
  }
}
