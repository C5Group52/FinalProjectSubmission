import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/firebase_error_mapper.dart';
import '../models/app_user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  bool _googleInitialized = false;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(FirestorePaths.users).doc(uid);

  /// Firebase's own auth stream only knows about credentials, so it can't tell
  /// us whether onboarding is done. Chaining it onto the user document keeps
  /// the router's redirect in step with the profile.
  Stream<AppUserModel?> watchAuthState() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _userDoc(user.uid).snapshots().map((doc) {
        final data = doc.data();
        if (data == null) return null;
        return AppUserModel.fromFirestore(data, user.uid);
      });
    });
  }

  Future<AppUserModel> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(fullName.trim());

      final model = AppUserModel(
        uid: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        onboardingCompleted: false,
        phoneNumber: phoneNumber?.trim(),
      );
      await _userDoc(user.uid).set(model.toFirestore());
      return model;
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.fromAuthException(e);
    }
  }

  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _readOrCreateUserDoc(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.fromAuthException(e);
    }
  }

  Future<AppUserModel> signInWithGoogle() async {
    try {
      final google = GoogleSignIn.instance;
      if (!_googleInitialized) {
        await google.initialize();
        _googleInitialized = true;
      }

      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure('Google sign-in did not return a token.');
      }

      final credential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      return _readOrCreateUserDoc(
        credential.user!,
        fallbackName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.fromAuthException(e);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('Sign-in cancelled.');
      }
      throw const AuthFailure('Could not sign in with Google. Try again.');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.fromAuthException(e);
    }
  }

  Future<void> signOut() async {
    if (_googleInitialized) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  /// A first-time Google user has no `users/{uid}` document yet, and an email
  /// user could in theory lose theirs. Either way the app needs one, so read
  /// it and write a starter document when it's missing.
  Future<AppUserModel> _readOrCreateUserDoc(
    User user, {
    String? fallbackName,
    String? photoUrl,
  }) async {
    final doc = await _userDoc(user.uid).get();
    final data = doc.data();
    if (data != null) {
      return AppUserModel.fromFirestore(data, user.uid);
    }

    final model = AppUserModel(
      uid: user.uid,
      fullName: fallbackName ?? user.displayName ?? '',
      email: user.email ?? '',
      onboardingCompleted: false,
      photoUrl: photoUrl ?? user.photoURL,
    );
    await _userDoc(user.uid).set(model.toFirestore());
    return model;
  }
}
