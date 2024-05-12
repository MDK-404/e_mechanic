import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/screens/customer_home.dart';
import 'package:e_mechanic/screens/customer_login.dart';
import 'package:e_mechanic/screens/mechanicprofile.dart';
import 'package:e_mechanic/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class MyVerify extends StatefulWidget {
  final String verificationid;
  const MyVerify({Key? key, required this.verificationid}) : super(key: key);

  @override
  State<MyVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends State<MyVerify> {
  final FirebaseAuth aut = FirebaseAuth.instance;
  final otpcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    var code = "";
    return Scaffold(
      backgroundColor: Colors.black87,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/verifyr.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Enter OTP",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.orange),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                controller: otpcontroller,
                showCursor: true,
                onChanged: (value) {
                  code = value;
                },
                // defaultPinTheme: defaultPinTheme,
                // focusedPinTheme: focusedPinTheme,
                // submittedPinTheme: submittedPinTheme,

                onCompleted: (pin) => print(pin),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final credential = PhoneAuthProvider.credential(
                      verificationId: widget.verificationid,
                      smsCode: otpcontroller.text,
                    );

                    try {
                      await aut.signInWithCredential(credential);

                      // Firebase se user ke details fetch karo
                      User? user = FirebaseAuth.instance.currentUser;
                      DocumentSnapshot snapshot = await FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(user?.uid)
                          .get();

                      String userType = "";
                      var data = snapshot.data();
                      if (data is Map<String, dynamic>) {
                        userType = data['userType'];
                      }
                      //String? userType = snapshot.data()?['userType'] as String?;

                      if (userType == 'mechanic') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MechanicProfile(),
                          ),
                        );
                      } else if (userType == 'customer') {
                        // Customer ki home screen par jaao
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerHomeScreen(),
                          ),
                        );
                      } else {
                        // Agar user type kuch aur hai, toh appropriate action lo
                        // Jaise error message dikhao ya koi default screen dikhao
                        Utils().toastMessage("Invalid user type");
                      }
                    } catch (e) {
                      Utils().toastMessage(e.toString());
                    }
                  },
                  child: const Text(
                    "Verify Phone Number",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'customerLogin');
                    },
                    child: const Text(
                      "Edit Phone Number ?",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
