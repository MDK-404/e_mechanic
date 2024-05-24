import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/screens/navbar.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({Key? key}) : super(key: key);

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCity = '';
  String _selectedVehicleType = 'Car';
  String _selectedShop = '';
  List<String> _selectedServices = [];
  List<String> _services = ['Tuning', 'Electric Work', 'Complete Engine Work'];
  List<String> _shopOptions = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle date selection
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      if (_selectedShop.isNotEmpty) {
        final bool isAvailable =
            await _isMechanicAvailable(_selectedShop, picked);
        if (isAvailable) {
          setState(() {
            _selectedDate = picked;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'The selected mechanic is not available on this date.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a mechanic shop first.')),
        );
      }
    }
  }

  // Mapping from weekday number to weekday name
  final Map<int, String> _weekdayNames = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  Future<bool> _isMechanicAvailable(String shopName, DateTime date) async {
    final mechanicSnapshot =
        await _firestore.collection('mechanics').doc(shopName).get();
    if (!mechanicSnapshot.exists) return false;

    final Map<String, dynamic> availability =
        mechanicSnapshot.get('availability');
    final String dayOfWeek =
        _weekdayNames[date.weekday]!; // Convert weekday number to name

    return availability[dayOfWeek] ?? false;
  }

  void _fetchShops(String city, String vehicleType) async {
    print('Fetching shops for city: $city and vehicleType: $vehicleType');
    try {
      final QuerySnapshot shopsSnapshot = await _firestore
          .collection('mechanics')
          .where('city', isEqualTo: city)
          .where('shopType',
              isEqualTo:
                  vehicleType == 'Car' ? 'car workshop' : 'bike workshop')
          .get();

      // Print each document to ensure correct data retrieval
      shopsSnapshot.docs.forEach((doc) {
        print('Shop: ${doc.data()}');
      });

      setState(() {
        _shopOptions = shopsSnapshot.docs
            .map<String>((doc) => '${doc.get('shopName')} - ${doc.get('area')}')
            .toList();
        _selectedShop = ''; // Reset selected shop
        print('Fetched shops: $_shopOptions');
      });
    } catch (e) {
      print('Error fetching shops: $e');
      setState(() {
        _shopOptions = [];
      });
    }
  }

  void _confirmBooking() async {
    if (_selectedCity.isEmpty ||
        _selectedShop.isEmpty ||
        _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all the required fields.')),
      );
      return;
    }

    // Save the booking details in Firestore
    final bookingData = {
      'city': _selectedCity,
      'shop': _selectedShop,
      'date': _selectedDate,
      'services': _selectedServices,
      'status': 'pending',
    };

    await _firestore.collection('bookings').add(bookingData);

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Booking Confirmed'),
          content: Text(
              'Your request has been sent and you will get an update after confirmation from the mechanic.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCity.isNotEmpty ? _selectedCity : null,
                hint: Text('Select City'),
                items: ['Rawalpindi', 'Islamabad'].map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value!;
                    _fetchShops(_selectedCity, _selectedVehicleType);
                  });
                },
              ),
              SizedBox(height: 20),
              Text('Select Vehicle Type'),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Car'),
                      leading: Radio<String>(
                        value: 'Car',
                        groupValue: _selectedVehicleType,
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleType = value!;
                            _fetchShops(_selectedCity, _selectedVehicleType);
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Bike'),
                      leading: Radio<String>(
                        value: 'Bike',
                        groupValue: _selectedVehicleType,
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleType = value!;
                            _fetchShops(_selectedCity, _selectedVehicleType);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedShop.isNotEmpty ? _selectedShop : null,
                hint: Text('Select Mechanic Shop'),
                items: _shopOptions.map((String shopName) {
                  return DropdownMenuItem<String>(
                    value: shopName,
                    child: Text(shopName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedShop = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Selected Date: ${_selectedDate.toString().substring(0, 10)}'),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select Date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              MultiSelectDialogField(
                items: _services
                    .map((service) => MultiSelectItem<String>(service, service))
                    .toList(),
                title: Text('Select Services'),
                buttonText: Text('Select Services'),
                initialValue: _selectedServices,
                onConfirm: (values) {
                  setState(() {
                    _selectedServices = values;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  child: Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, 'customer_home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, 'services');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, 'customer_profile');
          }
        },
        currentIndex: 0,
      ),
    );
  }
}
