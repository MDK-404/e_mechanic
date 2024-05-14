import 'package:e_mechanic/screens/mechanic_navbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class MechanicProfile extends StatefulWidget {
  const MechanicProfile({Key? key}) : super(key: key);

  @override
  _MechanicProfileState createState() => _MechanicProfileState();
}

class _MechanicProfileState extends State<MechanicProfile> {
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  String phoneNumber = '';
  late String shopType = '';
  late String servicesAvailable = '';
  late String shopTiming = '';
  late bool isShopOpen = false;
  late String profileImageUrl = '';

  late File? _image; // Initialize with null
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _image = null; // Initialize with null in initState
    // Fetching user's phone number from Firebase Authentication
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    phoneNumber = user!.phoneNumber!;
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _saveProfile() async {
    if (_image != null ||
        shopNameController.text.isNotEmpty ||
        cityController.text.isNotEmpty ||
        areaController.text.isNotEmpty ||
        shopType.isNotEmpty ||
        servicesAvailable.isNotEmpty ||
        shopTiming.isNotEmpty) {
      // Check if image is selected
      String profileImageUrl = '';
      if (_image != null) {
        // Upload image to Firebase Storage
        String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('mechanic_profile_images')
            .child('$imageFileName.jpg');
        await ref.putFile(_image!);

        // Get download URL for the uploaded image
        profileImageUrl = await ref.getDownloadURL();
      }

      // Save mechanic data to Firestore
      FirebaseFirestore.instance.collection('mechanics').doc(phoneNumber).set({
        'shopName': shopNameController.text,
        'phoneNumber': phoneNumber,
        'profileImageUrl': profileImageUrl,
        'city': cityController.text,
        'area': areaController.text,
        'shopType': shopType,
        'servicesAvailable': servicesAvailable,
        'shopTiming': shopTiming,
        'isShopOpen': isShopOpen,
      });

      // Navigate to mechanic's dashboard or any other screen after saving profile
      Navigator.pushReplacementNamed(context, 'mechanic_dashboard');
    } else {
      // Show error if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all the fields.'),
        ),
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, 'mainscreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: getImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : NetworkImage(profileImageUrl) as ImageProvider,
                child: _image == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 40,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: shopNameController,
              decoration: InputDecoration(
                labelText: 'Shop Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: phoneNumber),
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: areaController,
              decoration: InputDecoration(
                labelText: 'Area',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Radio(
                  value: 'Car Workshop',
                  groupValue: shopType,
                  onChanged: (value) {
                    setState(() {
                      shopType = value.toString();
                    });
                  },
                ),
                Text('Car Workshop'),
                Radio(
                  value: 'Bike Workshop',
                  groupValue: shopType,
                  onChanged: (value) {
                    setState(() {
                      shopType = value.toString();
                    });
                  },
                ),
                Text('Bike Workshop'),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Services Available',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  servicesAvailable = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Shop Timing',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  shopTiming = value;
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: isShopOpen,
                  onChanged: (value) {
                    setState(() {
                      isShopOpen = value!;
                    });
                  },
                ),
                Text('Shop is open'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MechanicBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
          } else if (index == 1) {
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, 'mechanic_profile');
          }
        },
        currentIndex: 2,
      ),
    );
  }
}
