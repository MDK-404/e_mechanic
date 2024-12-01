import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerChatScreen extends StatefulWidget {
  final String mechanicId;
  final String shopName;
  final String mechanicImageUrl;

  CustomerChatScreen({
    required this.mechanicId,
    required this.shopName,
    required this.mechanicImageUrl,
  });

  @override
  _CustomerChatScreenState createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  late String customerId;
  String customerName = 'Unknown';
  String customerProfileImage = '';

  @override
  void initState() {
    super.initState();
    User? user = _auth.currentUser;
    if (user != null) {
      customerId = user.uid;
      _fetchCustomerData();
    }
  }

  Future<void> _fetchCustomerData() async {
    try {
      final customerDoc =
          await _firestore.collection('customers').doc(customerId).get();
      if (customerDoc.exists) {
        final customerData = customerDoc.data();
        setState(() {
          customerName = customerData?['name'] ?? 'Unknown';
          customerProfileImage = customerData?['profileImageURL'] ??
              'https://via.placeholder.com/50';
        });
      }
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      // Add message to the 'chats' collection
      await _firestore.collection('chats').add({
        'mechanicId': widget.mechanicId,
        'customerId': customerId,
        'mechanicname': widget.shopName,
        'mechanicprofileurl': widget.mechanicImageUrl,
        'customerName': customerName, // Customer name from Firestore
        'customerProfileImage':
            customerProfileImage, // Profile image from Firestore
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'senderType': 'customer',
      });

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _confirmDeleteMessage(String messageId, bool isCustomerMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Message"),
          content: Text("Are you sure you want to delete this message?"),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (isCustomerMessage) {
                  _deleteMessage(messageId, isCustomerMessage);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("You can only delete your messages!")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(String messageId, bool isCustomerMessage) async {
    if (isCustomerMessage) {
      await _firestore.collection('chats').doc(messageId).delete();
    } else {
      setState(() {
        // Remove message from the local chat screen without deleting from Firebase
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.mechanicImageUrl),
            ),
            SizedBox(width: 8.0),
            Text(widget.shopName, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('mechanicId', isEqualTo: widget.mechanicId)
                  .where('customerId', isEqualTo: customerId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet'));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message =
                        messages[index].data() as Map<String, dynamic>;
                    var isCustomer =
                        message['senderType'] == 'customer'; // Check sender
                    String messageId = messages[index].id;

                    return Align(
                      alignment: isCustomer
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () {
                          _confirmDeleteMessage(messageId, isCustomer);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color:
                                isCustomer ? Colors.orangeAccent : Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.orange),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
