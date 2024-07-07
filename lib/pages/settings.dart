

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ustawienia'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Język'),
              onTap: () {
                // Dodaj logikę zmiany języka
              },
            ),
            ListTile(
              leading: Icon(Icons.volume_up),
              title: Text('Dźwięk'),
              onTap: () {
                // Dodaj logikę zmiany głośności
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Powiadomienia'),
              onTap: () {
                // Dodaj logikę konfiguracji powiadomień
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Prywatność'),
              onTap: () {
                // Dodaj logikę ochrony prywatności
              },
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Bezpieczeństwo'),
              onTap: () {
                // Dodaj logikę zmiany hasła i opcji bezpieczeństwa
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}