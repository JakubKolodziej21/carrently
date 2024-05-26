import 'package:carrently/widget_tree.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.title});

  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo - Możesz zastąpić tym rzeczywistym logo
            
            Image.asset('assets/images/logo.png', height: 300, width: 300), // Adjust height and width as needed
            SizedBox(height: 20),
            // Napis powitalny
            Text(
              'Witaj w aplikacji, CarRenly',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Przycisk Zaloguj się
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WidgetTree()),
                );
              },
              child: Text('Zaloguj się'),
            ),
            
          ],
        ),
      ),
    );
  }
}