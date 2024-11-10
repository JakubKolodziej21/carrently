import 'package:carrently/pages/cars.dart';
import 'package:carrently/pages/payment.dart';
import 'package:carrently/pages/rentals_screen_page.dart';
import 'package:carrently/pages/settings.dart';
import 'package:flutter/material.dart';

/// MyHomePage is a stateful widget that provides navigation between main screens
/// in the app using a BottomNavigationBar.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentIndex = 0; // Holds the index of the currently selected tab
  late final List<Widget> screens; // List of screens to navigate between

  @override
  void initState() {
    screens = [
      CarsListScreen(),
      RentalsScreen(),
      Payment(),
      SettingsScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black45,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental_outlined), label: 'Samochody'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), label: 'Moje Wypożyczenia'),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_outlined), label: 'Płatności'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), label: 'Ustawienia')
        ],
      ),
    );
  }
}
