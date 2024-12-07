import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:e_mechanic/screens/navbar.dart';

class CustomerHomeScreen extends StatefulWidget {
  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  Completer<GoogleMapController> _controller = Completer();
  Position? _currentPosition;
  List<DocumentSnapshot> nearbyMechanics = [];
  Set<Marker> markers = {};
  String? username;
  String? profileImageUrl;
  TextEditingController _problemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getCurrentLocation();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await firestore.collection('customers').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            username = userDoc.get('name') ?? 'User';
            profileImageUrl = userDoc.get('profileImageURL');
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _fetchNearbyMechanics();

      setState(() {});
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _fetchNearbyMechanics() async {
    try {
      QuerySnapshot mechanicsSnapshot =
          await firestore.collection('mechanics').get();

      for (var doc in mechanicsSnapshot.docs) {
        GeoPoint mechanicLocation = doc['location'];
        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          mechanicLocation.latitude,
          mechanicLocation.longitude,
        );

        if (distance <= 25000) {
          setState(() {
            nearbyMechanics.add(doc);
            markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(
                    mechanicLocation.latitude, mechanicLocation.longitude),
                infoWindow: InfoWindow(
                  title: doc['shopName'],
                  snippet: '${(distance / 1000).toStringAsFixed(2)} km away',
                  onTap: () => _showRequestDialog(doc),
                ),
              ),
            );
          });
        }
      }
    } catch (e) {
      print("Error fetching mechanics: $e");
    }
  }

  void _showRequestDialog(DocumentSnapshot mechanicDoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Request to ${mechanicDoc['shopName']}'),
        content: TextField(
          controller: _problemController,
          decoration: InputDecoration(labelText: 'Describe your problem'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _sendRequest(mechanicDoc);
              Navigator.pop(context);
            },
            child: Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRequest(DocumentSnapshot mechanicDoc) async {
    String userId = auth.currentUser!.uid;
    String mechanicId = mechanicDoc['uid'];

    await firestore.collection('emergencyRequests').add({
      'userId': userId,
      'username': username,
      'mechanicId': mechanicId,
      'mechanicName': mechanicDoc['shopName'],
      'problem': _problemController.text,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request sent successfully!')),
    );

    _problemController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 14.0,
              ),
              markers: markers,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
      bottomNavigationBar: MyBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, 'customer_home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, 'services');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(
                context, 'customer_chat_list_screen');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, 'customer_profile');
          }
        },
        currentIndex: 0,
      ),
    );
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:e_mechanic/screens/navbar.dart';

// class CustomerHomeScreen extends StatefulWidget {
//   @override
//   _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
// }

// class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
//   final auth = FirebaseAuth.instance;
//   final firestore = FirebaseFirestore.instance;

//   String? username;
//   String? profileImageUrl;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }

//   Future<void> _fetchUserData() async {
//     try {
//       User? user = auth.currentUser;

//       if (user != null) {
//         String uid = user.uid; // Using UID for Firestore document access
//         DocumentSnapshot userDoc =
//             await firestore.collection('customers').doc(uid).get();

//         if (userDoc.exists) {
//           setState(() {
//             username = userDoc.get('name') ?? 'User';
//             profileImageUrl = userDoc.get('profileImageURL');
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching user data: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/map1.jpg',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned(
//             top: 0.0,
//             left: 0,
//             right: 0,
//             child: Card(
//               elevation: 6.0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               color: Colors.white,
//               child: Padding(
//                 padding: EdgeInsets.all(10.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.car_rental,
//                           color: Colors.black,
//                           size: 24.0,
//                         ),
//                         SizedBox(width: 8.0),
//                         Text(
//                           'Hello ${username ?? '(username)'}',
//                           style: TextStyle(
//                             fontSize: 18.0,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         Spacer(),
//                         InkWell( 
//                           onTap: () {
//                             auth.signOut();
//                             Navigator.pushReplacementNamed(
//                                 context, 'mainscreen');
//                           },
//                           child: CircleAvatar(
//                             radius: 24.0,
//                             backgroundImage: profileImageUrl != null
//                                 ? NetworkImage(profileImageUrl!)
//                                     as ImageProvider
//                                 : AssetImage(
//                                         'assets/images/customer_login.jpeg')
//                                     as ImageProvider,
//                             backgroundColor: Colors.transparent,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8.0),
//                     Text(
//                       'Find a mechanic now',
//                       style: TextStyle(
//                         fontSize: 16.0,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 20.0,
//             right: 20.0,
//             child: ElevatedButton(
//               onPressed: () {
//                 // Handle service request
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//               child: Text(
//                 'Request Service',
//                 style: TextStyle(
//                   fontSize: 16.0,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: MyBottomNavigationBar(
//         onTap: (index) {
//           if (index == 0) {
//             Navigator.pushReplacementNamed(context, 'customer_home');
//           } else if (index == 1) {
//             Navigator.pushReplacementNamed(context, 'services');
//           } else if (index == 2) {
//             Navigator.pushReplacementNamed(
//                 context, 'customer_chat_list_screen');
//           } else if (index == 3) {
//             Navigator.pushReplacementNamed(context, 'customer_profile');
//           }
//         },
//         currentIndex: 0,
//       ),
//     );
//   }
// }
