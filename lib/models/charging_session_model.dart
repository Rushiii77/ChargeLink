class ChargingSessionModel {
  final String id;
  final String bookingId;
  final double energyDeliveredKwh;
  final int durationMinutes;
  final String sessionStatus;

  ChargingSessionModel({
    required this.id,
    required this.bookingId,
    required this.energyDeliveredKwh,
    required this.durationMinutes,
    required this.sessionStatus,
  });

  factory ChargingSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return ChargingSessionModel(
      id: id,
      bookingId: map['bookingId'] ?? '',
      energyDeliveredKwh: (map['energyDeliveredKwh'] ?? 0.0).toDouble(),
      durationMinutes: map['durationMinutes'] ?? 0,
      sessionStatus: map['sessionStatus'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'energyDeliveredKwh': energyDeliveredKwh,
      'durationMinutes': durationMinutes,
      'sessionStatus': sessionStatus,
    };
  }
}
