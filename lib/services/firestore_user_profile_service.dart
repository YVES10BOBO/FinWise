import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserProfileService {
  final FirebaseFirestore _db;

  FirestoreUserProfileService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _db.collection('users').doc(uid);
  }

  Future<void> createProfileIfNeeded({
    required String uid,
    String? email,
    String? name,
  }) async {
    // Create a minimal profile doc. If it already exists, merge safely.
    await _doc(uid).set(
      {
        'uid': uid,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateProfile({
    required String uid,
    String? email,
    String? name,
    double? income,
    String? incomeFrequency,
    String? spendingStyle,
    List<String>? categories,
    bool? onboardingComplete,
    String? profileImageUrl,
  }) async {
    await _doc(uid).set(
      {
        'uid': uid,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        if (income != null) 'income': income,
        if (incomeFrequency != null) 'incomeFrequency': incomeFrequency,
        if (spendingStyle != null) 'spendingStyle': spendingStyle,
        if (categories != null) 'categories': categories,
        if (onboardingComplete != null)
          'onboardingComplete': onboardingComplete,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final snapshot = await _doc(uid).get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }
}

