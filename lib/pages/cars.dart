import 'package:carrently/models/car.dart';
import 'package:carrently/services/firestrore_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CarsListScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista samochodów"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Dodaj funkcjonalność wyszukiwania
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<List<Car>>(
          stream: _firestoreService.streamCars(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Wystąpił błąd: ${snapshot.error}"),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            var cars = snapshot.data!;
            return ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                Car car = cars[index];
                return Card(
                  margin: EdgeInsets.all(5),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    title: Text(
                      car.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${car.year}"),
                        SizedBox(height: 5),
                        _carDetailRow(Icons.attach_money, "Koszt na km: \$${car.costPerKm.toStringAsFixed(2)}"),
                        _carDetailRow(Icons.timer, "Opóźnienie kara: \$${car.delayFine}"),
                        _carDetailRow(Icons.door_front_door, "Liczba drzwi: ${car.doors}"),
                        _carDetailRow(Icons.local_gas_station, "Rodzaj paliwa: ${car.fuelType}"),
                        _carDetailRow(Icons.opacity, "Pojemność paliwa: ${car.fuelCapacity} L"),
                        _carDetailRow(Icons.settings, "Skrzynia biegów: ${car.gearbox}"),
                        _carDetailRow(Icons.speed, "Przebieg: ${car.mileage} km"),
                        _carDetailRow(Icons.event_seat, "Liczba miejsc: ${car.seats}"),
                        _carDetailRow(Icons.directions_car, "Typ: ${car.type}"),
                      ],
                    ),
                    leading: FutureBuilder(
                      future: _getImageUrl(car.thumbnailImage),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                          return CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(snapshot.data!),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.directions_car),
                      onPressed: () {
                        // Dodaj funkcjonalność wypożyczania
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Row _carDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  Future<String> _getImageUrl(String imagePath) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Failed to load image URL: $e");
      return ''; // Można zwrócić pusty string jako fallback
    }
  }
}