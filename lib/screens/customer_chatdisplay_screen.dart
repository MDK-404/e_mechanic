import 'package:e_mechanic/screens/navbar.dart';
import 'package:e_mechanic/shop/screens/customer_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerChatListScreen extends StatefulWidget {
  @override
  _CustomerChatListScreenState createState() => _CustomerChatListScreenState();
}

class _CustomerChatListScreenState extends State<CustomerChatListScreen> {
  late String customerId;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      customerId = user.uid; // Fetch customerId from authenticated user
    }
  }

  // Fetching the chat list, grouped by the mechanicId and ordered by the latest message timestamp.
  Stream<List<Map<String, dynamic>>> getChatList() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('customerId', isEqualTo: customerId)
        .orderBy('timestamp', descending: true) // Sorting chats by latest
        .snapshots()
        .map((snapshot) {
      // Group chats by mechanicId
      Map<String, Map<String, dynamic>> groupedChats = {};
      for (var doc in snapshot.docs) {
        var chat = doc.data();
        String mechanicId = chat['mechanicId'];

        if (!groupedChats.containsKey(mechanicId)) {
          groupedChats[mechanicId] = {
            'mechanicId': mechanicId,
            'mechanicName': chat['mechanicName'],
            'mechanicProfileImage': chat['mechanicProfileImage'],
            'latestMessage': chat['message'], // Include the latest message
            'timestamp': chat['timestamp'], // Include timestamp
          };
        }
      }
      return groupedChats.values.toList(); // Convert grouped chats to a list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Building stream of chat data
        stream: getChatList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No chats available"));
          }

          var chatList = snapshot.data!;

          // Group chats by mechanicId and pick the latest message
          Map<String, Map<String, dynamic>> groupedChats = {};
          for (var chat in chatList) {
            String mechanicId = chat['mechanicId'];
            if (!groupedChats.containsKey(mechanicId)) {
              groupedChats[mechanicId] = chat;
            } else {
              // Replace with the most recent message
              var currentMessageTime =
                  chat['timestamp'] != null && chat['timestamp'] is Timestamp
                      ? (chat['timestamp'] as Timestamp).toDate()
                      : DateTime.fromMillisecondsSinceEpoch(
                          0); // Default to epoch time

              var existingMessageTime =
                  groupedChats[mechanicId]?['timestamp'] != null &&
                          groupedChats[mechanicId]?['timestamp'] is Timestamp
                      ? (groupedChats[mechanicId]?['timestamp'] as Timestamp)
                          .toDate()
                      : DateTime.fromMillisecondsSinceEpoch(
                          0); // Default to epoch time

              if (currentMessageTime.isAfter(existingMessageTime)) {
                groupedChats[mechanicId] = chat;
              }
            }
          }

          var finalChatList = groupedChats.values.toList();

          return ListView.builder(
            itemCount: chatList.length,
            itemBuilder: (context, index) {
              var chat = chatList[index];
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: chat['mechanicProfileImage'] != null
                      ? NetworkImage(chat['mechanicProfileImage'])
                      : null,
                  child: chat['mechanicProfileImage'] == null
                      ? Icon(Icons.person, size: 30)
                      : null,
                ),
                title: Text(
                  chat['mechanicName'] ?? 'Unknown Name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      chat['latestMessage'] ?? '', // Display the latest message
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Truncate long messages
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        // Date and time of the latest message
                        Text(
                          chat['timestamp'] != null &&
                                  chat['timestamp'] is Timestamp
                              ? (chat['timestamp'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]
                              : "No Date",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(width: 10),
                        Text(
                          chat['timestamp'] != null &&
                                  chat['timestamp'] is Timestamp
                              ? (chat['timestamp'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .split(' ')[1]
                                  .substring(0, 5)
                              : "00:00",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.message, size: 30, color: Colors.orange),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerChatScreen(
                          mechanicId: chat['mechanicId'],
                          shopName: chat['mechanicName'] ?? 'Unknown',
                          mechanicImageUrl: chat['mechanicProfileImage'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerChatScreen(
                        mechanicId: chat['mechanicId'],
                        shopName: chat['mechanicName'] ?? 'Unknown',
                        mechanicImageUrl: chat['mechanicProfileImage'] ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          );
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
        currentIndex: 2,
      ),
    );
  }
}
