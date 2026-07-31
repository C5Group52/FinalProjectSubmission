import '../../domain/entities/application.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_data_source.dart';
import '../models/application_model.dart';

class JobRepositoryImpl implements JobRepository {
  JobRepositoryImpl(this._remote);

  final JobRemoteDataSource _remote;

  @override
  Stream<List<Job>> watchJobs({String? category, String? searchQuery}) {
    return _remote.watchJobs(category: category, searchQuery: searchQuery);
  }

  @override
  Future<Job?> getJob(String jobId) => _remote.getJob(jobId);

  @override
  Stream<List<Job>> watchSavedJobs(String uid) {
    return _remote.watchSavedJobIds(uid).asyncMap((ids) async {
      final jobs = await Future.wait(ids.map(_remote.getJob));
      return jobs.whereType<Job>().toList();
    });
  }

  @override
  Future<bool> isJobSaved({required String uid, required String jobId}) {
    return _remote.isJobSaved(uid: uid, jobId: jobId);
  }

  @override
  Future<void> toggleSavedJob({required String uid, required String jobId}) {
    return _remote.toggleSavedJob(uid: uid, jobId: jobId);
  }

  @override
  Stream<List<Application>> watchApplications(String uid) {
    return _remote.watchApplications(uid);
  }

  @override
  Future<bool> hasApplied({required String uid, required String jobId}) {
    return _remote.hasApplied(uid: uid, jobId: jobId);
  }

  @override
  Future<void> submitApplication(Application application) {
    return _remote.submitApplication(
      ApplicationModel(
        applicationId: application.applicationId,
        jobId: application.jobId,
        uid: application.uid,
        status: application.status,
        coverLetterText: application.coverLetterText,
        cvFileId: application.cvFileId,
        portfolioFileIds: application.portfolioFileIds,
        appliedAt: application.appliedAt,
        updatedAt: application.updatedAt,
        jobTitle: application.jobTitle,
        company: application.company,
      ),
    );
  }
}