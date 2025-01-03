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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  String shopName = '';
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
      if (_user != null) {
        fetchShopName();
      } else {
        print('User is not logged in.');
      }
    });
  }

  Future<void> fetchShopName() async {
    if (_user == null) {
      print('User is not logged in.');
      return;
    }

    final String userId = _user!.uid; // Use UID instead of phone number

    try {
      DocumentSnapshot mechanicSnapshot = await FirebaseFirestore.instance
          .collection('mechanics')
          .doc(userId) // Fetch by UID
          .get();

      if (mechanicSnapshot.exists) {
        setState(() {
          shopName = mechanicSnapshot.get('shopName') ?? 'Shop Name Not Found';
        });
      } else {
        setState(() {
          shopName = 'Shop Name Not Found';
        });
      }
    } catch (error) {
      print('Error fetching shop name: $error');
      setState(() {
        shopName = 'Error Fetching Shop Name';
      });
    }
  }

  Future<String> uploadImage(File image) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('product_images/${DateTime.now().millisecondsSinceEpoch}');

      final UploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.whenComplete(() async {});
      final url = await storageReference.getDownloadURL();
      return url;
    } catch (error) {
      print('Error uploading image: $error');
      rethrow;
    }
  }

  Future<void> saveProduct() async {
    if (_user == null) {
      print('User is not logged in.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid, do not proceed
    }

    final productName = productNameController.text;
    final productPrice = double.tryParse(productPriceController.text) ?? 0.0;
    final description = descriptionController.text;
    final stockAvailable = int.tryParse(stockController.text) ?? 0;

    try {
      final String imageUrl = _image != null ? await uploadImage(_image!) : '';

      final CollectionReference productsRef =
          FirebaseFirestore.instance.collection('products');

      // Create a new document to get its ID
      final DocumentReference newProductRef = productsRef.doc();

      final productData = {
        'productId': newProductRef.id, // Use the document ID as productId
        'productName': productName,
        'description': description,
        'price': productPrice,
        'stockAvailable': stockAvailable,
        'image': imageUrl,
        'shopName': shopName,
        'userId': _user!.uid, // Add user ID
      };

      // Save the product to Firestore
      await newProductRef.set(productData);

      // Clear text controllers and images list after saving
      productNameController.clear();
      productPriceController.clear();
      descriptionController.clear();
      stockController.clear();
      setState(() {
        _image = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product saved successfully')),
      );
      Navigator.pushNamed(context, 'mechanic_dashboard');
    } catch (error) {
      print('Error saving product: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product')),
      );
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 50,
      );

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } catch (error) {
      print('Error picking image: $error');
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
        child: Form(
          key: _formKey,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: productPriceController,
                decoration: InputDecoration(labelText: 'Price'),
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: stockController,
                decoration: InputDecoration(labelText: 'Stock Available'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the stock available';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('Upload Product Image'),
              SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.camera_alt, size: 60)
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child:
                                  Icon(Icons.camera_alt, color: Colors.black),
                            ),
                          ),
                  ),
                ),
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
      ),
      bottomNavigationBar: MechanicBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, 'mechanic_dashboard');
          } else if (index == 1) {
            Navigator.pushNamed(context, 'addproducts');
          } else if (index == 2) {
            Navigator.pushNamed(context, 'mechanic_chat_list_screen');
          } else if (index == 3) {
            Navigator.pushNamed(context, 'mechanic_profile');
          }
        },
        currentIndex: 1,
      ),
    );
  }
}
