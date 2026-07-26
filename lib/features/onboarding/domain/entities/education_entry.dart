import 'package:equatable/equatable.dart';

class EducationEntry extends Equatable {
  const EducationEntry({
    required this.institutionName,
    required this.degree,
    required this.graduationYear,
  });

  final String institutionName;
  final String degree;
  final String graduationYear;

  Map<String, dynamic> toMap() => {
    'institutionName': institutionName,
    'degree': degree,
    'graduationYear': graduationYear,
  };

  factory EducationEntry.fromMap(Map<String, dynamic> map) => EducationEntry(
    institutionName: map['institutionName'] as String? ?? '',
    degree: map['degree'] as String? ?? '',
    graduationYear: map['graduationYear'] as String? ?? '',
  );

  @override
  List<Object?> get props => [institutionName, degree, graduationYear];
}
