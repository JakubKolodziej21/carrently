import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// A widget to display an image from Firebase Storage based on the provided image path.
class ImageFromFirebaseStorage extends StatelessWidget {
  final String imagePath;

  const ImageFromFirebaseStorage({super.key, required this.imagePath});

  /// Fetches the image URL from Firebase Storage using the specified [imagePath].
  Future<String> _getImageUrl(String imagePath) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      final url = await ref.getDownloadURL();
      print("Successfully loaded image URL: $url");
      return url;
    } catch (e) {
      print("Failed to load image URL: $e");
      return '';  // Returns an empty string as a fallback if loading fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getImageUrl(imagePath),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Image.network(snapshot.data!); // Display the image if loaded successfully
        }
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return const CircularProgressIndicator(); // Shows loading indicator while waiting
        }
        return const Icon(Icons.error);  // Displays error icon if image loading fails
      },
    );
  }
}
