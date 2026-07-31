import '../entities/application.dart';
import '../entities/job.dart';

abstract interface class JobRepository {
  Stream<List<Job>> watchJobs({String? category, String? searchQuery});

  Future<Job?> getJob(String jobId);

  Stream<List<Job>> watchSavedJobs(String uid);

  Future<bool> isJobSaved({required String uid, required String jobId});

  Future<void> toggleSavedJob({required String uid, required String jobId});

  Stream<List<Application>> watchApplications(String uid);

  Future<bool> hasApplied({required String uid, required String jobId});

  Future<void> submitApplication(Application application);
}