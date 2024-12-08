import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  // static keyword ka maqsad taka hum is method ka instance banaye bagehr use kr saky
  static void firebaseInit() {
    FirebaseMessaging.onMessage.listen(
      (message) {
        print(message.notification!.title);
        print(message.notification!.body);
      },
    );
  }
}
