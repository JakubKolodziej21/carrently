import 'package:carrently/auth.dart';
import 'package:carrently/models/rentals.dart';
import 'package:carrently/pages/create_rental_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentalsScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? userId = getUserId();

  Stream<List<RentalWithCar>> getRentalsWithCars() {
    return firestore.collection('rentals').where('user_id', isEqualTo: userId).snapshots().asyncMap((snapshot) async {
      List<RentalWithCar> rentalsWithCars = [];
      for (var rentalSnapshot in snapshot.docs) {
        var rentalData = Rental.fromFirestore(rentalSnapshot.data() as Map<String, dynamic>);
        DocumentSnapshot carSnapshot = await firestore.collection('cars').doc(rentalData.carId).get();
        var carData = carSnapshot.data() as Map<String, dynamic>;
        rentalsWithCars.add(RentalWithCar(
          rental: rentalData,
          carBrand: carData['brand'],
          carModel: carData['name'],
        ));
      }
      return rentalsWithCars;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aktualne Rezerwacje"),
      ),
      body: StreamBuilder<List<RentalWithCar>>(
        stream: getRentalsWithCars(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Wystąpił błąd');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          var rentalsWithCars = snapshot.data ?? [];
          return ListView.builder(
            itemCount: rentalsWithCars.length,
            itemBuilder: (context, index) {
              var rentalWithCar = rentalsWithCars[index];
              return ListTile(
                title: Text('Samochód: ${rentalWithCar.carBrand} ${rentalWithCar.carModel}'),
                subtitle: Text('Od: ${rentalWithCar.rental.dateStart} Do: ${rentalWithCar.rental.dateEnd}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRentalScreen()));
        },
        tooltip: 'Dodaj rezerwację',
        child: Icon(Icons.add),
      ),
    );
  }
}

class RentalWithCar {
  final Rental rental;
  final String carBrand;
  final String carModel;

  RentalWithCar({required this.rental, required this.carBrand, required this.carModel});
}
