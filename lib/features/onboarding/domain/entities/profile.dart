import 'package:equatable/equatable.dart';

import 'education_entry.dart';

/// Mirrors `docs/ERD.md`'s PROFILE entity, stored at `profiles/{uid}`.
class Profile extends Equatable {
  const Profile({
    required this.uid,
    this.skills = const [],
    this.education = const [],
    this.languages = const [],
    this.qualifications = const [],
    this.cvFileId,
    this.portfolioFileIds = const [],
    this.headline,
    this.updatedAt,
  });

  final String uid;
  final List<String> skills;
  final List<EducationEntry> education;
  final List<String> languages;
  final List<String> qualifications;
  final String? cvFileId;
  final List<String> portfolioFileIds;
  final String? headline;
  final DateTime? updatedAt;

  /// Weighted completeness used on the dashboard's "profile strength" nudge.
  int get completenessPercent {
    var score = 0;
    if (skills.isNotEmpty) score += 20;
    if (education.isNotEmpty) score += 20;
    if (languages.isNotEmpty) score += 20;
    if (qualifications.isNotEmpty) score += 20;
    if (cvFileId != null) score += 20;
    return score;
  }

  Profile copyWith({
    List<String>? skills,
    List<EducationEntry>? education,
    List<String>? languages,
    List<String>? qualifications,
    String? cvFileId,
    List<String>? portfolioFileIds,
    String? headline,
  }) {
    return Profile(
      uid: uid,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      languages: languages ?? this.languages,
      qualifications: qualifications ?? this.qualifications,
      cvFileId: cvFileId ?? this.cvFileId,
      portfolioFileIds: portfolioFileIds ?? this.portfolioFileIds,
      headline: headline ?? this.headline,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    uid,
    skills,
    education,
    languages,
    qualifications,
    cvFileId,
    portfolioFileIds,
    headline,
  ];
}
