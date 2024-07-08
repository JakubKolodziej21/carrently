import 'package:carrently/models/car.dart';
import 'package:carrently/models/rentals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carrently/auth.dart';  
class CreateRentalScreen extends StatefulWidget {
  @override
  _CreateRentalScreenState createState() => _CreateRentalScreenState();
}

class _CreateRentalScreenState extends State<CreateRentalScreen> {
  List<Car> cars = [];
  Car? selectedCar;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  void fetchCars() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var querySnapshot = await firestore.collection('cars').get();
    setState(() {
      cars = querySnapshot.docs.map((doc) {
        var data = doc.data();
        return data is Map<String, dynamic> ? Car.fromMap(data, doc.id) : null;
      }).where((car) => car != null).cast<Car>().toList();
    });
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void createRental() async {
    String? userId = getUserId(); // Uzyskaj ID zalogowanego użytkownika
    if (selectedCar != null && startDate != null && endDate != null && userId != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('rentals').add({
        'car_id': selectedCar!.id,
        'date_start': startDate!.toIso8601String(),
        'date_end': endDate!.toIso8601String(),
        'user_id': userId  // Użyj uzyskanego ID użytkownika
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rental created successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select all fields or log in')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Rental"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            DropdownButton<Car>(
              value: selectedCar,
              onChanged: (Car? newValue) {
                setState(() {
                  selectedCar = newValue;
                });
              },
              items: cars.map<DropdownMenuItem<Car>>((Car car) {
                return DropdownMenuItem<Car>(
                  value: car,
                  child: Text("${car.brand} ${car.name} (${car.year})"),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () => _selectDate(context, isStartDate: true),
              child: Text('Select Start Date'),
            ),
            Text(startDate != null ? 'Start Date: ${startDate!.toIso8601String()}' : 'No start date selected'),
            ElevatedButton(
              onPressed: () => _selectDate(context, isStartDate: false),
              child: Text('Select End Date'),
            ),
            Text(endDate != null ? 'End Date: ${endDate!.toIso8601String()}' : 'No end date selected'),
            ElevatedButton(
              onPressed: createRental,
              child: Text('Create Rental'),
            ),
          ],
        ),
      ),
    );
  }
}
