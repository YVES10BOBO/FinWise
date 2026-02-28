import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../models/transaction.dart';

class FirestoreTransactionService {
  final FirebaseFirestore _db;

  FirestoreTransactionService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _db.collection('users').doc(uid).collection('transactions');
  }

  Stream<List<Transaction>> watchTransactions(String uid) {
    return _collection(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList();
    });
  }

  Future<Set<String>> getTransactionIds(String uid) async {
    final snapshot = await _collection(uid).get();
    return snapshot.docs.map((d) => d.id).toSet();
  }

  Future<void> upsertTransaction(String uid, Transaction transaction) async {
    await _collection(uid)
        .doc(transaction.id)
        .set(transaction.toJson(), SetOptions(merge: true));
  }

  Future<void> deleteTransaction(String uid, String transactionId) async {
    await _collection(uid).doc(transactionId).delete();
  }
}

