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

  Future<void> endRental(BuildContext context, RentalWithCar rentalWithCar) async {
    // Pytanie użytkownika, czy na pewno chce zakończyć rezerwację
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zakończyć rezerwację?'),
        content: const Text('Czy na pewno chcesz zakończyć tę rezerwację?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Zakończ'),
          ),
        ],
      ),
    );

if (confirmed == true) {
    DateTime start = DateTime.parse(rentalWithCar.rental.dateStart);
    DateTime endDate = DateTime.parse(rentalWithCar.rental.dateEnd);
    DateTime actualReturnDate = DateTime.now();

    // Ustalanie liczby dni wynajmu
    int totalDays = actualReturnDate.isBefore(endDate) ? endDate.difference(start).inDays : actualReturnDate.difference(start).inDays;
    
    // Obliczanie dni opóźnienia
    int delayDays = actualReturnDate.isAfter(endDate) ? actualReturnDate.difference(endDate).inDays : 0;

    // Pobieranie informacji o samochodzie z Firestore
    DocumentSnapshot carSnapshot = await FirebaseFirestore.instance.collection('cars').doc(rentalWithCar.rental.carId).get();
    Map<String, dynamic> carData = carSnapshot.data() as Map<String, dynamic>;

    // Pobranie ceny za dzień i kary za opóźnienie z dokumentu
    int dailyRate = carData['cost_per_day'] is int ? carData['cost_per_day'] : int.parse(carData['cost_per_day'].toString());
    int delayPenalty = carData['delay_fine'] is int ? carData['delay_fine'] : int.parse(carData['delay_fine'].toString());

    // Obliczanie całkowitej ceny
    int totalPrice = (dailyRate * totalDays) + (delayPenalty * delayDays);

    // Tworzenie wpisu w kolekcji "payments"
    await FirebaseFirestore.instance.collection('payments').add({
        'user_id': getUserId(),
        'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(start),
        'price': totalPrice.toString(),
        'type': 'rent',
    });



      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezerwacja została zakończona, wpis o płatności został dodany.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(
          'Aktualne rezerwacje',
          style: TextStyle(color: Colors.blueAccent), // Kolor tytułu
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                        trailing: ElevatedButton(
                          onPressed: () => endRental(context, rentalWithCar),
                          child: const Text('Zakończ'),
                        ),
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

