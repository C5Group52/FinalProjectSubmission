import 'package:somtalent/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:somtalent/features/auth/data/models/app_user_model.dart';
import 'package:somtalent/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource remote;
  late AuthRepositoryImpl repository;

  const testUser = AppUserModel(
    uid: 'uid-123',
    fullName: 'Hodan Ahmed',
    email: 'hodan@example.com',
    onboardingCompleted: false,
  );

  setUp(() {
    remote = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remote);
  });

  test('currentUser is null before the auth stream emits', () {
    expect(repository.currentUser, isNull);
  });

  test('currentUser caches the latest value from authStateChanges', () async {
    when(
      () => remote.watchAuthState(),
    ).thenAnswer((_) => Stream.value(testUser));

    await repository.authStateChanges().first;

    expect(repository.currentUser, testUser);
    expect(repository.currentUser?.uid, 'uid-123');
  });

  test('signUpWithEmail passes the form values through to the data source', () {
    when(
      () => remote.signUpWithEmail(
        fullName: any(named: 'fullName'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        phoneNumber: any(named: 'phoneNumber'),
      ),
    ).thenAnswer((_) async => testUser);

    repository.signUpWithEmail(
      fullName: 'Hodan Ahmed',
      email: 'hodan@example.com',
      password: 'passw0rd1',
      phoneNumber: '+252630000000',
    );

    verify(
      () => remote.signUpWithEmail(
        fullName: 'Hodan Ahmed',
        email: 'hodan@example.com',
        password: 'passw0rd1',
        phoneNumber: '+252630000000',
      ),
    ).called(1);
  });

  test('signOut clears the cached user', () async {
    when(
      () => remote.watchAuthState(),
    ).thenAnswer((_) => Stream.value(testUser));
    when(() => remote.signOut()).thenAnswer((_) async {});

    await repository.authStateChanges().first;
    expect(repository.currentUser, isNotNull);

    await repository.signOut();

    expect(repository.currentUser, isNull);
  });
}
