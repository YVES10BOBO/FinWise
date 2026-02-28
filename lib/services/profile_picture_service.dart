import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firestore_user_profile_service.dart';

/// Service to manage user profile pictures using Firebase Storage + Firestore.
///
/// - Image file is stored in Firebase Storage under `profilePictures/{uid}/profile.jpg`
/// - Public download URL is stored in Firestore user profile (`users/{uid}.profileImageUrl`)
/// - No path is stored in SharedPreferences anymore (backend is the source of truth)
class ProfilePictureService {
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final FirestoreUserProfileService _profileService;

  ProfilePictureService({
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    FirestoreUserProfileService? profileService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _profileService = profileService ?? FirestoreUserProfileService();

  String _storagePath(String uid) => 'profilePictures/$uid/profile.jpg';

  /// Get download URL for current user's profile picture from Firestore profile.
  Future<String?> getProfilePictureUrl() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final profile = await _profileService.getProfile(user.uid);
    final url = profile?['profileImageUrl'];
    if (url is String && url.isNotEmpty) {
      return url;
    }
    return null;
  }

  /// Upload a new profile picture to Firebase Storage and update Firestore profile.
  /// Returns the download URL, or null if user not logged in.
  Future<String?> uploadProfilePicture(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final ref = _storage.ref().child(_storagePath(user.uid));
    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();

    await _profileService.updateProfile(
      uid: user.uid,
      profileImageUrl: url,
    );

    return url;
  }

  /// Delete the profile picture from Storage and clear the URL in Firestore.
  Future<void> deleteProfilePicture() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _storage.ref().child(_storagePath(user.uid));
    try {
      await ref.delete();
    } catch (_) {
      // Ignore if file does not exist
    }

    await _profileService.updateProfile(
      uid: user.uid,
      profileImageUrl: '',
    );
  }
}
