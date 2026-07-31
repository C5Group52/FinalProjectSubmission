import 'package:equatable/equatable.dart';

enum ApplicationStatus { submitted, underReview, interview, offered, rejected }

class Application extends Equatable {
  const Application({
    required this.applicationId,
    required this.jobId,
    required this.uid,
    required this.status,
    required this.coverLetterText,
    required this.cvFileId,
    required this.portfolioFileIds,
    required this.appliedAt,
    required this.updatedAt,
    this.jobTitle = '',
    this.company = '',
  });

  final String applicationId;
  final String jobId;
  final String uid;
  final ApplicationStatus status;
  final String coverLetterText;
  final String? cvFileId;
  final List<String> portfolioFileIds;
  final DateTime appliedAt;
  final DateTime updatedAt;

  /// Denormalized for list display so the applications screen doesn't have
  /// to join against `jobs` on every render.
  final String jobTitle;
  final String company;

  @override
  List<Object?> get props => [
    applicationId,
    jobId,
    uid,
    status,
    coverLetterText,
    cvFileId,
    portfolioFileIds,
    appliedAt,
    updatedAt,
    jobTitle,
    company,
  ];
}