import 'package:e_mechanic/firebase_options.dart';
import 'package:e_mechanic/screens/add_products.dart';
import 'package:e_mechanic/screens/appoinment.dart';
import 'package:e_mechanic/screens/customer_chatdisplay_screen.dart';
import 'package:e_mechanic/screens/customer_home.dart';
import 'package:e_mechanic/screens/customer_login.dart';
import 'package:e_mechanic/screens/customer_profile.dart';
import 'package:e_mechanic/screens/emergency_request_show.dart';
import 'package:e_mechanic/screens/main_screen.dart';
import 'package:e_mechanic/screens/mechanic_booking_screen.dart';
import 'package:e_mechanic/screens/mechanic_dashboard.dart';
import 'package:e_mechanic/screens/mechanic_login.dart';
import 'package:e_mechanic/screens/mechanic_otp.dart';
import 'package:e_mechanic/screens/mechanic_products_sceen.dart';
import 'package:e_mechanic/screens/mechanic_profile.dart';
import 'package:e_mechanic/screens/mechanics_chats_displayscreen.dart';
import 'package:e_mechanic/screens/orders_screen.dart';
import 'package:e_mechanic/screens/otp.dart';
import 'package:e_mechanic/screens/services.dart';
import 'package:e_mechanic/screens/splash_screen.dart';
import 'package:e_mechanic/shop/screens/cart_screen.dart';
import 'package:e_mechanic/shop/screens/mechanic_chatscreen.dart';
import 'package:e_mechanic/shop/screens/product_detail_screen.dart';
import 'package:e_mechanic/shop/screens/product_list_screen.dart';
import 'package:e_mechanic/shop/services/get_service_key.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:e_mechanic/shop/models/customer_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  final getServerKey = GetServerKey();
  final serverKeyToken = await getServerKey.getServerKeyToken();
  print('Server Key Token: $serverKeyToken');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        'splash': (context) => const SplashScreen(),
        'mainscreen': (context) => MainScreen(),
        'customerLogin': (context) => CustomerLogin(),
        'customer_home': (context) => CustomerHomeScreen(),
        'customer_profile': (context) => CustomerProfile(),
        'mechanic_profile': (context) => MechanicProfile(),
        'mechanic_login': (context) => MechanicLogin(),
        'addproducts': (context) => AddProductScreen(),
        'appoitnment': (context) => AppointmentScreen(),
        'services': (context) => ServicesScreen(),
        'customer_chat_list_screen': (context) => CustomerChatListScreen(),
        'mechanic_chat_list_screen': (context) => MechanicChatListScreen(),
        'mechanic_dashboard': (context) => MechanicDashboard(),
        'mechanic_products': (context) => YourProductsScreen(),
        'bookings_screen': (context) => BookingsScreen(),
        'order_screen': (context) => OrdersScreen(),
        'cart': (context) => CartScreen(),
        'emergency_screen': (context) => EmergencyRequestsScreen(),
        'product_list': (context) => ProductListScreen(),
        'mechanic_otp': (context) => OTPVerification(
              verificationid: 'verificationid',
            ),

        // below otp verification route is  for user
        'otp': (context) => MyVerify(
              verificationid: 'verificationid',
            ), // customers login otp
      },
    );
  }
}
