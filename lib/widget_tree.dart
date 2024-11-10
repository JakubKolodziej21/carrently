import 'package:carrently/auth.dart';
import 'package:carrently/pages/login_register_page.dart';
import 'package:carrently/pages/myhomepage.dart';
import 'package:flutter/material.dart';

/// WidgetTree listens for authentication state changes and displays either
/// the main home page or the login/register page based on the user's login status.
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
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MyHomePage(); // User is logged in, show home page
        } else {
          return const LoginPage(); // User is not logged in, show login/register page
        }
      },
    );
  }
}
