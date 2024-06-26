import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ImageFromFirebaseStorage extends StatelessWidget {
  final String imagePath;

  ImageFromFirebaseStorage({required this.imagePath});

  Future<String> _getImageUrl(String imagePath) async {
  try {
    final ref = FirebaseStorage.instance.ref().child(imagePath);
    final url = await ref.getDownloadURL();
    print("Successfully loaded image URL: $url");
    return url;
  } catch (e) {
    print("Failed to load image URL: $e");
    return '';  // Można zwrócić pusty string jako fallback
  }
}


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getImageUrl(imagePath),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Image.network(snapshot.data!);
        }
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return CircularProgressIndicator();
        }
        return Icon(Icons.error);  // W przypadku błędu ładowania obrazu
      },
    );
  }
}
