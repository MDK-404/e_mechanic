import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart'; // Add geocoding package to get latitude/longitude from address
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class MechanicProfile extends StatefulWidget {
  const MechanicProfile({Key? key}) : super(key: key);

  @override
  _MechanicProfileState createState() => _MechanicProfileState();
}

class _MechanicProfileState extends State<MechanicProfile> {
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController shopAddressController =
      TextEditingController(); // New Controller for shop address
  String shopType = '';
  List<String> servicesAvailable = [];
  String shopTiming = '';
  File? _image;
  final picker = ImagePicker();
  Map<String, bool> availability = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  String saveButtonText = "Save";
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    fetchMechanicDetails();
  }

  /// Fetch Mechanic Details (if exists)
  Future<void> fetchMechanicDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      DocumentSnapshot mechanicDoc = await FirebaseFirestore.instance
          .collection('mechanics')
          .doc(uid)
          .get();

      if (mechanicDoc.exists) {
        Map<String, dynamic> data = mechanicDoc.data() as Map<String, dynamic>;
        setState(() {
          shopNameController.text = data['shopName'] ?? '';
          cityController.text = data['city'] ?? '';
          areaController.text = data['area'] ?? '';
          phoneController.text = data['phone'] ?? '';
          shopType = data['shopType'] ?? '';
          servicesAvailable =
              List<String>.from(data['servicesAvailable'] ?? []);
          shopTiming = data['shopTiming'] ?? '';
          availability =
              Map<String, bool>.from(data['availability'] ?? availability);
          saveButtonText = "Update";
        });
      }
    } catch (e) {
      print("Error fetching mechanic details: $e");
    }
  }

  /// Convert Address to Coordinates (latitude, longitude)
  Future<void> _getCoordinatesFromAddress() async {
    try {
      // Get coordinates based on address entered by mechanic
      List<Location> locations =
          await locationFromAddress(shopAddressController.text);
      if (locations.isNotEmpty) {
        setState(() {
          latitude = locations.first.latitude;
          longitude = locations.first.longitude;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching coordinates: $e")),
      );
    }
  }

  /// Save Mechanic Profile to Firestore
  void _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || latitude == null || longitude == null) return;

    String profileImageUrl = '';
    if (_image != null) {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('mechanic_images/$uid.jpg');
      await ref.putFile(_image!);
      profileImageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('mechanics').doc(uid).set({
      'uid': uid,
      'phone': phoneController.text,
      'shopName': shopNameController.text,
      'city': cityController.text,
      'area': areaController.text,
      'shopType': shopType,
      'servicesAvailable': servicesAvailable,
      'shopTiming': shopTiming,
      'availability': availability,
      'profileImageUrl': profileImageUrl,
      'location':
          GeoPoint(latitude!, longitude!), // Store the converted location
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Profile ${saveButtonText == "Save" ? "saved" : "updated"} successfully!')),
    );

    Navigator.pushReplacementNamed(context, 'mechanic_dashboard');
  }

  /// Get Image for Profile
  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mechanic Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: getImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? Icon(Icons.camera_alt, size: 40) : null,
              ),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: shopNameController,
              decoration: InputDecoration(labelText: 'Shop Name'),
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
            TextField(
              controller: shopAddressController,
              decoration: InputDecoration(
                labelText: 'Shop Address (Enter address to get coordinates)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getCoordinatesFromAddress,
              child: Text("Get Coordinates"),
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
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'Services Available',
                border: OutlineInputBorder(),
              ),
              value: null,
              items: [
                DropdownMenuItem(
                  child: Text('Tuning'),
                  value: 'Tuning',
                ),
                DropdownMenuItem(
                  child: Text('Denting'),
                  value: 'Denting',
                ),
                DropdownMenuItem(
                  child: Text('Electrician'),
                  value: 'Electrician',
                ),
                DropdownMenuItem(
                  child: Text('Puncture'),
                  value: 'Puncture',
                ),
                DropdownMenuItem(
                  child: Text('Car Deck System'),
                  value: 'Car Deck System',
                ),
                DropdownMenuItem(
                  child: Text('Fuel Delivery'),
                  value: 'Fuel Delivery',
                ),
                DropdownMenuItem(
                  child: Text('Auto Parts'),
                  value: 'Auto Parts',
                ),
              ],
              onChanged: (value) {
                setState(() {
                  servicesAvailable.add(value.toString());
                });
              },
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: availability.keys.map((String day) {
                return Row(
                  children: [
                    Checkbox(
                      value: availability[day],
                      onChanged: (value) {
                        setState(() {
                          availability[day] = value!;
                        });
                      },
                    ),
                    Text(day),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text(saveButtonText),
            ),
          ],
        ),
      ),
    );
  }
}
