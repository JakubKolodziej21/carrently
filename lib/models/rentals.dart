/// Represents a rental record with details including car ID, rental start and end dates, and user ID.
class Rental {
  final String carId;
  final String dateStart;
  final String dateEnd;
  final String userId;

  Rental({
    required this.carId,
    required this.dateStart,
    required this.dateEnd,
    required this.userId,
  });

  /// Factory method to create an instance of Rental from Firestore document data.
  factory Rental.fromFirestore(Map<String, dynamic> data) {
    return Rental(
      carId: data['car_id'],
      dateStart: data['date_start'],
      dateEnd: data['date_end'],
      userId: data['user_id'],
    );
  }

  /// Converts the Rental instance into a map, useful for saving data to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'car_id': carId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'user_id': userId,
    };
  }
}
