import 'package:equatable/equatable.dart';

enum MeetingStatus { scheduled, completed, cancelled }

class CareerMeeting extends Equatable {
  const CareerMeeting({
    required this.meetingId,
    required this.uid,
    required this.mentorName,
    required this.scheduledAt,
    required this.status,
    this.notes = '',
  });

  final String meetingId;
  final String uid;
  final String mentorName;
  final DateTime scheduledAt;
  final MeetingStatus status;
  final String notes;

  @override
  List<Object?> get props => [
    meetingId,
    uid,
    mentorName,
    scheduledAt,
    status,
    notes,
  ];
}
