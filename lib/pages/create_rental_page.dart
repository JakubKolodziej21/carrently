import 'package:carrently/models/car.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateRentalScreen extends StatefulWidget {
  const CreateRentalScreen({super.key});

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
        return Car.fromMap(data, doc.id);
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Zapobiega wybraniu daty z przeszłości
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

  Future<void> createRental() async {
    if (selectedCar == null || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: const Text('Proszę wybrać wszystkie pola')));
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data zakończenia musi być później niż data rozpoczęcia')));
      return;
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('rentals').add({
      'car_id': selectedCar!.id,
      'date_start': DateFormat('yyyy-MM-dd').format(startDate!),
      'date_end': DateFormat('yyyy-MM-dd').format(endDate!),
      'user_id': userId
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rezerwacja utworzona pomyślnie')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stwórz Rezerwację"),
        backgroundColor: Colors.blue, // Niebieski kolor dla AppBar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButton<Car>(
                  isExpanded: true,
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
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: () => _selectDate(context, isStartDate: true),
                  child: const Text('Wybierz datę rozpoczęcia'),
                ),
                const SizedBox(height: 10),
                Text(startDate != null ? 'Data rozpoczęcia: ${DateFormat('yyyy-MM-dd').format(startDate!)}' : 'Brak wybranej daty rozpoczęcia'),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: () => _selectDate(context, isStartDate: false),
                  child: const Text('Wybierz datę zakończenia'),
                ),
                const SizedBox(height: 10),
                Text(endDate != null ? 'Data zakończenia: ${DateFormat('yyyy-MM-dd').format(endDate!)}' : 'Brak wybranej daty zakończenia'),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: createRental,
                  child: const Text('Utwórz Rezerwację'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
