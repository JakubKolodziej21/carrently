import 'package:carrently/auth.dart';
import 'package:carrently/models/rentals.dart';
import 'package:carrently/pages/create_rental_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import do formatowania dat

class RentalsScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? userId = getUserId();  // Upewnij się, że ta metoda poprawnie zwraca userID

  Stream<List<RentalWithCar>> getRentalsWithCars() {
    return firestore.collection('rentals').where('user_id', isEqualTo: userId).snapshots().asyncMap((snapshot) async {
      List<RentalWithCar> rentalsWithCars = [];
      for (var rentalSnapshot in snapshot.docs) {
        var rentalData = Rental.fromFirestore(rentalSnapshot.data());
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
        title: const Text("Aktualne Rezerwacje"),
        backgroundColor: const Color.fromARGB(255, 127, 214, 255),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            delegate: _CalendarHeaderDelegate(),
            pinned: true,
          ),
          StreamBuilder<List<RentalWithCar>>(
            stream: getRentalsWithCars(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const SliverFillRemaining(child: Text('Wystąpił błąd'));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: CircularProgressIndicator());
              }
              var rentalsWithCars = snapshot.data ?? [];
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var rentalWithCar = rentalsWithCars[index];
                    DateTime startDate = DateTime.parse(rentalWithCar.rental.dateStart);
                    DateTime endDate = DateTime.parse(rentalWithCar.rental.dateEnd);
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: ListTile(
                        title: Text('Samochód: ${rentalWithCar.carBrand} ${rentalWithCar.carModel}'),
                        subtitle: Text('Od: ${DateFormat('yyyy-MM-dd').format(startDate)} Do: ${DateFormat('yyyy-MM-dd').format(endDate)}'),
                      ),
                    );
                  },
                  childCount: rentalsWithCars.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRentalScreen()));
        },
        backgroundColor: const Color.fromARGB(255, 0, 174, 255),
        tooltip: 'Dodaj rezerwację',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 250;  // Minimalna wysokość widżetu kalendarza
  @override
  double get maxExtent => 250;  // Maksymalna wysokość widżetu kalendarza

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,  // Tło kalendarza
      child: CalendarDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        onDateChanged: (DateTime value) {
          // Implementacja reakcji na zmianę daty, jeśli jest potrzebna
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_CalendarHeaderDelegate oldDelegate) => false;
}

class RentalWithCar {
  final Rental rental;
  final String carBrand;
  final String carModel;

  RentalWithCar({required this.rental, required this.carBrand, required this.carModel});
}
