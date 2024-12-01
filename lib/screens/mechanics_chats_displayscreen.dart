import 'package:e_mechanic/screens/mechanic_navbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_mechanic/shop/screens/mechanic_chatscreen.dart';

class MechanicChatListScreen extends StatefulWidget {
  @override
  _MechanicChatListScreenState createState() => _MechanicChatListScreenState();
}

class _MechanicChatListScreenState extends State<MechanicChatListScreen> {
  late String mechanicId;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      mechanicId = user.uid;
    }
  }

  Stream<List<Map<String, dynamic>>> getChatList() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('mechanicId', isEqualTo: mechanicId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      Map<String, Map<String, dynamic>> groupedChats = {};

      for (var doc in snapshot.docs) {
        var chat = doc.data() as Map<String, dynamic>;
        String customerId = chat['customerId'];

        if (!groupedChats.containsKey(customerId)) {
          groupedChats[customerId] = {
            'customerId': customerId,
            'customerName': chat['customerName'],
            'customerProfileImage': chat['customerProfileImage'],
            'latestMessage': chat['message'],
            'timestamp': chat['timestamp'],
          };
        } else {
          var currentMessageTime =
              (chat['timestamp'] as Timestamp?)?.toDate() ??
                  DateTime.fromMillisecondsSinceEpoch(0);
          var existingMessageTime =
              (groupedChats[customerId]!['timestamp'] as Timestamp?)
                      ?.toDate() ??
                  DateTime.fromMillisecondsSinceEpoch(0);

          if (currentMessageTime.isAfter(existingMessageTime)) {
            groupedChats[customerId] = chat;
          }
        }
      }

      return groupedChats.values.toList();
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
        stream: getChatList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Error loading chats: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
              "No Chats Available",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ));
          }

          var chatList = snapshot.data!;

          return ListView.builder(
            itemCount: chatList.length,
            itemBuilder: (context, index) {
              var chat = chatList[index];
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: chat['customerProfileImage'] != null
                      ? NetworkImage(chat['customerProfileImage'])
                      : null,
                  child: chat['customerProfileImage'] == null
                      ? Icon(Icons.person, size: 30)
                      : null,
                ),
                title: Text(
                  chat['customerName'] ?? 'Unknown Name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      chat['latestMessage'] ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
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
                        builder: (context) => MechanicChatScreen(
                          customerId: chat['customerId'],
                          customerName: chat['customerName'] ?? 'Unknown',
                          customerImageUrl: chat['customerProfileImage'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MechanicChatScreen(
                        customerId: chat['customerId'],
                        customerName: chat['customerName'] ?? 'Unknown',
                        customerImageUrl: chat['customerProfileImage'] ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: MechanicBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, 'mechanic_dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, 'addproducts');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, 'mechanic_chat_list');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, 'mechanic_profile');
          }
        },
        currentIndex: 2,
      ),
    );
  }
}
