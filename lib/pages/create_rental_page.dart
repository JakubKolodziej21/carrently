import 'package:carrently/models/car.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        var data = doc.data() as Map<String, dynamic>;
        return Car.fromMap(data, doc.id);
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Ensure no past dates are selectable
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

 Future<bool> isCarAvailable() async {
  if (selectedCar == null || startDate == null || endDate == null) return false;

  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var rentalsQuery = firestore.collection('rentals')
      .where('car_id', isEqualTo: selectedCar!.id)
      .where('date_end', isGreaterThan: startDate!.toIso8601String())
      .where('date_start', isLessThan: endDate!.toIso8601String());

    var querySnapshot = await rentalsQuery.get();
    return querySnapshot.docs.isEmpty;
  } catch (e) {
    print("Error checking car availability: $e");
    return false;
  }
}




  Future<void> createRental() async {
    if (selectedCar == null || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select all fields')));
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('End date must be after start date')));
      return;
    }

    if (!await isCarAvailable()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Car is already booked for selected dates')));
      return;
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('rentals').add({
      'car_id': selectedCar!.id,
      'date_start': startDate!.toIso8601String(),
      'date_end': endDate!.toIso8601String(),
      'user_id': userId  // Use the obtained user ID
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rental created successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Rental"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (cars.isNotEmpty) 
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
