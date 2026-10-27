class ValidationError {
  final String message;

  const ValidationError(this.message);
}

class Validators {
  static ValidationError? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationError('Email is required');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return const ValidationError('Please enter a valid email address');
    }

    return null;
  }

  static ValidationError? validatePassword(String? value, {bool isCreate = false}) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationError('Password is required');
    }

    if (isCreate && value.length < 12) {
      return const ValidationError('Password must be at least 12 characters');
    }

    return null;
  }

  static ValidationError? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return const ValidationError('Please confirm your password');
    }

    if (password != confirmPassword) {
      return const ValidationError('Passwords do not match');
    }

    return null;
  }

  static ValidationError? validateMedicalRegistration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationError('Medical registration number is required');
    }

    final trimmed = value.trim();

    if (trimmed.length < 4 || trimmed.length > 20) {
      return const ValidationError('Must be 4-20 characters');
    }

    final validChars = RegExp(r'^[a-zA-Z0-9/-]+$');
    if (!validChars.hasMatch(trimmed)) {
      return const ValidationError('Only letters, digits, slash, and hyphen allowed');
    }

    return null;
  }

  static ValidationError? validateAccessCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationError('Access code is required');
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const ValidationError('Access code is required');
    }

    return null;
  }
}
