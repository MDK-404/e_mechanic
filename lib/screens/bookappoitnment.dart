import 'package:flutter/material.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({Key? key}) : super(key: key);

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCity = '';

  // Function to handle date selection
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Selected Date: ${_selectedDate.toString().substring(0, 10)}'),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'Enter Your City'),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality to confirm booking
              },
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}