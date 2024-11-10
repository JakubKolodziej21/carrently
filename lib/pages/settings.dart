import 'package:carrently/auth.dart';
import 'package:flutter/material.dart';

/// SettingsScreen displays various user settings options, including language,
/// sound, notifications, privacy, security, and logout.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ustawienia',
          style: TextStyle(color: Colors.blueAccent), // Title color
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            // Language setting option
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Język'),
              onTap: () {
                // Add language change logic
              },
            ),
            // Sound setting option
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Dźwięk'),
              onTap: () {
                // Add volume change logic
              },
            ),
            // Notifications setting option
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Powiadomienia'),
              onTap: () {
                // Add notification configuration logic
              },
            ),
            // Privacy setting option
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Prywatność'),
              onTap: () {
                // Add privacy protection logic
              },
            ),
            // Security setting option
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Bezpieczeństwo'),
              onTap: () {
                // Add password change and security options logic
              },
            ),
            // Logout option
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Wyloguj się'),
              onTap: () async {
                await signOut();
                // Navigate to the login screen or show a confirmation message
                // Navigator.of(context).pushReplacementNamed('/login'); 
                // Uncomment and replace '/login' with your actual login route
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}

/// Signs the user out by calling the Auth service.
Future<void> signOut() async {
  await Auth().signOut();
}
