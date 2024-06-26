
import 'package:carrently/pages/cars.dart';
import 'package:carrently/pages/home_page.dart';
import 'package:flutter/material.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentIndex = 0;
  var screens;

  @override
  void initState() {
    screens = [
      CarsListScreen(),
      HomePage(),
      HomePage(),
      
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black45,
        backgroundColor: Colors.white,
        // iconSize: 30,
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.car_rental_outlined), label: 'Samochody'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined), label: 'Moje Wypożyczenia'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Ustawienia')
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}