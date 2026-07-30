import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../jobs/presentation/providers/job_providers.dart';
import '../../data/datasources/career_support_remote_data_source.dart';
import '../../data/repositories/career_support_repository_impl.dart';
import '../../domain/entities/career_meeting.dart';
import '../../domain/entities/career_resource.dart';
import '../../domain/repositories/career_support_repository.dart';

final careerSupportRemoteDataSourceProvider =
    Provider<CareerSupportRemoteDataSource>((ref) {
      return CareerSupportRemoteDataSource();
    });

final careerSupportRepositoryProvider = Provider<CareerSupportRepository>((
  ref,
) {
  return CareerSupportRepositoryImpl(
    ref.watch(careerSupportRemoteDataSourceProvider),
  );
});

final careerResourcesStreamProvider =
    StreamProvider.autoDispose<List<CareerResource>>((ref) {
      return ref.watch(careerSupportRepositoryProvider).watchResources();
    });

final careerMeetingsStreamProvider =
    StreamProvider.autoDispose<List<CareerMeeting>>((ref) {
      final uid = ref.watch(currentUidProvider);
      if (uid == null) return const Stream.empty();
      return ref.watch(careerSupportRepositoryProvider).watchMeetings(uid);
    });

final bookMeetingControllerProvider =
    AsyncNotifierProvider<BookMeetingController, void>(
      BookMeetingController.new,
    );

class BookMeetingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> book({
    required String mentorName,
    required DateTime scheduledAt,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(careerSupportRepositoryProvider)
          .bookMeeting(
            uid: uid,
            mentorName: mentorName,
            scheduledAt: scheduledAt,
          ),
    );
    return !state.hasError;
  }
}
