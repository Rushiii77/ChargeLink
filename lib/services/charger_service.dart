import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/charger_model.dart';

class ChargerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Fetch all chargers (Customer) ──────────────────────────────────────────
  Future<List<ChargerModel>> getAllChargers() async {
    try {
      final snapshot = await _firestore.collection('chargers').get();
      return snapshot.docs
          .map((doc) => ChargerModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Stream all chargers (Customer live map) ────────────────────────────────
  Stream<List<ChargerModel>> chargerStream() {
    return _firestore.collection('chargers').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ChargerModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ── Stream chargers for a specific Host ────────────────────────────────────
  Stream<List<ChargerModel>> streamOwnerChargers(String ownerId) {
    return _firestore
        .collection('chargers')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChargerModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
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

    await docRef.set(charger.toMap());
    return charger;
  }

  // ── Toggle charger availability (Host) ─────────────────────────────────────
  Future<void> updateChargerAvailability(String chargerId, bool isAvailable) async {
    await _firestore.collection('chargers').doc(chargerId).update({
      'isAvailable': isAvailable,
    });
  }

  // ── Delete charger (Host) ──────────────────────────────────────────────────
  Future<void> deleteCharger(String chargerId) async {
    await _firestore.collection('chargers').doc(chargerId).delete();
  }

  // ── Seed test data (run once if empty) ──────────────────────────────────────
  Future<void> seedChargers() async {
    final batch = _firestore.batch();

    final chargers = [
      {
        'ownerId': 'seed',
        'name': 'Nerul EV Hub',
        'address': 'Sector 1, Nerul, Navi Mumbai',
        'pricePerKwh': 18.0,
        'rating': 4.8,
        'chargerType': 'DC',
        'powerKw': 50.0,
        'connectorType': 'CCS2',
        'latitude': 19.0342,
        'longitude': 73.0285,
        'isAvailable': true,
        'totalReviews': 42,
      },
      {
        'ownerId': 'seed',
        'name': 'Bhimanshankar Station',
        'address': 'Sector 6, Nerul, Navi Mumbai',
        'pricePerKwh': 20.0,
        'rating': 4.6,
        'chargerType': 'DC',
        'powerKw': 22.0,
        'connectorType': 'CCS2',
        'latitude': 19.0308,
        'longitude': 73.0260,
        'isAvailable': true,
        'totalReviews': 28,
      },
      {
        'ownerId': 'seed',
        'name': 'Kharghar Green Charger',
        'address': 'Sector 12, Kharghar, Navi Mumbai',
        'pricePerKwh': 15.0,
        'rating': 4.5,
        'chargerType': 'AC',
        'powerKw': 7.4,
        'connectorType': 'Type2',
        'latitude': 19.0370,
        'longitude': 73.0320,
        'isAvailable': false,
        'totalReviews': 19,
      },
      {
        'ownerId': 'seed',
        'name': 'Seawoods EV Point',
        'address': 'Seawoods, Navi Mumbai',
        'pricePerKwh': 17.0,
        'rating': 4.7,
        'chargerType': 'AC',
        'powerKw': 11.0,
        'connectorType': 'Type2',
        'latitude': 19.0290,
        'longitude': 73.0345,
        'isAvailable': true,
        'totalReviews': 35,
      },
      {
        'ownerId': 'seed',
        'name': 'Car Charger Jewels',
        'address': 'Palm Beach Road, Nerul',
        'pricePerKwh': 22.0,
        'rating': 5.0,
        'chargerType': 'DC',
        'powerKw': 120.0,
        'connectorType': 'CCS2',
        'latitude': 19.0355,
        'longitude': 73.0362,
        'isAvailable': true,
        'totalReviews': 67,
      },
    ];

    for (final data in chargers) {
      final ref = _firestore.collection('chargers').doc();
      batch.set(ref, data);
    }

    await batch.commit();
  }

  Future<bool> chargersExist() async {
    try {
      final snapshot = await _firestore.collection('chargers').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
