import 'package:e_mechanic/screens/customer_login.dart';
import 'package:e_mechanic/screens/mechanic_dashboard.dart';
import 'package:e_mechanic/screens/mechanic_profile.dart';
import 'package:e_mechanic/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OTPVerification extends StatefulWidget {
  final String verificationid;
  const OTPVerification({Key? key, required this.verificationid})
      : super(key: key);

  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        margin: const EdgeInsets.symmetric(horizontal: 25),
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
                  color: Colors.orange,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                controller: otpController,
                showCursor: true,
                onChanged: (value) {},
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final credential = PhoneAuthProvider.credential(
                      verificationId: widget.verificationid,
                      smsCode: otpController.text,
                    );

                    try {
                      await auth.signInWithCredential(credential);

                      var user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        Navigator.pushNamed(context, 'mechanic_dashboard');
                      } else {
                        Navigator.pushNamed(context, 'mechanic_profile');
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
                      Navigator.pushNamed(context, 'mechanic_login ');
                    },
                    child: const Text(
                      "Edit Phone Number ?",
                      style: TextStyle(color: Colors.black),
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
