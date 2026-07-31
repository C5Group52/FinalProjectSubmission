import '../../domain/entities/career_meeting.dart';
import '../../domain/entities/career_resource.dart';
import '../../domain/repositories/career_support_repository.dart';
import '../datasources/career_support_remote_data_source.dart';

class CareerSupportRepositoryImpl implements CareerSupportRepository {
  CareerSupportRepositoryImpl(this._remote);

  final CareerSupportRemoteDataSource _remote;

  @override
  Stream<List<CareerResource>> watchResources() => _remote.watchResources();

  @override
  Stream<List<CareerMeeting>> watchMeetings(String uid) =>
      _remote.watchMeetings(uid);

  @override
  Future<void> bookMeeting({
    required String uid,
    required String mentorName,
    required DateTime scheduledAt,
  }) {
    return _remote.bookMeeting(
      uid: uid,
      mentorName: mentorName,
      scheduledAt: scheduledAt,
    );
  }
}
