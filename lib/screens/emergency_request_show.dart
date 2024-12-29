import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/shop/screens/mechanic_chatscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmergencyRequestsScreen extends StatefulWidget {
  @override
  _EmergencyRequestsScreenState createState() =>
      _EmergencyRequestsScreenState();
}

class _EmergencyRequestsScreenState extends State<EmergencyRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> emergencyRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchEmergencyRequests();
  }

  Future<void> _fetchEmergencyRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await _firestore
            .collection('emergencyrequest')
            .where('status', isEqualTo: 'pending')
            .where('mechanicId', isEqualTo: user.uid) // Filter by mechanicId
            .get();

        setState(() {
          emergencyRequests = snapshot.docs;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch requests: $e')),
        );
      }
    }
  }

  String formatDate(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _firestore.collection('emergencyrequest').doc(requestId).update({
        'status': newStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $newStatus successfully!')),
      );

      _fetchEmergencyRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request: $e')),
      );
    }
  }

  Future<void> _navigateToChatScreen(String userId) async {
    try {
      // Match userId with the customers collection docId
      final customerDoc =
          await _firestore.collection('customers').doc(userId).get();

      if (customerDoc.exists) {
        final customerName = customerDoc['name'] ?? 'Unknown'; // Fetch username
        final profilePicture =
            customerDoc['profileImageUrl'] ?? null; // Fetch profile picture

        // Navigate to MechanicChatScreen with customer details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MechanicChatScreen(
              customerId: userId, // Pass the actual userId
              customerName: customerName,
              customerImageUrl: profilePicture,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customer data not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching customer data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Emergency Requests')),
      body: SafeArea(
        child: emergencyRequests.isEmpty
            ? Center(
                child: Text(
                  'No pending requests.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  itemCount: emergencyRequests.length,
                  itemBuilder: (context, index) {
                    final request = emergencyRequests[index];
                    final requestId = request.id;
                    final userName = request['username'];
                    final problem = request['problem'];
                    final Timestamp dateTimestamp = request['date'];
                    final userId = request.id; // Use document ID as userId

                    return Card(
                      color: Colors.redAccent.shade100,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User: $userName',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Problem: $problem',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Date & Time: ${formatDate(dateTimestamp)}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _updateRequestStatus(
                                            requestId, 'confirmed');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: Text('Confirm'),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        _updateRequestStatus(
                                            requestId, 'rejected');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text('Reject'),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    _navigateToChatScreen(
                                        userId); // Pass userId
                                  },
                                  icon: Icon(Icons.chat, color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
