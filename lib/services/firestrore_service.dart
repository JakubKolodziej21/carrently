import 'package:carrently/models/car.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Car>> streamCars() {
    return _db.collection('cars')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }
}