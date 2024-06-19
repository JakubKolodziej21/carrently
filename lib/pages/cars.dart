import 'package:flutter/material.dart';

class CarsListPage extends StatelessWidget {
  final List<Car> cars;

  CarsListPage({Key? key, required this.cars}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Samochody do wypożyczenia'),
      ),
      body: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Image.asset(cars[index].imageUrl, width: 100, fit: BoxFit.cover),
              title: Text('${cars[index].make} ${cars[index].model}'),
              subtitle: Text('${cars[index].year} - \$${cars[index].pricePerDay}/dzień'),
              onTap: () {
                // Akcja po kliknięciu na element listy, np. przejście do szczegółów
              },
            ),
          );
        },
      ),
    );
  }
}

class Car {
  final String make;
  final String model;
  final int year;
  final double pricePerDay;
  final String imageUrl;

  Car({required this.make, required this.model, required this.year, required this.pricePerDay, required this.imageUrl});
}


List<Car> cars = [
  Car(make: 'Toyota', model: 'Corolla', year: 2020, pricePerDay: 30, imageUrl: 'assets/images/toyota_corolla.jpg'),
  Car(make: 'Honda', model: 'Civic', year: 2019, pricePerDay: 28, imageUrl: 'assets/images/honda_civic.jpg'),
  Car(make: 'Ford', model: 'Mustang', year: 2021, pricePerDay: 45, imageUrl: 'assets/images/ford_mustang.jpg'),
  // Dodaj więcej samochodów według potrzeb
];

