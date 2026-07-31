import 'package:equatable/equatable.dart';

/// The signed-in user as the rest of the app sees them. Deliberately not
/// `firebase_auth.User` — the router and dashboard need `onboardingCompleted`
/// and a guaranteed `fullName`, which only live in our `users/{uid}` document.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.onboardingCompleted,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final bool onboardingCompleted;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    uid,
    fullName,
    email,
    onboardingCompleted,
    phoneNumber,
    photoUrl,
    createdAt,
  ];
}
