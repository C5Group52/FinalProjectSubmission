import '../entities/career_meeting.dart';
import '../entities/career_resource.dart';

abstract interface class CareerSupportRepository {
  Stream<List<CareerResource>> watchResources();

  Stream<List<CareerMeeting>> watchMeetings(String uid);

  Future<void> bookMeeting({
    required String uid,
    required String mentorName,
    required DateTime scheduledAt,
  });
}
