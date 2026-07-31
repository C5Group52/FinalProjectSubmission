import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() {
    // Caching each emission is what lets `currentUser` answer synchronously
    // for callers like the profile providers, which can't await a stream.
    return _remote.watchAuthState().map((user) {
      _currentUser = user;
      return user;
    });
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) {
    return _remote.signUpWithEmail(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _remote.signInWithEmail(email: email, password: password);
  }

  @override
  Future<AppUser> signInWithGoogle() => _remote.signInWithGoogle();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _remote.sendPasswordResetEmail(email);

  @override
  Future<void> signOut() async {
    await _remote.signOut();
    _currentUser = null;
  }
}
