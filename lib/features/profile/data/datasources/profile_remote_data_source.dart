import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/firebase_error_mapper.dart';
import '../../../onboarding/data/models/profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore.collection(FirestorePaths.profiles);

  CollectionReference<Map<String, dynamic>> _files(String uid) =>
      _profiles.doc(uid).collection(FirestorePaths.filesSubcollection);

  Future<ProfileModel?> getProfile(String uid) async {
    try {
      final doc = await _profiles.doc(uid).get();
      if (!doc.exists) return null;
      return ProfileModel.fromFirestore(doc.data()!, uid);
    } catch (e) {
      throw FirebaseErrorMapper.fromUnknown(e);
    }
  }

  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _profiles
          .doc(profile.uid)
          .set(profile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw FirebaseErrorMapper.fromUnknown(e);
    }
  }

  /// Stores [bytes] base64-encoded as its own document under
  /// `profiles/{uid}/files/{fileId}` and returns the generated `fileId`.
  Future<String> uploadDocument({
    required String uid,
    required String fileName,
    required List<int> bytes,
  }) async {
    if (bytes.length > AppConstants.maxUploadFileSizeBytes) {
      final maxKb = AppConstants.maxUploadFileSizeBytes ~/ 1024;
      throw ValidationFailure(
        '"$fileName" is too large (max ${maxKb}KB). Try a smaller file.',
      );
    }
    try {
      final doc = _files(uid).doc();
      await doc.set({
        'fileName': fileName,
        'base64Data': base64Encode(bytes),
        'sizeBytes': bytes.length,
        'uploadedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw FirebaseErrorMapper.fromUnknown(e);
    }
  }
}
