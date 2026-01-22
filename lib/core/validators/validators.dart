class Validators {
  static bool isEmail(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    // simple + safe regex
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
  }

  static String? emailError(String v) {
    if (v.trim().isEmpty) return 'Email is required.';
    if (!isEmail(v)) return 'Enter a valid email.';
    return null;
  }

  static String? passwordError(String v) {
    if (v.isEmpty) return 'Password is required.';
    if (v.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  static String? nameError(String v, {String field = 'Name'}) {
    if (v.trim().isEmpty) return '$field is required.';
    if (v.trim().length < 2) return '$field is too short.';
    return null;
  }
}
