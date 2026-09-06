import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/charger_model.dart';

class ChargerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<ChargerModel> _defaultSeedChargers = [
    ChargerModel(
      id: 'seed_1',
      ownerId: 'seed',
      name: 'Nerul EV Fast Hub',
      address: 'Sector 1, Nerul, Navi Mumbai',
      pricePerKwh: 18.0,
      rating: 4.8,
      chargerType: 'DC',
      powerKw: 50.0,
      connectorType: 'CCS2',
      latitude: 19.0342,
      longitude: 73.0285,
      isAvailable: true,
      totalReviews: 42,
    ),
    ChargerModel(
      id: 'seed_2',
      ownerId: 'seed',
      name: 'Bhimashankar Station',
      address: 'Sector 6, Nerul, Navi Mumbai',
      pricePerKwh: 20.0,
      rating: 4.6,
      chargerType: 'DC',
      powerKw: 22.0,
      connectorType: 'CCS2',
      latitude: 19.0308,
      longitude: 73.0260,
      isAvailable: true,
      totalReviews: 28,
    ),
    ChargerModel(
      id: 'seed_3',
      ownerId: 'seed',
      name: 'Kharghar Green Charger',
      address: 'Sector 12, Kharghar, Navi Mumbai',
      pricePerKwh: 15.0,
      rating: 4.5,
      chargerType: 'AC',
      powerKw: 7.4,
      connectorType: 'Type2',
      latitude: 19.0370,
      longitude: 73.0320,
      isAvailable: false,
      totalReviews: 19,
    ),
    ChargerModel(
      id: 'seed_4',
      ownerId: 'seed',
      name: 'Seawoods EV Superpoint',
      address: 'Seawoods Grand Central, Navi Mumbai',
      pricePerKwh: 17.0,
      rating: 4.7,
      chargerType: 'AC',
      powerKw: 11.0,
      connectorType: 'Type2',
      latitude: 19.0290,
      longitude: 73.0345,
      isAvailable: true,
      totalReviews: 35,
    ),
    ChargerModel(
      id: 'seed_5',
      ownerId: 'seed',
      name: 'Palm Beach Hypercharger',
      address: 'Palm Beach Road, Nerul',
      pricePerKwh: 22.0,
      rating: 5.0,
      chargerType: 'DC',
      powerKw: 120.0,
      connectorType: 'CCS2',
      latitude: 19.0355,
      longitude: 73.0362,
      isAvailable: true,
      totalReviews: 67,
    ),
  ];

  static final List<ChargerModel> _localAddedChargers = [];

  // ── Fetch all chargers (Customer) ──────────────────────────────────────────
  Future<List<ChargerModel>> getAllChargers() async {
    try {
      final snapshot = await _firestore
          .collection('chargers')
          .get()
          .timeout(const Duration(seconds: 4));

      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => ChargerModel.fromMap(doc.data(), doc.id))
            .toList();
        return [...list, ..._localAddedChargers];
      }
    } catch (e) {
      debugPrint('Firestore getAllChargers warning (using fallback seed): $e');
    }
    return [..._defaultSeedChargers, ..._localAddedChargers];
  }

  // ── Stream all chargers (Customer live map) ────────────────────────────────
  Stream<List<ChargerModel>> chargerStream() {
    return _firestore.collection('chargers').snapshots().map(
      (snapshot) {
        if (snapshot.docs.isEmpty) {
          return [..._defaultSeedChargers, ..._localAddedChargers];
        }
        final list = snapshot.docs
            .map((doc) => ChargerModel.fromMap(doc.data(), doc.id))
            .toList();
        return [...list, ..._localAddedChargers];
      },
    ).handleError((error) {
      debugPrint('Firestore chargerStream error fallback: $error');
      return [..._defaultSeedChargers, ..._localAddedChargers];
    });
  }

  // ── Stream chargers for a specific Host ────────────────────────────────────
  Stream<List<ChargerModel>> streamOwnerChargers(String ownerId) {
    return _firestore
        .collection('chargers')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snapshot) {
            final firestoreList = snapshot.docs
                .map((doc) => ChargerModel.fromMap(doc.data(), doc.id))
                .toList();
            final localOwner = _localAddedChargers.where((c) => c.ownerId == ownerId).toList();
            return [...firestoreList, ...localOwner];
          },
        )
        .handleError((error) {
          debugPrint('Firestore streamOwnerChargers fallback: $error');
          final localOwner = _localAddedChargers.where((c) => c.ownerId == ownerId).toList();
          return localOwner;
        });
  }

  // ── Add new charger (Host) ────────────────────────────────────────────────
  Future<ChargerModel> addCharger({
    required String ownerId,
    required String name,
    required String address,
    required double pricePerKwh,
    required String chargerType,
    required double powerKw,
    required String connectorType,
    required double latitude,
    required double longitude,
  }) async {
    final docRef = _firestore.collection('chargers').doc();

    final charger = ChargerModel(
      id: docRef.id,
      ownerId: ownerId,
      name: name,
      address: address,
      pricePerKwh: pricePerKwh,
      rating: 5.0,
      chargerType: chargerType,
      powerKw: powerKw,
      connectorType: connectorType,
      latitude: latitude,
      longitude: longitude,
      isAvailable: true,
      totalReviews: 1,
    );

    // Save locally first
    _localAddedChargers.add(charger);

    // Try Firestore
    try {
      await docRef.set(charger.toMap(), SetOptions(merge: true)).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Firestore addCharger write warning (saved locally): $e');
    }

    return charger;
  }

  // ── Toggle charger availability (Host) ─────────────────────────────────────
  Future<void> updateChargerAvailability(String chargerId, bool isAvailable) async {
    // Update local copy
    final index = _localAddedChargers.indexWhere((c) => c.id == chargerId);
    if (index != -1) {
      final old = _localAddedChargers[index];
      _localAddedChargers[index] = ChargerModel(
        id: old.id,
        ownerId: old.ownerId,
        name: old.name,
        address: old.address,
        pricePerKwh: old.pricePerKwh,
        rating: old.rating,
        chargerType: old.chargerType,
        powerKw: old.powerKw,
        connectorType: old.connectorType,
        latitude: old.latitude,
        longitude: old.longitude,
        isAvailable: isAvailable,
        totalReviews: old.totalReviews,
      );
    }

    try {
      await _firestore.collection('chargers').doc(chargerId).set({
        'isAvailable': isAvailable,
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Firestore updateChargerAvailability warning: $e');
    }
  }

  // ── Delete charger (Host) ──────────────────────────────────────────────────
  Future<void> deleteCharger(String chargerId) async {
    _localAddedChargers.removeWhere((c) => c.id == chargerId);
    try {
      await _firestore.collection('chargers').doc(chargerId).delete().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Firestore deleteCharger warning: $e');
    }
  }

  // ── Seed test data (run once if empty) ──────────────────────────────────────
  Future<void> seedChargers() async {
    try {
      final batch = _firestore.batch();
      for (final charger in _defaultSeedChargers) {
        final ref = _firestore.collection('chargers').doc(charger.id);
        batch.set(ref, charger.toMap(), SetOptions(merge: true));
      }
      await batch.commit().timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Firestore seedChargers warning: $e');
    }
  }

  Future<bool> chargersExist() async {
    try {
      final snapshot = await _firestore.collection('chargers').limit(1).get().timeout(const Duration(seconds: 3));
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return true; // Use seed
    }
  }
}
