import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/screens/customer_home.dart';
import 'package:e_mechanic/screens/customer_profile.dart';
import 'package:e_mechanic/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomerLogin extends StatefulWidget {
  const CustomerLogin({Key? key}) : super(key: key);

  static String verify = "";

  @override
  State<CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<CustomerLogin> {
  final TextEditingController countryController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool loading = false;
  bool _isLoading = false;
  String phone = "";

  @override
  void initState() {
    countryController.text = "+92";
    super.initState();
  }

  /// Save device token to Firestore
  Future<void> _saveDeviceToken(User? user) async {
    if (user != null) {
      FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('customers').doc(user.uid);

        try {
          DocumentSnapshot docSnapshot = await docRef.get();
          if (docSnapshot.exists) {
            await docRef.update({'deviceToken': token});
            print(token);
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
  /// Handle Google Sign-In
  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign out from previous Google account if any
      await _googleSignIn.signOut();

      // Start new sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        setState(() {
          _isLoading = false;
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
        DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .get();

        if (customerSnapshot.exists) {
          // Navigate to Home Screen if user already exists
          Navigator.pushReplacementNamed(context, 'customer_home');
        } else {
          // Navigate to Profile Setup Screen if user is new
          Navigator.pushReplacementNamed(context, 'customer_profile');
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Google Sign-In error: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Google sign-in failed. Please try again.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
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
                  Positioned(
                    bottom: -20,
                    child: Text(
                      "Continue as a customer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                "Phone Verification",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "We need to register your phone before getting started!",
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: countryController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const Text(
                      "|",
                      style: TextStyle(fontSize: 33, color: Colors.black),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          phone = value;
                        },
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Phone",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    try {
                      await _auth.verifyPhoneNumber(
                        phoneNumber: '${countryController.text + phone}',
                        verificationCompleted: (_) {},
                        verificationFailed: (e) {
                          setState(() {
                            loading = false;
                          });
                          Utils().toastMessage(e.toString());
                        },
                        codeSent: (String verificationId, int? token) {
                          CustomerLogin.verify = verificationId;
                          setState(() {
                            loading = false;
                          });
                          Navigator.pushReplacementNamed(context, 'otp');
                        },
                        codeAutoRetrievalTimeout: (e) {
                          Utils().toastMessage(e.toString());
                          setState(() {
                            loading = false;
                          });
                        },
                      );
                    } catch (e) {
                      setState(() {
                        loading = false;
                      });
                      print(e);
                    }
                  },
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Send the code"),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Or"),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
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
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'mainscreen');
                },
                child: Text(
                  "Login as a Mechanic?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//         margin: const EdgeInsets.only(left: 25, right: 25),
//         alignment: Alignment.center,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/images/verifyr.png',
//                 width: 150,
//                 height: 150,
//               ),
//               const SizedBox(height: 25),
//               const Text(
//                 "Phone Verification",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Poppins',
//                   color: Colors.orange,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 "We need to register your phone before getting started!",
//                 style: TextStyle(fontSize: 16, color: Colors.black),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),
//               Container(
//                 height: 55,
//                 decoration: BoxDecoration(
//                   border: Border.all(width: 1, color: Colors.grey),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(width: 10),
//                     SizedBox(
//                       width: 40,
//                       child: TextField(
//                         controller: countryController,
//                         keyboardType: TextInputType.phone,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                         ),
//                         style: const TextStyle(color: Colors.black),
//                       ),
//                     ),
//                     const Text(
//                       "|",
//                       style: TextStyle(fontSize: 33, color: Colors.black),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: TextField(
//                         onChanged: (value) {
//                           phone = value;
//                         },
//                         keyboardType: TextInputType.phone,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           hintText: "Phone",
//                           hintStyle: TextStyle(color: Colors.black),
//                         ),
//                         style: const TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 45,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () async {
//                     setState(() {
//                       loading = true;
//                     });
//                     try {
//                       await _auth.verifyPhoneNumber(
//                         phoneNumber: '${countryController.text + phone}',
//                         verificationCompleted: (_) {},
//                         verificationFailed: (e) {
//                           setState(() {
//                             loading = false;
//                           });
//                           Utils().toastMessage(e.toString());
//                         },
//                         codeSent: (String verificationId, int? token) {
//                           CustomerLogin.verify = verificationId;
//                           setState(() {
//                             loading = false;
//                           });
//                           Navigator.pushReplacementNamed(context, 'otp');
//                         },
//                         codeAutoRetrievalTimeout: (e) {
//                           Utils().toastMessage(e.toString());
//                           setState(() {
//                             loading = false;
//                           });
//                         },
//                       );
//                     } catch (e) {
//                       setState(() {
//                         loading = false;
//                       });
//                       print(e);
//                     }
//                   },
//                   child: loading
//                       ? const CircularProgressIndicator(
//                           color: Colors.white,
//                         )
//                       : const Text("Send the code"),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text("Or"),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 45,
//                 child: ElevatedButton(
//                   onPressed: _loginWithGoogle,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     side: BorderSide(color: Colors.orange),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset('assets/images/google_logo.png', height: 20),
//                       SizedBox(width: 10),
//                       Text(
//                         "Login with Google",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.orange,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
