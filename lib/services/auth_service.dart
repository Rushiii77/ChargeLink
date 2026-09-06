import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Registration ──────────────────────────────────────────────────────────
  Future<UserCredential> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // 1. Create user account in Firebase Auth
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    // 2. Cache user profile locally in SharedPreferences immediately
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name_$uid', name);
      await prefs.setString('user_email_$uid', email);
      await prefs.setString('user_phone_$uid', phone);
      await prefs.setString('user_role_$uid', 'customer');
      await prefs.setString('current_user_role', 'customer');
    } catch (e) {
      debugPrint('SharedPreferences cache error during register: $e');
    }

    // 3. Sync to Cloud Firestore with merge: true and graceful timeout
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set({
            'uid': uid,
            'name': name,
            'email': email,
            'phone': phone,
            'role': 'customer',
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Firestore write warning during register (account created in Auth & local cache): $e');
    }

    return userCredential;
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Warm cache
    if (credential.user != null) {
      unawaited(getUserRole(credential.user!.uid));
    }

    return credential;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_role');
    } catch (_) {}
    await _auth.signOut();
  }

  // ── Reset Password ────────────────────────────────────────────────────────
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Get User Role (Fault-tolerant) ────────────────────────────────────────
  Future<String?> getUserRole(String uid) async {
    // 1. Try reading from local cache first for instant response
    String? cachedRole;
    try {
      final prefs = await SharedPreferences.getInstance();
      cachedRole = prefs.getString('user_role_$uid') ?? prefs.getString('current_user_role');
    } catch (_) {}

    // 2. Try fetching from Cloud Firestore
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 3));

      if (doc.exists && doc.data() != null) {
        final role = doc.data()!['role'] as String?;
        if (role != null && role.isNotEmpty) {
          // Update local cache
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_role_$uid', role);
            await prefs.setString('current_user_role', role);
          } catch (_) {}
          return role;
        }
      }
    } catch (e) {
      debugPrint('Firestore getUserRole warning: $e');
    }

    // Return cached role if available
    return cachedRole;
  }

  // ── Update User Role (Fault-tolerant with fallback) ───────────────────────
  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    // 1. Save to local storage immediately
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role_$uid', role);
      await prefs.setString('current_user_role', role);
    } catch (e) {
      debugPrint('SharedPreferences cache error in updateUserRole: $e');
    }

    // 2. Sync to Cloud Firestore using set with merge: true so non-existent doc is created safely
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set({
            'role': role,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Firestore updateUserRole warning (saved to local device storage): $e');
    }
  }

  // ── Get User Details Map ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    String name = '';
    String email = _auth.currentUser?.email ?? '';
    String phone = '';
    String role = 'customer';

    try {
      final prefs = await SharedPreferences.getInstance();
      name = prefs.getString('user_name_$uid') ?? '';
      email = prefs.getString('user_email_$uid') ?? email;
      phone = prefs.getString('user_phone_$uid') ?? '';
      role = prefs.getString('user_role_$uid') ?? 'customer';
    } catch (_) {}

    try {
      final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        name = data['name'] ?? name;
        email = data['email'] ?? email;
        phone = data['phone'] ?? phone;
        role = data['role'] ?? role;
      }
    } catch (_) {}

    return {
      'name': name.isEmpty ? (email.contains('@') ? email.split('@').first : 'User') : name,
      'email': email,
      'phone': phone.isEmpty ? '+91 98765 43210' : phone,
      'role': role,
    };
  }

  User? get currentUser => _auth.currentUser;
}