import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';
//
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Profile?> getProfile(String uid) => _remote.getProfile(uid);

  @override
  Future<void> saveProfile(Profile profile) {
    return _remote.saveProfile(ProfileModel.fromEntity(profile));
  }

  @override
  Future<String> uploadDocument({
    required String uid,
    required String fileName,
    required List<int> bytes,
  }) {
    return _remote.uploadDocument(uid: uid, fileName: fileName, bytes: bytes);
  }

  @override
  Future<void> markOnboardingComplete(String uid) {
    return _remote.markOnboardingComplete(uid);
  }
}
