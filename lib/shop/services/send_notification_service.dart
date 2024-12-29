import 'dart:convert';

import 'package:e_mechanic/shop/services/get_service_key.dart';
import 'package:http/http.dart' as http;

class SendNotificaitonService {
  static Future<void> sendNotificationUsingApi({
    required String? token,
    required String? title,
    required String? body,
    required Map<String, dynamic>? data,
  }) async {
    String serverKey = await GetServerKey().getServerKeyToken();
    print("Notificaiton Server key=> ${serverKey} ");
    String url =
        "https://fcm.googleapis.com/v1/projects/emechanicfyp-8f13f/messages:send";

    var headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };
    Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {"body": body, "title": title},
        "data": data,
      }
    };

    // hit api
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(message),
    );
    if (response.statusCode == 200) {
      print(" Notification Send Successfully");
    } else {
      print("Notificaiton not send");
    }
  }
}
