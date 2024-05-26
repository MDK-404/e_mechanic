import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_mechanic/screens/navbar.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();
  String _selectedCity = '';
  String _selectedVehicleType = 'Car';
  String _selectedShop = '';
  List<String> _shopOptions = [];
  bool _isLoadingShops = false;
  List<String> _selectedServices = [];
  List<String> _services = ['Tuning', 'Electric Work', 'Complete Engine Work'];
  List<String> shopTypes = [];
  String? selectedShopType;
  String? selectedarea;
  String? city;
  List<String> area = [];
  Map<String, dynamic> shopAvailability = {};

  @override
  void initState() {
    super.initState();
    fetchMechanicsData();
  }

  Future<void> fetchMechanicsData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('mechanics').get();
      List<String> tempShopTypes = [];
      String? tempCity;
      List<String> tempArea = [];
      Map<String, dynamic> tempAvailability = {};
      snapshot.docs.forEach((doc) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['shopName'] != null) {
          tempShopTypes.add(data['shopName']);
          tempAvailability[data['shopName']] = data['availability'];
        }
        if (data['area'] != null) {
          tempArea.add(data['area']);
        }
        if (data['city'] != null && tempCity == null) {
          tempCity = data['city'];
          print(tempCity);
        }
      });

      setState(() {
        shopTypes = tempShopTypes;
        city = tempCity;
        area = tempArea;
        shopAvailability = tempAvailability;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _confirmBooking() async {
    if (_selectedCity.isEmpty ||
        selectedShopType == null ||
        _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all the required fields.')),
      );
      return;
    }

    // Save the booking details in Firestore
    final bookingData = {
      'city': _selectedCity,
      'shop': selectedShopType,
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      String dayOfWeek = _getDayOfWeek(pickedDate);
      bool isShopOpen = shopAvailability[selectedShopType]?[dayOfWeek] ?? true;

      if (isShopOpen) {
        setState(() {
          _selectedDate = pickedDate;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'The shop is closed on ${dayOfWeek}s. Please select another date.'),
          ),
        );
      }
    }
  }

  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
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
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              hint: Text('Select Shop'),
              value: selectedShopType,
              onChanged: (newValue) {
                setState(() {
                  selectedShopType = newValue;
                });
              },
              items: shopTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  selectedShopType == null ? null : () => _selectDate(context),
              child: Text('Select Date'),
            ),
            SizedBox(height: 20),
            if (_selectedDate != null)
              Text('Selected Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
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
        currentIndex: 1,
      ),
    );
  }
}
