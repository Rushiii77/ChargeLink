import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/charger_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateOtpPin() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  Future<BookingModel> createBooking({
    required String customerId,
    required ChargerModel charger,
    required DateTime startTime,
    required int durationMinutes,
    required double totalAmount,
  }) async {
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    final otpPin = _generateOtpPin();
    final now = DateTime.now();

    final docRef = _firestore.collection('bookings').doc();

    final booking = BookingModel(
      id: docRef.id,
      customerId: customerId,
      chargerId: charger.id,
      chargerName: charger.name,
      chargerAddress: charger.address,
      powerKw: charger.powerKw,
      connectorType: charger.connectorType,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      totalAmount: totalAmount,
      status: 'confirmed',
      otpPin: otpPin,
      createdAt: now,
    );

    await docRef.set(booking.toMap());
    return booking;
  }

  Stream<List<BookingModel>> streamCustomerBookings(String customerId) {
    return _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort in memory by startTime descending
      list.sort((a, b) => b.startTime.compareTo(a.startTime));
      return list;
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
    });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
    });
  }
}

