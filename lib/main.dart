import 'package:carrently/firebase_options.dart';
import 'package:carrently/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz; 

/// Main function to initialize Firebase, time zones, and run the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? firebaseError;
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    firebaseError = 'Error initializing Firebase: $e';
    debugPrint(firebaseError);
  }

  tz.initializeTimeZones();
  runApp(MyApp(firebaseError: firebaseError));
}

/// Root widget for the application.
class MyApp extends StatelessWidget {
  final String? firebaseError;

  const MyApp({super.key, this.firebaseError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: firebaseError != null 
          ? ErrorScreen(error: firebaseError!) 
          : const WidgetTree(),
    );
  }
}

/// Screen displayed when Firebase initialization fails, showing the error message.
class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(error)),
    );
  }
}
