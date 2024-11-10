import 'package:firebase_storage/firebase_storage.dart';

/// Represents a car with various attributes, including brand, cost, location, and more.
class Car {
  final String id;
  final String brand;
  final double costPerKm;
  final int delayFine;
  final int doors;
  final String fuelType;
  final double fuelCapacity;
  final String gearbox;
  final int mileage;
  final String name;
  final double latitude;
  final double longitude;
  final double rating;
  final int seats;
  final int startCost;
  final String thumbnailImage;
  final String type;
  final int year;

  Car({
    required this.id,
    required this.brand,
    required this.costPerKm,
    required this.delayFine,
    required this.doors,
    required this.fuelType,
    required this.fuelCapacity,
    required this.gearbox,
    required this.mileage,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.seats,
    required this.startCost,
    required this.thumbnailImage,
    required this.type,
    required this.year,
  });

  /// Creates a Car object from a map of data, handling nulls and parsing values.
  factory Car.fromMap(Map<String, dynamic> data, String id) {
    return Car(
      id: id,
      brand: data['brand'] ?? 'Unknown Brand',
      costPerKm: double.tryParse((data['cost_per_km'] ?? '0').replaceAll(',', '.')) ?? 0.0,
      delayFine: data['delay_fine'] ?? 0,
      doors: data['doors'] ?? 0,
      fuelType: data['fuel_type'] ?? 'Unknown Fuel Type',
      fuelCapacity: double.tryParse((data['fuel_capacity'] ?? '0').replaceAll(',', '.')) ?? 0.0,
      gearbox: data['gearbox'] ?? 'Unknown Gearbox',
      mileage: data['mileage'] ?? 0,
      name: data['name'] ?? 'Unknown Car',
      latitude: data['pickup_map']?.latitude ?? 0.0,
      longitude: data['pickup_map']?.longitude ?? 0.0,
      rating: double.tryParse((data['rating'] ?? '0').replaceAll(',', '.')) ?? 0.0,
      seats: data['seates'] ?? 0,
      startCost: data['start_cost'] ?? 0,
      thumbnailImage: data['thumbnail_image'] ?? 'path/to/default/image.png',
      type: data['type'] ?? 'Unknown Type',
      year: data['year'] ?? 0,
    );
  }

  /// Retrieves the URL of the car's thumbnail image from Firebase Storage.
  Future<String> getThumbnailUrl() async {
    try {
      final ref = FirebaseStorage.instance.ref().child(thumbnailImage);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Failed to load image URL: $e");
      return '';  // Returns an empty string as a fallback
    }
  }
}
