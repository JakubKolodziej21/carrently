import 'package:carrently/auth.dart';
import 'package:carrently/models/rentals.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentalsScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? userId = getUserId();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aktualne Rezerwacje"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('rentals').where('user_id', isEqualTo: userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Wystąpił błąd');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          var rentalsList = snapshot.data!.docs.map((doc) => Rental.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
          return ListView.builder(
            itemCount: rentalsList.length,
            itemBuilder: (context, index) {
              Rental rental = rentalsList[index];
              return ListTile(
                title: Text('Samochód: ${rental.carId}'),
                subtitle: Text('Od: ${rental.dateStart} Do: ${rental.dateEnd}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Here, you can navigate to a new page or open a dialog
         // Navigator.push(context, MaterialPageRoute(builder: (context) => NewRentalScreen()));
        },
        tooltip: 'Dodaj rezerwację',
        child: Icon(Icons.add),
      ),
    );
  }
}
