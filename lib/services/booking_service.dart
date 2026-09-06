import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/charger_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final List<BookingModel> _localBookings = [];

  String _generateOtpPin() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  String _generateTransactionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randSuffix = 1000 + random.nextInt(9000);
    return 'TXN_${timestamp}_$randSuffix';
  }

  Future<BookingModel> createBooking({
    required String customerId,
    required ChargerModel charger,
    required DateTime startTime,
    required int durationMinutes,
    required double totalAmount,
    double bookingFee = 100.0,
    String paymentMethod = 'UPI - Instant Pay',
  }) async {
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    final otpPin = _generateOtpPin();
    final transactionId = _generateTransactionId();
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
      bookingFee: bookingFee,
      paymentStatus: 'paid',
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      status: 'confirmed',
      otpPin: otpPin,
      createdAt: now,
    );

    // Save in local list
    _localBookings.add(booking);

    // Sync to Firestore
    try {
      await docRef.set(booking.toMap(), SetOptions(merge: true)).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Firestore createBooking write warning (saved locally): $e');
    }

    return booking;
  }

  Stream<List<BookingModel>> streamCustomerBookings(String customerId) {
    return _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      final firestoreList = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
      final localList = _localBookings.where((b) => b.customerId == customerId).toList();

      final combined = <String, BookingModel>{};
      for (final b in firestoreList) {
        combined[b.id] = b;
      }
      for (final b in localList) {
        combined[b.id] = b;
      }

      final list = combined.values.toList();
      list.sort((a, b) => b.startTime.compareTo(a.startTime));
      return list;
    }).handleError((error) {
      debugPrint('Firestore streamCustomerBookings fallback: $error');
      final localList = _localBookings.where((b) => b.customerId == customerId).toList();
      localList.sort((a, b) => b.startTime.compareTo(a.startTime));
      return localList;
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    final index = _localBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final old = _localBookings[index];
      _localBookings[index] = BookingModel(
        id: old.id,
        customerId: old.customerId,
        chargerId: old.chargerId,
        chargerName: old.chargerName,
        chargerAddress: old.chargerAddress,
        powerKw: old.powerKw,
        connectorType: old.connectorType,
        startTime: old.startTime,
        endTime: old.endTime,
        durationMinutes: old.durationMinutes,
        totalAmount: old.totalAmount,
        bookingFee: old.bookingFee,
        paymentStatus: 'refunded',
        paymentMethod: old.paymentMethod,
        transactionId: old.transactionId,
        status: 'cancelled',
        otpPin: old.otpPin,
        createdAt: old.createdAt,
      );
    }

    try {
      await _firestore.collection('bookings').doc(bookingId).set({
        'status': 'cancelled',
        'paymentStatus': 'refunded',
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Firestore cancelBooking warning: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final index = _localBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final old = _localBookings[index];
      _localBookings[index] = BookingModel(
        id: old.id,
        customerId: old.customerId,
        chargerId: old.chargerId,
        chargerName: old.chargerName,
        chargerAddress: old.chargerAddress,
        powerKw: old.powerKw,
        connectorType: old.connectorType,
        startTime: old.startTime,
        endTime: old.endTime,
        durationMinutes: old.durationMinutes,
        totalAmount: old.totalAmount,
        bookingFee: old.bookingFee,
        paymentStatus: old.paymentStatus,
        paymentMethod: old.paymentMethod,
        transactionId: old.transactionId,
        status: status,
        otpPin: old.otpPin,
        createdAt: old.createdAt,
      );
    }

    try {
      await _firestore.collection('bookings').doc(bookingId).set({
        'status': status,
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Firestore updateBookingStatus warning: $e');
    }
  }
}
