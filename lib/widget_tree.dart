import 'package:carrently/auth.dart';
import 'package:carrently/pages/rentals_screen_page.dart';
import 'package:carrently/pages/login_register_page.dart';
import 'package:carrently/pages/myhomepage.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot){
        if (snapshot.hasData){
          return MyHomePage();
        } else {
          return const LoginPage();
        }
        },
        );
  }
}