/// Form-field validators shared across the app. Each returns `null` when
/// valid, or a user-facing error string otherwise — the shape `TextFormField`
/// expects for its `validator` callback.
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 2) return 'Full name is too short';
    if (!v.contains(' ')) return 'Enter your first and last name';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? phoneNumber(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required';
    final digitsOnly = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Requires 8+ chars with at least one letter and one digit — enough to
  /// stop trivially weak passwords without being punitive for real users.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'[0-9]').hasMatch(v)) {
      return 'Password must contain a letter and a number';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() originalPassword,
  ) {
    return (value) {
      if (value != originalPassword()) return 'Passwords do not match';
      return null;
    };
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if ((value ?? '').trim().isEmpty) return '$fieldName is required';
    return null;
  }
}