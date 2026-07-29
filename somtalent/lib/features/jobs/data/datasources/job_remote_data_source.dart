import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/error/firebase_error_mapper.dart';
import '../models/application_model.dart';
import '../models/job_model.dart';

class JobRemoteDataSource {
  JobRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _jobs =>
      _firestore.collection(FirestorePaths.jobs);

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection(FirestorePaths.applications);

  CollectionReference<Map<String, dynamic>> _savedJobs(String uid) => _firestore
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.savedJobsSubcollection);

  Stream<List<JobModel>> watchJobs({String? category, String? searchQuery}) {
    Query<Map<String, dynamic>> query = _jobs
        .where('status', isEqualTo: 'open')
        .orderBy('postedAt', descending: true);
    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snapshot) {
      var jobs = snapshot.docs
          .map((doc) => JobModel.fromFirestore(doc.data(), doc.id))
          .toList();
      // Firestore has no full-text search; filtering client-side keeps the
      // data model simple for a dataset this small (school-project scale).
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        jobs = jobs
            .where(
              (job) =>
                  job.title.toLowerCase().contains(q) ||
                  job.company.toLowerCase().contains(q) ||
                  job.skillsRequired.any((s) => s.toLowerCase().contains(q)),
            )
            .toList();
      }
      return jobs;
    });
  }

  Future<JobModel?> getJob(String jobId) async {
    final doc = await _jobs.doc(jobId).get();
    if (!doc.exists) return null;
    return JobModel.fromFirestore(doc.data()!, doc.id);
  }

  Stream<List<String>> watchSavedJobIds(String uid) {
    return _savedJobs(
      uid,
    ).snapshots().map((s) => s.docs.map((d) => d.id).toList());
  }

  Future<bool> isJobSaved({required String uid, required String jobId}) async {
    final doc = await _savedJobs(uid).doc(jobId).get();
    return doc.exists;
  }

  Future<void> toggleSavedJob({
    required String uid,
    required String jobId,
  }) async {
    try {
      final ref = _savedJobs(uid).doc(jobId);
      final doc = await ref.get();
      if (doc.exists) {
        await ref.delete();
      } else {
        await ref.set({'savedAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      throw FirebaseErrorMapper.fromUnknown(e);
    }
  }

  Stream<List<ApplicationModel>> watchApplications(String uid) {
    return _applications
        .where('uid', isEqualTo: uid)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => ApplicationModel.fromFirestore(d.data(), d.id))
              .toList(),
        );
  }

  Future<bool> hasApplied({required String uid, required String jobId}) async {
    final result = await _applications
        .where('uid', isEqualTo: uid)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> submitApplication(ApplicationModel application) async {
    try {
      await _applications.add(application.toFirestore());
    } catch (e) {
      throw FirebaseErrorMapper.fromUnknown(e);
    }
  }
}