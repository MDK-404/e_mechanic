import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MechanicChatScreen extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String customerImageUrl;

  MechanicChatScreen({
    required this.customerId,
    required this.customerName,
    required this.customerImageUrl,
  });

  @override
  _MechanicChatScreenState createState() => _MechanicChatScreenState();
}

class _MechanicChatScreenState extends State<MechanicChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  late String mechanicId;
  late String mechanicName = '';
  late String mechanicProfileImage = '';

  @override
  void initState() {
    super.initState();
    _fetchMechanicDetails();
  }

  Future<void> _fetchMechanicDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      mechanicId = user.uid;

      try {
        DocumentSnapshot mechanicDoc = await _firestore
            .collection('mechanics') // Adjust collection name if needed
            .doc(mechanicId)
            .get();

        if (mechanicDoc.exists) {
          setState(() {
            mechanicName = mechanicDoc['shopName'] ?? 'Unknown Mechanic';
            mechanicProfileImage = mechanicDoc['profileImageUrl'] ?? '';
          });
        }
      } catch (e) {
        print('Error fetching mechanic details: $e');
      }
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _firestore.collection('chats').add({
        'mechanicId': mechanicId,
        'customerId': widget.customerId,
        'mechanicName': mechanicName,
        'mechanicProfileImage': mechanicProfileImage,
        'customerName': widget.customerName,
        'customerProfileImage': widget.customerImageUrl,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'senderType': 'mechanic',
      });

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _confirmDeleteMessage(String messageId, bool isMechanicMessage) {
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
                if (isMechanicMessage) {
                  _deleteMessage(messageId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("You can only delete your messages!"),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(String messageId) async {
    try {
      await _firestore.collection('chats').doc(messageId).delete();
    } catch (e) {
      print('Error deleting message: $e');
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
              backgroundImage: NetworkImage(widget.customerImageUrl),
            ),
            SizedBox(width: 8.0),
            Text(widget.customerName, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('mechanicId', isEqualTo: mechanicId)
                  .where('customerId', isEqualTo: widget.customerId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
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
                    bool isMechanic = message['senderType'] == 'mechanic';
                    String messageId = messages[index].id;
                    return Align(
                      alignment: isMechanic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () {
                          _confirmDeleteMessage(messageId, isMechanic);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color: isMechanic
                                ? Colors.orangeAccent
                                : Colors.grey[700],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(color: Colors.white),
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
                  icon: Icon(Icons.send, color: Colors.orangeAccent),
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
