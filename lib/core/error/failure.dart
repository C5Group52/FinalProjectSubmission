/// Base failure type surfaced to the presentation layer. Repositories catch
/// data-source exceptions (Firebase, network, etc.) and translate them into
/// one of these so the UI never has to know about Firebase-specific types.
sealed class Failure {
  const Failure(this.message);

  final String message;

  /// Snackbars call `error.toString()` on whatever `AsyncValue.error` holds;
  /// without this override that prints `Instance of 'AuthFailure'` instead
  /// of the actual message.
  @override
  String toString() => message;
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Check your network and try again.',
  ]);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'The requested item could not be found.',
  ]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}