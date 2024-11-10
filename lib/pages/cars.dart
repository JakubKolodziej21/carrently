import 'package:carrently/models/car.dart';
import 'package:carrently/services/firestrore_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// A screen displaying a list of available cars for rental.
class CarsListScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  CarsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista samochodów',
          style: TextStyle(color: Colors.blueAccent), // Title color
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.blueAccent,
            onPressed: () {
              // Add search functionality
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            var cars = snapshot.data!;
            return ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                Car car = cars[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: FutureBuilder(
                          future: _getImageUrl(car.thumbnailImage),
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return Image.network(
                                snapshot.data!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              );
                            } else {
                              return Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _carDetailRow(Icons.attach_money, "Koszt za dzień: \$${car.startCost.toStringAsFixed(2)}"),
                                _carDetailRow(Icons.timer, "Opóźnienie kara: \$${car.delayFine}"),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _carDetailRow(Icons.door_front_door, "Liczba drzwi: ${car.doors}"),
                                _carDetailRow(Icons.local_gas_station, "Paliwo: ${car.fuelType}"),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _carDetailRow(Icons.opacity, "Pojemność: ${car.fuelCapacity} L"),
                                _carDetailRow(Icons.settings, "Skrzynia: ${car.gearbox}"),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _carDetailRow(Icons.speed, "Przebieg: ${car.mileage} km"),
                                _carDetailRow(Icons.event_seat, "Miejsca: ${car.seats}"),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _carDetailRow(Icons.directions_car, "Typ: ${car.type}"),
                                IconButton(
                                  icon: const Icon(Icons.directions_car),
                                  onPressed: () {
                                    // Add rental functionality
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Creates a row displaying a car detail with an icon and text.
  Row _carDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  /// Retrieves the URL of the car's thumbnail image from Firebase Storage.
  Future<String> _getImageUrl(String imagePath) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Failed to load image URL: $e");
      return ''; 
    }
  }
}
