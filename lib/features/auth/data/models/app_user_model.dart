import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.onboardingCompleted,
    super.phoneNumber,
    super.photoUrl,
    super.createdAt,
  });

  factory AppUserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUserModel(
      uid: uid,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'fullName': fullName,
    'email': email,
    'onboardingCompleted': onboardingCompleted,
    'phoneNumber': phoneNumber,
    'photoUrl': photoUrl,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
