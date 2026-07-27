import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Permanently deletes a user's account and all of their data.
///
/// Google Play requires apps that let users create an account to also provide
/// an in-app way to delete it, along with the data it holds. Our privacy
/// policy promises this, so it must actually work.
///
/// Order matters: Firestore and Storage are cleared FIRST, while the user is
/// still authenticated. Deleting the auth user first would revoke access and
/// strand their documents in the database forever.
class AccountDeletionService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  AccountDeletionService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Deletes everything. Returns null on success, or a user-facing error.
  ///
  /// [password] is required because Firebase refuses to delete an account
  /// whose sign-in is not recent ("requires-recent-login"). Re-authenticating
  /// also ensures the person deleting the account is genuinely the owner.
  Future<String?> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null) return 'You are not signed in.';
    final uid = user.uid;
    final email = user.email;

    // 1. Prove identity again before anything destructive happens.
    if (email == null) {
      return 'This account has no email sign-in, so it cannot be verified '
          'this way. Please contact support.';
    }

    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('FinWise: re-auth failed with code "${e.code}"');
      }
      return switch (e.code) {
        // Newer Firebase returns invalid-credential for a wrong password.
        'wrong-password' ||
        'invalid-credential' ||
        'invalid-login-credentials' =>
          'Incorrect password. Use the password you sign in to FinWise with '
              '(not your app-lock PIN).',
        'user-mismatch' =>
          'That password belongs to a different account.',
        'too-many-requests' =>
          'Too many attempts. Please wait a few minutes and try again.',
        'network-request-failed' =>
          'Network error. Check your connection and try again.',
        'requires-recent-login' =>
          'Please sign out, sign in again, then retry deletion.',
        // Surface the code for anything unexpected — a vague message makes
        // this impossible to diagnose.
        _ => 'Verification failed (${e.code}). Please try again.',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('FinWise: re-auth threw: $e');

      // Known firebase_auth bug (present in 4.x): re-authentication SUCCEEDS
      // but the plugin throws a type-cast error while decoding the result
      // ("type 'List<Object?>' is not a subtype of type 'PigeonUserDetails?'").
      // The login screen already works around this. Treat it as success —
      // a genuinely wrong password raises a FirebaseAuthException instead,
      // which is handled above.
      final message = e.toString();
      final isPluginDecodingBug = message.contains('PigeonUserDetails') ||
          message.contains('List<Object?>') ||
          message.contains('is not a subtype of type');

      if (!isPluginDecodingBug) {
        return 'Could not verify your password. Please try again.';
      }
      // Fall through and continue with deletion.
    }

    // 2. Delete cloud data while still authorised to do so.
    try {
      await _deleteCollection(_db.collection('users').doc(uid).collection('transactions'));
      await _deleteCollection(_db.collection('users').doc(uid).collection('goals'));
      await _db.collection('users').doc(uid).delete();
    } catch (e) {
      if (kDebugMode) debugPrint('FinWise: Firestore deletion failed: $e');
      return 'Could not delete your data. Please try again.';
    }

    // (Profile pictures were removed from the app — Firebase Storage requires
    // the paid Blaze plan — so there are no uploaded files to clean up.)

    // 3. Local data — cached transactions, PIN, settings.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}

    // 5. Finally the auth account itself.
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Please sign out, sign in again, then retry deletion.';
      }
      return 'Could not delete your account. Please try again.';
    }

    return null; // success
  }

  /// Firestore has no "delete collection" operation — documents must be
  /// removed in batches. 300 keeps us well inside the 500-write batch limit.
  Future<void> _deleteCollection(CollectionReference<Map<String, dynamic>> ref) async {
    while (true) {
      final snapshot = await ref.limit(300).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snapshot.docs.length < 300) return;
    }
  }
}
