// import 'package:e_mechanic/screens/mechanic_otp.dart';
// import 'package:e_mechanic/screens/otp.dart';
// import 'package:e_mechanic/utils/utils.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:provider/provider.dart';
// class MechanciLogin extends StatefulWidget {
//   const MechanciLogin({Key? key}) : super(key: key);

//   static String verify = "";

//   @override
//   State<MechanciLogin> createState() => _CustomerLoginState();
// }

// class _CustomerLoginState extends State<MechanciLogin> {
//   bool loading = false;
//   // Mobile number input ke liye controller

//   final TextEditingController countryController = TextEditingController();
//   var phone = "";
//   final auth = FirebaseAuth.instance;
//   @override
//   void initState() {
//     // TODO: implement initState
//     countryController.text = "+92";
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//         // color: Colors.black87,
//         margin: EdgeInsets.only(left: 25, right: 25),
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
//               SizedBox(
//                 height: 25,
//               ),
//               Text(
//                 "Phone Verification",
//                 style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                     color: Colors.orange),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 "We need to register your phone before getting started!",
//                 style: TextStyle(fontSize: 16, color: Colors.black),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               Container(
//                 height: 55,
//                 decoration: BoxDecoration(
//                     border: Border.all(width: 1, color: Colors.grey),
//                     borderRadius: BorderRadius.circular(10)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 10,
//                     ),
//                     SizedBox(
//                       width: 40,
//                       child: TextField(
//                         controller: countryController,
//                         keyboardType: TextInputType.phone,
//                         decoration: InputDecoration(
//                           border: InputBorder.none,
//                         ),
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                     Text(
//                       "|",
//                       style: TextStyle(fontSize: 33, color: Colors.black),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Expanded(
//                         child: TextField(
//                       onChanged: (value) {
//                         phone = value;
//                       },
//                       keyboardType: TextInputType.phone,
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: "Phone",
//                         hintStyle: TextStyle(color: Colors.black),
//                       ),
//                       style: TextStyle(color: Colors.black),
//                     ))
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               SizedBox(
//                 width: double.infinity,
//                 height: 45,

//                 // child: ElevatedButton(
//                 //   onPressed: () {
//                 //     Navigator.pushNamed(context, 'mechanic_otp');
//                 //   },
//                 //   child: Text(
//                 //     ' Login',
//                 //     style: TextStyle(
//                 //       fontSize: 18.0,
//                 //       fontWeight: FontWeight.bold,
//                 //       color: Colors.orange,
//                 //       fontFamily: 'Poppins',
//                 //     ),
//                 //   ),
//                 // ),
//                 child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         //primary: Colors.green.shade600,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10))),
//                     onPressed: () async {
//                       await auth.verifyPhoneNumber(
//                           phoneNumber: '${countryController.text + phone}',
//                           verificationCompleted: (_) {},
//                           verificationFailed: (e) {
//                             setState(() {
//                               loading = false;
//                             });
//                             Utils().toastMessage(e.toString());
//                           },
//                           codeSent: (String verificationid, int? token) {

//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => OTPVerification(
//                                         verificationid: verificationid)));
//                             setState(() {
//                               loading = false;
//                             });
//                           },
//                           codeAutoRetrievalTimeout: (e) {
//                             Utils().toastMessage(e.toString());
//                             setState(() {
//                               loading = false;
//                             });
//                           });
//                       //Navigator.pushNamed(context, 'otp');
//                     },
//                     child: Text("Send the code")
//                     ),
//               ),
//               SizedBox(height: 20),
//               SizedBox(
//   width: double.infinity,
//   height: 45,
//   child: ElevatedButton(
//     onPressed: _loginWithGoogle,
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.white, // White background for the button
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side: BorderSide(color: Colors.orange), // Orange border
//       ),
//     ),

//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Image.asset(
//           'assets/images/google_logo.png', // Add your Google logo image here
//           height: 20,
//         ),
//         SizedBox(width: 10),
//         Text(
//           "Login with Google",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.orange,
//           ),
//         ),
//       ],
//     ),
//   ),
// ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:e_mechanic/screens/mechanic_profile.dart';
import 'package:e_mechanic/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  void _loginWithGoogle() async {
    setState(() {
      loading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
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
      final uid = userCredential.user?.uid;

      if (uid != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('mechanics')
            .doc(uid)
            .get();

        if (docSnapshot.exists) {
          Navigator.pushReplacementNamed(context, 'mechanic_dashboard');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MechanicProfile(),
            ),
          );
        }
      }
    } catch (e) {
      print(e);
      Utils().toastMessage('Google sign-in failed.');
    } finally {
      setState(() {
        loading = false;
      });
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/verifyr.png',
              width: 150,
              height: 150,
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
          ],
        ),
      ),
    );
  }
}
