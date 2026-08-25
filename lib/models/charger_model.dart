class ChargerModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final double pricePerKwh;
  final double rating;
  final String chargerType;  // "AC" or "DC"
  final double powerKw;      // e.g. 7.0, 22.0, 50.0, 120.0
  final String connectorType; // "CCS2", "Type2", "CHAdeMO"
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final int totalReviews;

  ChargerModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.pricePerKwh,
    required this.rating,
    required this.chargerType,
    required this.powerKw,
    required this.connectorType,
    required this.latitude,
    required this.longitude,
    this.isAvailable = true,
    this.totalReviews = 0,
  });

  factory ChargerModel.fromMap(Map<String, dynamic> map, String id) {
    return ChargerModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      pricePerKwh: (map['pricePerKwh'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      chargerType: map['chargerType'] ?? 'AC',
      powerKw: (map['powerKw'] ?? 7.0).toDouble(),
      connectorType: map['connectorType'] ?? 'Type2',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      isAvailable: map['isAvailable'] ?? true,
      totalReviews: map['totalReviews'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'pricePerKwh': pricePerKwh,
      'rating': rating,
      'chargerType': chargerType,
      'powerKw': powerKw,
      'connectorType': connectorType,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
      'totalReviews': totalReviews,
    };
  }

  /// Display helper: "22 kW AC"
  String get powerLabel =>
      '${powerKw % 1 == 0 ? powerKw.toInt() : powerKw} kW $chargerType';

  /// Display helper: "★ 4.8 (23)"
  String get ratingLabel =>
      '★ ${rating.toStringAsFixed(1)} ($totalReviews)';
}
