import 'package:flutter/material.dart';

class MechanicProfile extends StatefulWidget {
  @override
  _MechanicProfileState createState() => _MechanicProfileState();
}

class _MechanicProfileState extends State<MechanicProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mechanic Profile'),
      ),
      body: Center(
        child: Text(
          'Mechanic Profile Screen',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
