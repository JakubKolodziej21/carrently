import 'package:carrently/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A welcome page that displays a background image, app title, and a login button.
class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color.fromARGB(255, 230, 230, 230),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background image at the top section of the screen
            Align(
              alignment: Alignment.topCenter,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(17),
                  bottomRight: Radius.circular(17),
                ),
                child: Container(
                  height: screenHeight * 0.6, // 60% of the screen height
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background_image.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            // Logo and app title in the center
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo_white.png',
                    height: 300,
                    width: 300,
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: [
                      const Text(
                        'Witaj w aplikacji,',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 30),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Car',
                              style: GoogleFonts.lato(fontSize: 48, color: Colors.black87),
                            ),
                            const TextSpan(
                              text: 'Rently',
                              style: TextStyle(fontSize: 48, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Login button positioned at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFD66853)),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WidgetTree()),
                      );
                    },
                    child: const Text(
                      'Zaloguj się',
                      style: TextStyle(fontSize: 35.0, color: Color.fromARGB(255, 250, 250, 250)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
