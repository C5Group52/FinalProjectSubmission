import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/error/firebase_error_mapper.dart';
import '../models/career_meeting_model.dart';
import '../models/career_resource_model.dart';

class CareerSupportRemoteDataSource {
  CareerSupportRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _meetings(String uid) => _firestore
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.careerMeetingsSubcollection);

  Stream<List<CareerResourceModel>> watchResources() {
    return _firestore
        .collection(FirestorePaths.careerResources)
        .orderBy('order')
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => CareerResourceModel.fromFirestore(d.data(), d.id))
              .toList(),
        );
  }

  Stream<List<CareerMeetingModel>> watchMeetings(String uid) {
    return _meetings(uid)
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => CareerMeetingModel.fromFirestore(d.data(), d.id, uid))
              .toList(),
        );
  }

  Future<void> bookMeeting({
    required String uid,
    required String mentorName,
    required DateTime scheduledAt,
  }) async {
    try {
      await _meetings(uid).add({
        'mentorName': mentorName,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'status': 'scheduled',
        'notes': '',
      });
    } catch (e) {
      throw FirebaseErrorMapper.fromUnknown(e);
    }
  }
}
