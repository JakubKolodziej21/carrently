import 'package:carrently/models/car.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for interacting with Firestore database, specifically for retrieving car data.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Streams a list of `Car` objects from the Firestore 'cars' collection.
  Stream<List<Car>> streamCars() {
    return _db.collection('cars')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Car.fromMap(doc.data(), doc.id)).toList());
  }
}
