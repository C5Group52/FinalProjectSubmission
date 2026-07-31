import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/job.dart';

class JobModel extends Job {
  const JobModel({
    required super.jobId,
    required super.title,
    required super.company,
    required super.description,
    required super.remote,
    required super.payRateMin,
    required super.payRateMax,
    required super.payRateUnit,
    required super.skillsRequired,
    required super.category,
    required super.status,
    required super.postedAt,
  });

  factory JobModel.fromFirestore(Map<String, dynamic> data, String jobId) {
    return JobModel(
      jobId: jobId,
      title: data['title'] as String? ?? '',
      company: data['company'] as String? ?? '',
      description: data['description'] as String? ?? '',
      remote: data['remote'] as bool? ?? true,
      payRateMin: (data['payRateMin'] as num?)?.toDouble() ?? 0,
      payRateMax: (data['payRateMax'] as num?)?.toDouble() ?? 0,
      payRateUnit: data['payRateUnit'] as String? ?? 'hr',
      skillsRequired: List<String>.from(
        data['skillsRequired'] as List? ?? const [],
      ),
      category: data['category'] as String? ?? '',
      status: data['status'] as String? ?? 'open',
      postedAt: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'company': company,
    'description': description,
    'remote': remote,
    'payRateMin': payRateMin,
    'payRateMax': payRateMax,
    'payRateUnit': payRateUnit,
    'skillsRequired': skillsRequired,
    'category': category,
    'status': status,
    'postedAt': Timestamp.fromDate(postedAt),
  };
}