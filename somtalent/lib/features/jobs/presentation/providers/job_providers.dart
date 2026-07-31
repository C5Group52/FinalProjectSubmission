import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../onboarding/presentation/providers/profile_providers.dart';
import '../../data/datasources/job_remote_data_source.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/job_repository.dart';

final jobRemoteDataSourceProvider = Provider<JobRemoteDataSource>((ref) {
  return JobRemoteDataSource();
});

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepositoryImpl(ref.watch(jobRemoteDataSourceProvider));
});

final jobSearchQueryProvider =
    NotifierProvider<JobSearchQueryController, String>(
      JobSearchQueryController.new,
    );

class JobSearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final jobsStreamProvider = StreamProvider.autoDispose<List<Job>>((ref) {
  final query = ref.watch(jobSearchQueryProvider);
  return ref.watch(jobRepositoryProvider).watchJobs(searchQuery: query);
});

final jobByIdProvider = FutureProvider.autoDispose.family<Job?, String>((
  ref,
  jobId,
) {
  return ref.watch(jobRepositoryProvider).getJob(jobId);
});

final currentUidProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.value?.uid;
});

final savedJobsStreamProvider = StreamProvider.autoDispose<List<Job>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(jobRepositoryProvider).watchSavedJobs(uid);
});

final isJobSavedProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  jobId,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Future.value(false);
  return ref.watch(jobRepositoryProvider).isJobSaved(uid: uid, jobId: jobId);
});

final applicationsStreamProvider =
    StreamProvider.autoDispose<List<Application>>((ref) {
      final uid = ref.watch(currentUidProvider);
      if (uid == null) return const Stream.empty();
      return ref.watch(jobRepositoryProvider).watchApplications(uid);
    });

final hasAppliedProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  jobId,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Future.value(false);
  return ref.watch(jobRepositoryProvider).hasApplied(uid: uid, jobId: jobId);
});

final saveJobControllerProvider =
    AsyncNotifierProvider<SaveJobController, void>(SaveJobController.new);

class SaveJobController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggle(String jobId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(jobRepositoryProvider)
          .toggleSavedJob(uid: uid, jobId: jobId),
    );
    ref.invalidate(isJobSavedProvider(jobId));
    ref.invalidate(savedJobsStreamProvider);
  }
}

final applyControllerProvider = AsyncNotifierProvider<ApplyController, void>(
  ApplyController.new,
);

class ApplyController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> submit({
    required Job job,
    required String coverLetterText,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return false;

    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final profile = await ref.read(profileRepositoryProvider).getProfile(uid);
      final now = DateTime.now();
      await ref
          .read(jobRepositoryProvider)
          .submitApplication(
            Application(
              applicationId: '',
              jobId: job.jobId,
              uid: uid,
              status: ApplicationStatus.submitted,
              coverLetterText: coverLetterText,
              cvFileId: profile?.cvFileId,
              portfolioFileIds: profile?.portfolioFileIds ?? const [],
              appliedAt: now,
              updatedAt: now,
              jobTitle: job.title,
              company: job.company,
            ),
          );
      await ref
          .read(notificationsRemoteDataSourceProvider)
          .create(
            uid: uid,
            title: 'Application submitted',
            body:
                'Your application for ${job.title} at ${job.company} was sent.',
            type: 'application',
          );
    });
    state = result;
    if (!result.hasError) {
      ref.invalidate(hasAppliedProvider(job.jobId));
      ref.invalidate(applicationsStreamProvider);
    }
    return !result.hasError;
  }
}