import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
      carPlay: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user provisional  granted permission');
    } else {
      Get.snackbar(
        'Notification permission denied',
        'Please allow notificaitons to receive updated',
        snackPosition: SnackPosition.BOTTOM,
      );
      Future.delayed(Duration(seconds: 3), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  // init
  void inintLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitSetting =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initialaizationSetting =
        InitializationSettings(android: androidInitSetting);

    await _flutterLocalNotificationsPlugin.initialize(
      initialaizationSetting,
      onDidReceiveNotificationResponse: (payload) {
        handleMessage(context, message);
      },
    );
  }

  // handling firebase states (onpause, terminate, active)
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen(
      (message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification!.android;

        if (kDebugMode) {
          print("notificaiton title: ${notification!.title}");
          print("notificaiton title: ${notification.body}");
        }
        if (Platform.isAndroid) {
          inintLocalNotification(context, message);
          // handleMessage(context, message);
          showNotificaiton(message);
        }
      },
    );
  }

  // function  to show notificaiton

  Future<void> showNotificaiton(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: "Channel Description",
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: channel.sound,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // new update code
    print("Notification Data: ${message.data}");
    //show notificaition
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
        payload: "my_data",
      );
    });
  }
  // background and terminated state

  Future<void> setupInteractMessage(BuildContext context) async {
    // backgroun state
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(context, message);
    });
    //terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null && message.data.isNotEmpty) {
        handleMessage(context, message);
      }
    });
  }

  //handle mesage
  // Future<void> handleMessage(
  //     BuildContext context, RemoteMessage message) async {
  //   Navigator.pushNamed(context, 'customer_home');
  // }
  //handle mesage
  Future<void> handleMessage(
      BuildContext context, RemoteMessage message) async {
    // Notification data se screen aur orderId nikal rahe hain
    String screen = message.data['screen'] ?? '';
    String orderId = message.data['orderId'] ?? '';

    if (screen == 'OrdersScreen') {
      // Agar screen OrdersScreen hai, toh OrdersScreen par navigate karein aur orderId pass karein
      Navigator.pushNamed(context, 'order_screen');
    } else {
      // Default case mein customer_home screen par navigate karein
      Navigator.pushNamed(context, 'mechanic_dashboard');
    }
  }
}
