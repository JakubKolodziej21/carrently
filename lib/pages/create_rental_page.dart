import 'package:carrently/models/car.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CreateRentalScreen(),
    );
  }
}

class CreateRentalScreen extends StatefulWidget {
  const CreateRentalScreen({Key? key}) : super(key: key);

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
      firstDate: DateTime.now(),
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

  String formatCustomDateTime(DateTime dateTime) {
    String dayOfWeek = DateFormat('EEE').format(dateTime);
    String month = DateFormat('MMM').format(dateTime);
    String day = dateTime.day.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    String time = DateFormat('HH:mm:ss').format(dateTime);

    String gmtOffset = dateTime.timeZoneOffset.isNegative 
        ? 'GMT-${dateTime.timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}00' 
        : 'GMT+${dateTime.timeZoneOffset.inHours.toString().padLeft(2, '0')}00';

    String timezoneDescription = (dateTime.month >= 3 && dateTime.month < 11) 
        ? '(czas środkowoeuropejski letni)' 
        : '(czas środkowoeuropejski standardowy)';

    return '$dayOfWeek $month $day $year $time $gmtOffset $timezoneDescription';
  }

  DateTime parseCustomDateTime(String dateString) {
    try {
      // Przykładowy format: "Thu Oct 31 2024 00:00:00 GMT+0000 (czas środkowoeuropejski letni)"
      List<String> parts = dateString.split(' ');

      // Sprawdzamy, czy format jest poprawny
      if (parts.length < 6) {
        throw FormatException("Invalid date format: $dateString");
      }

      String month = parts[1];      // Miesiąc
      String day = parts[2];        // Dzień
      String year = parts[3];       // Rok
      String time = parts[4];       // Czas

      // Konwersja miesiąca na numer
      int monthNumber = DateFormat('MMM').parse(month).month;

      // Budowanie daty jako String do parsowania przez DateTime
      String dateTimeString = '$year-${monthNumber.toString().padLeft(2, '0')}-$day $time';

      // Obsługa GMT offsetu
      String gmtOffset = parts[5].replaceFirst("GMT", "").trim().replaceFirst(" ", ""); // Usuwamy 'GMT' i spacje
      String adjustedDateTimeString = dateTimeString + gmtOffset;

      // Użycie DateTime.parse
      return DateTime.parse(adjustedDateTimeString);
    } catch (e) {
      print('Error parsing date: $e'); // Logowanie błędu
      throw FormatException("Error parsing date: $dateString");
    }
  }

  Future<void> createRental() async {
    if (selectedCar == null || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę wybrać wszystkie pola')),
      );
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data zakończenia musi być później niż data rozpoczęcia')),
      );
      return;
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie można znaleźć użytkownika')),
      );
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 1. Sprawdzenie, czy użytkownik ma już aktywną rezerwację
    var userDoc = await firestore.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data()?['current_rent_id'] != null && userDoc.data()?['current_rent_id'] != '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masz już aktywną rezerwację. Nie możesz wynająć kolejnego samochodu.')),
      );
      return;
    }

    // 2. Sprawdzenie, czy samochód jest dostępny w wybranym terminie
    var rentalsQuery = await firestore
        .collection('rentals')
        .where('car_id', isEqualTo: selectedCar!.id)
        .get();

    for (var doc in rentalsQuery.docs) {
      var data = doc.data();
      
      DateTime carStartDate = parseCustomDateTime(data['date_start']);
      DateTime carEndDate = parseCustomDateTime(data['date_end']);

      // Sprawdzenie, czy terminy się pokrywają
      bool isOverlapping = !(endDate!.isBefore(carStartDate) || startDate!.isAfter(carEndDate));
      if (isOverlapping) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Samochód jest już zajęty w wybranym terminie.')),
        );
        return;
      }
    }

    // Jeśli użytkownik nie istnieje, utwórz go
    if (!userDoc.exists) {
      await firestore.collection('users').doc(userId).set({
        'client_id': userId,
        'company': 'Default',
        'current_rent_id': '',
        'email': FirebaseAuth.instance.currentUser?.email,
        'favourite_cars': [],
        'name': 'Default',
        'surname': 'Default',
        'phone': '000-000-000'
      });
    }

    // Tworzenie nowej rezerwacji
    var rentalDoc = await firestore.collection('rentals').add({
      'car_id': selectedCar!.id,
      'date_start': formatCustomDateTime(startDate!), // Użycie nowej funkcji
      'date_end': formatCustomDateTime(endDate!),     // Użycie nowej funkcji
      'user_id': userId
    });

    // Aktualizacja pola current_rent_id u użytkownika
    await firestore.collection('users').doc(userId).update({
      'current_rent_id': rentalDoc.id,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rezerwacja utworzona pomyślnie')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stwórz Rezerwację"),
        backgroundColor: Colors.lightBlueAccent[400],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.white, Colors.lightBlueAccent],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: Colors.teal.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
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
                              child: Text(
                                "${car.brand} ${car.name} (${car.year})",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlueAccent[700],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                          onPressed: () => _selectDate(context, isStartDate: true),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Wybierz datę rozpoczęcia'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          startDate != null
                              ? 'Data rozpoczęcia: ${DateFormat('yyyy-MM-dd').format(startDate!)}'
                              : 'Brak wybranej daty rozpoczęcia',
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                          onPressed: () => _selectDate(context, isStartDate: false),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Wybierz datę zakończenia'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          endDate != null
                              ? 'Data zakończenia: ${DateFormat('yyyy-MM-dd').format(endDate!)}'
                              : 'Brak wybranej daty zakończenia',
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                          onPressed: createRental,
                          child: const Text('Utwórz Rezerwację'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
