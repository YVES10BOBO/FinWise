import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/goal.dart';

class FirestoreGoalService {
  final FirebaseFirestore _db;

  FirestoreGoalService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _db.collection('users').doc(uid).collection('goals');
  }

  Stream<List<Goal>> watchGoals(String uid) {
    // Avoid strict ordering requirements in case older docs are missing fields.
    // We sort client-side in the provider.
    return _collection(uid).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Goal.fromJson(doc.data())).toList();
    });
  }

  Future<void> upsertGoal(String uid, Goal goal) async {
    await _collection(uid).doc(goal.id).set(goal.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    await _collection(uid).doc(goalId).delete();
  }
}

