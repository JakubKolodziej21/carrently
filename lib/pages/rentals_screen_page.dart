import 'package:carrently/auth.dart';
import 'package:carrently/models/rentals.dart';
import 'package:carrently/pages/create_rental_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Screen to display and manage current rentals of the user.
class RentalsScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? userId = getUserId();

  /// Retrieves rentals associated with the current user, along with car details.
  Stream<List<RentalWithCar>> getRentalsWithCars() {
    return firestore
        .collection('rentals')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
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

  /// Parses a custom-formatted date string into a `DateTime` object.
  DateTime parseCustomDateTime(String dateString) {
    List<String> parts = dateString.split(' ');

    if (parts.length < 6) {
      throw FormatException("Invalid date format: $dateString");
    }

    String month = parts[1];
    String day = parts[2];
    String year = parts[3];
    String time = parts[4];

    int monthNumber = DateFormat('MMM').parse(month).month;
    String dateTimeString = '$year-${monthNumber.toString().padLeft(2, '0')}-$day $time';
    String adjustedDateTimeString = dateTimeString.replaceFirst("GMT", "").replaceFirst(" ", "T");

    return DateTime.parse(adjustedDateTimeString);
  }

  /// Checks if there is a payment record for the given rental start date.
  Stream<bool> checkPaymentStatus(String dateStart) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(parseCustomDateTime(dateStart));

    return firestore
        .collection('payments')
        .where('user_id', isEqualTo: userId)
        .where('date', isEqualTo: formattedDate)
        .where('type', isEqualTo: 'rent')
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  /// Ends the rental by calculating the total cost and adding a payment record.
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
      DateTime start = parseCustomDateTime(rentalWithCar.rental.dateStart);
      DateTime endDate = parseCustomDateTime(rentalWithCar.rental.dateEnd);
      DateTime actualReturnDate = DateTime.now();

      int totalDays = actualReturnDate.isBefore(endDate)
          ? endDate.difference(start).inDays
          : actualReturnDate.difference(start).inDays;
      int delayDays = actualReturnDate.isAfter(endDate) ? actualReturnDate.difference(endDate).inDays : 0;

      DocumentSnapshot carSnapshot = await firestore.collection('cars').doc(rentalWithCar.rental.carId).get();
      Map<String, dynamic> carData = carSnapshot.data() as Map<String, dynamic>;

      int dailyRate = carData['cost_per_day'] is int
          ? carData['cost_per_day']
          : int.parse(carData['cost_per_day'].toString());
      int delayPenalty = carData['delay_fine'] is int
          ? carData['delay_fine']
          : int.parse(carData['delay_fine'].toString());

      int totalPrice = (dailyRate * totalDays) + (delayPenalty * delayDays);

      await firestore.collection('payments').add({
        'user_id': userId,
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
                    DateTime startDate = parseCustomDateTime(rentalWithCar.rental.dateStart);
                    DateTime endDate = parseCustomDateTime(rentalWithCar.rental.dateEnd);

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
                            subtitle: Text(
                              'Od: ${DateFormat('yyyy-MM-dd').format(startDate)} Do: ${DateFormat('yyyy-MM-dd').format(endDate)}',
                            ),
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

/// Delegate for the calendar header in the rentals screen.
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

/// Model to hold a rental along with car details.
class RentalWithCar {
  final Rental rental;
  final String carBrand;
  final String carModel;

  RentalWithCar({required this.rental, required this.carBrand, required this.carModel});
}
