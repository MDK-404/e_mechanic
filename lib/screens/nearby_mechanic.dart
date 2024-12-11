import 'package:e_mechanic/shop/screens/customer_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class NearbyMechanicsScreen extends StatefulWidget {
  @override
  _NearbyMechanicsScreenState createState() => _NearbyMechanicsScreenState();
}

class _NearbyMechanicsScreenState extends State<NearbyMechanicsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> mechanics = [];
  bool isLoading = true;
  bool noNearbyMechanics = false;
  late Position userPosition;
  final Map<String, TextEditingController> _problemControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userPosition = position;
      });
      _fetchNearbyMechanics();
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _fetchNearbyMechanics() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('mechanics').get();

      // Extract data correctly from the snapshot and map to List<Map<String, dynamic>>
      List<Map<String, dynamic>> fetchedMechanics = snapshot.docs.map((doc) {
        _problemControllers[doc.id] = TextEditingController();
        GeoPoint? location = doc['location'];
        double latitude = location?.latitude ?? 0.0;
        double longitude = location?.longitude ?? 0.0;

        return {
          'id': doc.id,
          'shopName': doc['shopName'] ?? 'Unknown Shop',
          'location': location,
          'latitude': latitude,
          'longitude': longitude,
          'profileImageUrl':
              doc['profileImageUrl'] ?? 'https://via.placeholder.com/50',
        };
      }).toList();

      // Filter mechanics based on distance (within 10 km radius)
      List<Map<String, dynamic>> nearbyMechanics =
          fetchedMechanics.where((mechanic) {
        double distanceInMeters = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          mechanic['latitude'],
          mechanic['longitude'],
        );
        return distanceInMeters <= 10000; // 10 km radius
      }).toList();

      setState(() {
        mechanics =
            nearbyMechanics.isNotEmpty ? nearbyMechanics : fetchedMechanics;
        noNearbyMechanics = nearbyMechanics.isEmpty;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching mechanics: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _sendEmergencyRequest(String mechanicId, String shopName) async {
    String problem = _problemControllers[mechanicId]?.text.trim() ?? '';
    if (problem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please enter a problem before sending a request.')),
      );
      return;
    }

    try {
      await _firestore.collection('emergencyrequest').add({
        'username': FirebaseAuth.instance.currentUser?.displayName ?? 'User',
        'userid': FirebaseAuth.instance.currentUser?.uid,
        'mechanicShopName': shopName,
        'mechanicId': mechanicId,
        'problem': problem,
        'date': DateTime.now(),
        'status': 'pending',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Emergency request sent successfully!')),
      );
      _problemControllers[mechanicId]?.clear();
    } catch (e) {
      print('Error sending emergency request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request. Please try again.')),
      );
    }
  }

  void _navigateToChat(String mechanicId, String shopName, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerChatScreen(
          mechanicId: mechanicId,
          shopName: shopName,
          mechanicImageUrl: imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Mechanics'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (noNearbyMechanics)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No nearby mechanics found. Showing all available mechanics.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: mechanics.length,
                    itemBuilder: (context, index) {
                      final mechanic = mechanics[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(mechanic['profileImageUrl']),
                                ),
                                title: Text(
                                  mechanic['shopName'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Location: (${mechanic['latitude']}, ${mechanic['longitude']})',
                                  style: TextStyle(fontSize: 14),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.chat, color: Colors.orange),
                                  onPressed: () => _navigateToChat(
                                    mechanic['id'],
                                    mechanic['shopName'],
                                    mechanic['profileImageUrl'],
                                  ),
                                ),
                              ),
                              TextField(
                                controller: _problemControllers[mechanic['id']],
                                decoration: InputDecoration(
                                  labelText: 'Enter your problem',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => _sendEmergencyRequest(
                                  mechanic['id'],
                                  mechanic['shopName'],
                                ),
                                icon: Icon(Icons.warning),
                                label: Text('Send Emergency Request'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
