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

  // Metoda factory do tworzenia instancji klasy Rental z danych dokumentu Firestore
  factory Rental.fromFirestore(Map<String, dynamic> data) {
    return Rental(
      carId: data['car_id'],
      dateStart: data['date_start'],
      dateEnd: data['date_end'],
      userId: data['user_id'],
    );
  }

  // Metoda do generowania mapy danych, przydatna przy zapisywaniu danych do Firestore
  Map<String, dynamic> toMap() {
    return {
      'car_id': carId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'user_id': userId,
    };
  }
}
