import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({Key? key}) : super(key: key);

  @override
  _CustomerProfileState createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  final TextEditingController nameController = TextEditingController();
  late String phoneNumber;
  late String profileImageURL = ''; // Initialize with empty string

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

    // Fetch user data from Firestore
    FirebaseFirestore.instance
        .collection('customers')
        .doc(phoneNumber)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          nameController.text = documentSnapshot.get('name');
          profileImageURL = documentSnapshot.get('profileImageURL');
        });
      }
    });
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
    if (_image != null || nameController.text.isNotEmpty) {
      // Check if image is selected
      if (_image != null) {
        // Upload image to Firebase Storage
        String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('$imageFileName.jpg');
        await ref.putFile(_image!);

        // Get download URL for the uploaded image
        profileImageURL = await ref.getDownloadURL();
      }

      // Save user data to Firestore
      FirebaseFirestore.instance.collection('customers').doc(phoneNumber).set({
        'name': nameController.text,
        'phoneNumber': phoneNumber,
        'profileImageURL': profileImageURL,
      });

      // Navigate to home screen or any other screen after saving profile
      Navigator.pushReplacementNamed(context, 'customer_home');
    } else {
      // Show error if image or name is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image and enter your name.'),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: getImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : NetworkImage(profileImageURL) as ImageProvider,
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
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
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
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
