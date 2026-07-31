import 'package:equatable/equatable.dart';

class Job extends Equatable {
  const Job({
    required this.jobId,
    required this.title,
    required this.company,
    required this.description,
    required this.remote,
    required this.payRateMin,
    required this.payRateMax,
    required this.payRateUnit,
    required this.skillsRequired,
    required this.category,
    required this.status,
    required this.postedAt,
  });

  final String jobId;
  final String title;
  final String company;
  final String description;
  final bool remote;
  final double payRateMin;
  final double payRateMax;
  final String payRateUnit;
  final List<String> skillsRequired;
  final String category;
  final String status;
  final DateTime postedAt;

  String get payRangeLabel =>
      '\$${payRateMin.toStringAsFixed(0)}-${payRateMax.toStringAsFixed(0)}/$payRateUnit';

  @override
  List<Object?> get props => [
    jobId,
    title,
    company,
    description,
    remote,
    payRateMin,
    payRateMax,
    payRateUnit,
    skillsRequired,
    category,
    status,
    postedAt,
  ];
}