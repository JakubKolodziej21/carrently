import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Payment extends StatelessWidget {
  // Utworzenie instancji Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<double> getPaymentAmountStream() {
    // Pobieranie aktualnie zalogowanego użytkownika
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Stream.value(0.0); // Zwróć strumień z wartością 0, jeśli użytkownik nie jest zalogowany
    }
    
    // Pobieranie strumienia danych z Firestore dla aktualnie zalogowanego użytkownika
    return _firestore.collection('payments')
      .where('user_id', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return double.parse(snapshot.docs.first['price'].toString());
        }
        return 0.0; // Zwróć 0, jeśli nie znaleziono płatności
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Płatności',
          style: TextStyle(color: Colors.blueAccent), // Kolor tytułu
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Kolor białym
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
            stream: getPaymentAmountStream(), // Wywołanie funkcji pobierającej strumień kwoty
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Pokazuje spinner, gdy trwa ładowanie
              } else if (snapshot.hasError) {
                return Text('Błąd: ${snapshot.error}'); // Obsługuje błąd
              } else {
                // Pokazuje kwotę pobraną z Firestore
                double amount = snapshot.data ?? 0.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Licznik kwoty
                    Text(
                      '\$${amount.toStringAsFixed(2)}', // Wyświetlanie kwoty z dwoma miejscami po przecinku
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Kolor tekstu kwoty
                      ),
                    ),
                    const SizedBox(height: 20), // Odstęp

                    // Przycisk "Opłać online"
                    SizedBox(
                      width: 200, // Ustalona szerokość
                      child: ElevatedButton(
                        onPressed: () {
                          // Logika płatności online
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 174, 255), // Kolor przycisku
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: const Text(
                          'Opłać online',
                          style: TextStyle(color: Colors.white), // Kolor czcionki przycisku
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Odstęp

                    // Przycisk "BLIK"
                    SizedBox(
                      width: 200, // Ustalona szerokość
                      child: ElevatedButton(
                        onPressed: () {
                          // Logika płatności Blik
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 36, 36, 36), // Kolor przycisku
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: const Text(
                          'BLIK',
                          style: TextStyle(color: Colors.white), // Kolor czcionki przycisku
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
