import 'package:cloud_firestore/cloud_firestore.dart';
//
import '../../domain/entities/education_entry.dart';
import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.uid,
    super.skills,
    super.education,
    super.languages,
    super.qualifications,
    super.cvFileId,
    super.portfolioFileIds,
    super.headline,
    super.updatedAt,
  });

  factory ProfileModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return ProfileModel(
      uid: uid,
      skills: List<String>.from(data['skills'] as List? ?? const []),
      education: (data['education'] as List? ?? const [])
          .map(
            (e) => EducationEntry.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      languages: List<String>.from(data['languages'] as List? ?? const []),
      qualifications: List<String>.from(
        data['qualifications'] as List? ?? const [],
      ),
      cvFileId: data['cvFileId'] as String?,
      portfolioFileIds: List<String>.from(
        data['portfolioFileIds'] as List? ?? const [],
      ),
      headline: data['headline'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'skills': skills,
      'education': education.map((e) => e.toMap()).toList(),
      'languages': languages,
      'qualifications': qualifications,
      'cvFileId': cvFileId,
      'portfolioFileIds': portfolioFileIds,
      'headline': headline,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ProfileModel.fromEntity(Profile profile) => ProfileModel(
    uid: profile.uid,
    skills: profile.skills,
    education: profile.education,
    languages: profile.languages,
    qualifications: profile.qualifications,
    cvFileId: profile.cvFileId,
    portfolioFileIds: profile.portfolioFileIds,
    headline: profile.headline,
    updatedAt: profile.updatedAt,
  );
}
