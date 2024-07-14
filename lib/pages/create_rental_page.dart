import 'package:carrently/models/car.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import do formatowania dat

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Proszę wybrać wszystkie pola')));
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data zakończenia musi być później niż data rozpoczęcia')));
      return;
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('rentals').add({
      'car_id': selectedCar!.id,
      'date_start': DateFormat('yyyy-MM-dd').format(startDate!), // Formatowanie daty
      'date_end': DateFormat('yyyy-MM-dd').format(endDate!), // Formatowanie daty
      'user_id': userId  // Użycie uzyskanego ID użytkownika
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rezerwacja utworzona pomyślnie')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stwórz Rezerwację"),
        backgroundColor: Colors.blue, // Niebieski kolor dla AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue, Colors.blueAccent],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Pomarańczowy kolor przycisku
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: () => _selectDate(context, isStartDate: true),
                  child: Text('Wybierz datę rozpoczęcia'),
                ),
                SizedBox(height: 10),
                Text(startDate != null ? 'Data rozpoczęcia: ${DateFormat('yyyy-MM-dd').format(startDate!)}' : 'Brak wybranej daty rozpoczęcia'),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: () => _selectDate(context, isStartDate: false),
                  child: Text('Wybierz datę zakończenia'),
                ),
                SizedBox(height: 10),
                Text(endDate != null ? 'Data zakończenia: ${DateFormat('yyyy-MM-dd').format(endDate!)}' : 'Brak wybranej daty zakończenia'),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: createRental,
                  child: Text('Utwórz Rezerwację'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
