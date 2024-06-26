import 'package:carrently/models/car.dart';
import 'package:carrently/services/firestrore_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CarsListScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista samochodów")),
      body: StreamBuilder<List<Car>>(
        stream: _firestoreService.streamCars(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Wyświetlanie szczegółów błędu, jeśli wystąpi
            return Text("Wystąpił błąd: ${snapshot.error}");
          }
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var cars = snapshot.data!;
          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              Car car = cars[index];
              return ListTile(
                title: Text(car.name),
                subtitle: Text("${car.brand} - ${car.year}"),
                leading: FutureBuilder(
                  future: _getImageUrl(car.thumbnailImage),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      return Image.network(snapshot.data!);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return Icon(Icons.error);  // W przypadku błędu ładowania obrazu
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _getImageUrl(String imagePath) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Failed to load image URL: $e");
      return '';  // Można zwrócić pusty string jako fallback
    }
  }
}
