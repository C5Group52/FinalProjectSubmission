import 'package:equatable/equatable.dart';

enum CareerResourceType { cvTip, proposalGuide, interviewPrep, mentorship }

class CareerResource extends Equatable {
  const CareerResource({
    required this.resourceId,
    required this.type,
    required this.title,
    required this.content,
    required this.order,
  });

  final String resourceId;
  final CareerResourceType type;
  final String title;
  final String content;
  final int order;

  @override
  List<Object?> get props => [resourceId, type, title, content, order];
}
