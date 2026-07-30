import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/career_meeting.dart';

class CareerMeetingModel extends CareerMeeting {
  const CareerMeetingModel({
    required super.meetingId,
    required super.uid,
    required super.mentorName,
    required super.scheduledAt,
    required super.status,
    super.notes,
  });

  factory CareerMeetingModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
    String uid,
  ) {
    return CareerMeetingModel(
      meetingId: id,
      uid: uid,
      mentorName: data['mentorName'] as String? ?? '',
      scheduledAt:
          (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: MeetingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MeetingStatus.scheduled,
      ),
      notes: data['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'mentorName': mentorName,
    'scheduledAt': Timestamp.fromDate(scheduledAt),
    'status': status.name,
    'notes': notes,
  };
}
