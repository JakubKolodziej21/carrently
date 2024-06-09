import 'package:carrently/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color.fromARGB(255, 230, 230, 230),
            ],
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(17),
                  bottomRight: Radius.circular(17),
                ),
                child: Container(
                  height: screenHeight * 0.6, // 60% of the screen height
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background_image.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Image.asset('assets/images/logo_white.png', height: 300, width: 300), // Adjust height and width as needed
                  ),
                  SizedBox(height: 30),
                  Column(
                    children: [
                      Text(
                        'Witaj w aplikacji,',
                        style: TextStyle(fontWeight:FontWeight.w600,fontSize: 30),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Car',
                              style: GoogleFonts.lato(fontSize: 48, color: Colors.black87),
                            ),
                            TextSpan(
                              text: 'Rently',
                              style: TextStyle(fontSize: 48,  color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 40.0, right: 40.0),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFD66853)),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.only(top: 12.0, bottom: 12.0),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // 17% of 50 is approximately 8.5
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
