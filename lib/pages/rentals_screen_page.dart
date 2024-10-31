import 'package:carrently/auth.dart';
import 'package:carrently/models/rentals.dart';
import 'package:carrently/pages/create_rental_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RentalsScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? userId = getUserId();

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

  DateTime parseCustomDateTime(String dateString) {
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
    String gmtOffset = parts[5];  // GMT offset

    int monthNumber = DateFormat('MMM').parse(month).month;

    // Zmiana formatu daty na akceptowalny przez DateTime.parse
    String dateTimeString = '$year-${monthNumber.toString().padLeft(2, '0')}-$day $time';

    // Zmiana offsetu GMT
    String adjustedDateTimeString = dateTimeString.replaceFirst("GMT", "").replaceFirst(" ", "T");

    // Zwracamy DateTime
    return DateTime.parse(adjustedDateTimeString);
  }

  Stream<bool> checkPaymentStatus(String dateStart) {
    // Użycie metody parseCustomDateTime do przetwarzania daty
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(parseCustomDateTime(dateStart));

    // Sprawdzanie na bieżąco, czy istnieje wpis w tabeli payments dla danego `user_id` i `date`
    return firestore
      .collection('payments')
      .where('user_id', isEqualTo: userId)
      .where('date', isEqualTo: formattedDate)
      .where('type', isEqualTo: 'rent')
      .snapshots()
      .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<void> endRental(BuildContext context, RentalWithCar rentalWithCar) async {
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
      DateTime start = parseCustomDateTime(rentalWithCar.rental.dateStart); // Użycie funkcji parsującej
      DateTime endDate = parseCustomDateTime(rentalWithCar.rental.dateEnd); // Użycie funkcji parsującej
      DateTime actualReturnDate = DateTime.now();

      int totalDays = actualReturnDate.isBefore(endDate) ? endDate.difference(start).inDays : actualReturnDate.difference(start).inDays;
      int delayDays = actualReturnDate.isAfter(endDate) ? actualReturnDate.difference(endDate).inDays : 0;

      DocumentSnapshot carSnapshot = await firestore.collection('cars').doc(rentalWithCar.rental.carId).get();
      Map<String, dynamic> carData = carSnapshot.data() as Map<String, dynamic>;

      int dailyRate = carData['cost_per_day'] is int ? carData['cost_per_day'] : int.parse(carData['cost_per_day'].toString());
      int delayPenalty = carData['delay_fine'] is int ? carData['delay_fine'] : int.parse(carData['delay_fine'].toString());

      int totalPrice = (dailyRate * totalDays) + (delayPenalty * delayDays);

      // Dodanie wpisu płatności
      await firestore.collection('payments').add({
        'user_id': userId,
        'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(start), // Użycie formatu daty
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
      appBar: AppBar(
        title: const Text(
          'Aktualne rezerwacje',
          style: TextStyle(color: Colors.blueAccent),
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
                    DateTime startDate = parseCustomDateTime(rentalWithCar.rental.dateStart); // Użycie funkcji parsującej
                    DateTime endDate = parseCustomDateTime(rentalWithCar.rental.dateEnd); // Użycie funkcji parsującej

                    return StreamBuilder<bool>(
                      stream: checkPaymentStatus(rentalWithCar.rental.dateStart),
                      builder: (context, paymentSnapshot) {
                        if (paymentSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        bool paymentExists = paymentSnapshot.data ?? false;
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
                            trailing: paymentExists
                                ? const Text('Oczekiwanie na płatność', style: TextStyle(color: Colors.red))
                                : ElevatedButton(
                                    onPressed: () => endRental(context, rentalWithCar),
                                    child: const Text('Zakończ'),
                                  ),
                          ),
                        );
                      },
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
  double get minExtent => 250;
  @override
  double get maxExtent => 250;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: CalendarDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        onDateChanged: (DateTime value) {},
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
