import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/application.dart';

class ApplicationModel extends Application {
  const ApplicationModel({
    required super.applicationId,
    required super.jobId,
    required super.uid,
    required super.status,
    required super.coverLetterText,
    required super.cvFileId,
    required super.portfolioFileIds,
    required super.appliedAt,
    required super.updatedAt,
    super.jobTitle,
    super.company,
  });

  factory ApplicationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ApplicationModel(
      applicationId: id,
      jobId: data['jobId'] as String? ?? '',
      uid: data['uid'] as String? ?? '',
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ApplicationStatus.submitted,
      ),
      coverLetterText: data['coverLetterText'] as String? ?? '',
      cvFileId: data['cvFileId'] as String?,
      portfolioFileIds: List<String>.from(
        data['portfolioFileIds'] as List? ?? const [],
      ),
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      jobTitle: data['jobTitle'] as String? ?? '',
      company: data['company'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'jobId': jobId,
    'uid': uid,
    'status': status.name,
    'coverLetterText': coverLetterText,
    'cvFileId': cvFileId,
    'portfolioFileIds': portfolioFileIds,
    'jobTitle': jobTitle,
    'company': company,
    'appliedAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}