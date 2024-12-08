import 'package:e_mechanic/screens/mechanic_profile.dart';
import 'package:e_mechanic/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MechanicLogin extends StatefulWidget {
  const MechanicLogin({Key? key}) : super(key: key);

  @override
  State<MechanicLogin> createState() => _MechanicLoginState();
}

class _MechanicLoginState extends State<MechanicLogin> {
  final TextEditingController countryController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool loading = false;
  String phone = "";

  @override
  void initState() {
    super.initState();
    countryController.text = "+92";
  }

  /// Save device token to Firestore
  Future<void> _saveDeviceToken(User? user) async {
    if (user != null) {
      FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('mechanics').doc(user.uid);

        try {
          DocumentSnapshot docSnapshot = await docRef.get();
          if (docSnapshot.exists) {
            await docRef.update({'deviceToken': token});
          } else {
            await docRef.set({'deviceToken': token});
          }
        } catch (e) {
          print("Error saving device token: $e");
        }
      }
    }
  }

  /// Handle Google Sign-In
  void _loginWithGoogle() async {
    setState(() {
      loading = true;
    });

    try {
      // Sign out from previous Google account if any
      await _googleSignIn.signOut();

      // Start new sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        setState(() {
          loading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      // Save FCM token
      await _saveDeviceToken(user);

      if (user != null) {
        // Check if the user already exists in "customers" collection
        DocumentSnapshot mechanicSnapshot = await FirebaseFirestore.instance
            .collection('mechanics')
            .doc(user.uid)
            .get();

        if (mechanicSnapshot.exists) {
          // Navigate to Home Screen if mechanic already exists
          Navigator.pushReplacementNamed(context, 'mechanic_dashboard');
        } else {
          // Navigate to Profile Setup Screen if mechanic is new
          Navigator.pushReplacementNamed(context, 'mechanic_profile');
        }
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      print("Google Sign-In error: $e");
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Google sign-in failed. Please try again.'),
      ));
    }
  }

   

  void _loginWithPhone() async {
    setState(() {
      loading = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: '${countryController.text + phone}',
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        Utils().toastMessage(e.toString());
        setState(() {
          loading = false;
        });
      },
      codeSent: (String verificationId, int? token) {
        Navigator.pushNamed(context, 'otp_screen', arguments: verificationId);
        setState(() {
          loading = false;
        });
      },
      codeAutoRetrievalTimeout: (e) {
        Utils().toastMessage(e.toString());
        setState(() {
          loading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          //padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/verifyr.png',
                    width: 150,
                    height: 150,
                  ),
                ],
              ),
              SizedBox(height: 25),
              Text(
                "Phone Verification",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Register your phone before getting started!",
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: countryController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(border: InputBorder.none),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Text("|",
                        style: TextStyle(fontSize: 33, color: Colors.black)),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => phone = value,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Phone",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginWithPhone,
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Send the code"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.orange),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/google_logo.png', height: 20),
                    SizedBox(width: 10),
                    Text(
                      "Login with Google",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'mainscreen');
                },
                child: Text(
                  "Login as a Customer?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
