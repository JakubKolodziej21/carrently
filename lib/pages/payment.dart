import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Payment screen widget that displays the user's payment amount and provides options for online payment.
class Payment extends StatelessWidget {
  // Creates an instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retrieves a stream of payment amount data for the currently logged-in user.
  Stream<double> getPaymentAmountStream() {
    // Gets the currently logged-in user
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Stream.value(0.0); // Returns a stream with 0 if the user is not logged in
    }
    
    // Retrieves a data stream from Firestore for the currently logged-in user
    return _firestore.collection('payments')
      .where('user_id', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return double.parse(snapshot.docs.first['price'].toString());
        }
        return 0.0; // Returns 0 if no payment data is found
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Płatności',
          style: TextStyle(color: Colors.blueAccent), // Title color
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // White background color
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: StreamBuilder<double>(
            stream: getPaymentAmountStream(), // Calls the function to get the payment amount stream
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Shows a spinner while loading
              } else if (snapshot.hasError) {
                return Text('Błąd: ${snapshot.error}'); // Handles any errors
              } else {
                // Displays the amount retrieved from Firestore
                double amount = snapshot.data ?? 0.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Amount display
                    Text(
                      '\$${amount.toStringAsFixed(2)}', // Displays the amount with two decimal places
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Amount text color
                      ),
                    ),
                    const SizedBox(height: 20), // Spacer

                    // "Pay Online" button
                    SizedBox(
                      width: 200, // Fixed width
                      child: ElevatedButton(
                        onPressed: () {
                          // Logic for online payment
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 174, 255), // Button color
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: const Text(
                          'Opłać online',
                          style: TextStyle(color: Colors.white), // Button text color
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Spacer

                    // "BLIK" button
                    SizedBox(
                      width: 200, // Fixed width
                      child: ElevatedButton(
                        onPressed: () {
                          // Logic for BLIK payment
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 36, 36, 36), // Button color
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: const Text(
                          'BLIK',
                          style: TextStyle(color: Colors.white), // Button text color
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Payment(),
  ));
}
