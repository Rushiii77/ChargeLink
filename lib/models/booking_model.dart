import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String customerId;
  final String chargerId;
  final String chargerName;
  final String chargerAddress;
  final double powerKw;
  final String connectorType;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double totalAmount;
  final double bookingFee; // ₹100 fixed slot reservation fee
  final String paymentStatus; // 'paid', 'pending', 'refunded'
  final String paymentMethod; // 'UPI', 'Card', 'Wallet'
  final String transactionId;
  final String status; // 'confirmed', 'active', 'completed', 'cancelled'
  final String otpPin;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.chargerId,
    required this.chargerName,
    required this.chargerAddress,
    required this.powerKw,
    required this.connectorType,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.totalAmount,
    this.bookingFee = 100.0,
    this.paymentStatus = 'paid',
    this.paymentMethod = 'UPI',
    this.transactionId = '',
    required this.status,
    required this.otpPin,
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      customerId: map['customerId'] ?? '',
      chargerId: map['chargerId'] ?? '',
      chargerName: map['chargerName'] ?? 'EV Charging Station',
      chargerAddress: map['chargerAddress'] ?? '',
      powerKw: (map['powerKw'] ?? 22.0).toDouble(),
      connectorType: map['connectorType'] ?? 'CCS2',
      startTime: map['startTime'] is Timestamp
          ? (map['startTime'] as Timestamp).toDate()
          : (map['startTime'] != null
              ? DateTime.tryParse(map['startTime'].toString()) ?? DateTime.now()
              : DateTime.now()),
      endTime: map['endTime'] is Timestamp
          ? (map['endTime'] as Timestamp).toDate()
          : (map['endTime'] != null
              ? DateTime.tryParse(map['endTime'].toString()) ?? DateTime.now()
              : DateTime.now()),
      durationMinutes: map['durationMinutes'] ?? 60,
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      bookingFee: (map['bookingFee'] ?? 100.0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'paid',
      paymentMethod: map['paymentMethod'] ?? 'UPI',
      transactionId: map['transactionId'] ?? '',
      status: map['status'] ?? 'confirmed',
      otpPin: map['otpPin'] ?? '1234',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'chargerId': chargerId,
      'chargerName': chargerName,
      'chargerAddress': chargerAddress,
      'powerKw': powerKw,
      'connectorType': connectorType,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationMinutes': durationMinutes,
      'totalAmount': totalAmount,
      'bookingFee': bookingFee,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status,
      'otpPin': otpPin,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get formattedStatus {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'active':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
