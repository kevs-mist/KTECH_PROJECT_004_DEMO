import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/user_role.dart';

class AuthSession {
  final bool isAuthenticated;
  final bool isDemo;
  final String userName;
  final UserRole role;
  final String email;
  final String? accessToken;
  final String? refreshToken;
  final bool requiresOtp;
  final String? otpCode;
  final int expiresInSeconds;
  final String? userId;
  final String? status;
  final String? deviceId;
  final String? deviceName;

  const AuthSession({
    required this.isAuthenticated,
    required this.isDemo,
    required this.userName,
    required this.role,
    required this.email,
    this.accessToken,
    this.refreshToken,
    this.requiresOtp = false,
    this.otpCode,
    this.expiresInSeconds = 0,
    this.userId,
    this.status,
    this.deviceId,
    this.deviceName,
  });

  factory AuthSession.otpRequired({
    required String email,
    required UserRole role,
    String? otpCode,
    int expiresInSeconds = 300,
  }) {
    return AuthSession(
      isAuthenticated: false,
      isDemo: false,
      userName: email,
      role: role,
      email: email,
      requiresOtp: true,
      otpCode: otpCode,
      expiresInSeconds: expiresInSeconds,
      status: 'otp_required',
    );
  }

  factory AuthSession.authenticated({
    required String email,
    required UserRole role,
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? deviceId,
    String? deviceName,
    int expiresInSeconds = 900,
  }) {
    return AuthSession(
      isAuthenticated: true,
      isDemo: false,
      userName: email.split('@').first,
      role: role,
      email: email,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresInSeconds: expiresInSeconds,
      userId: userId,
      status: 'authenticated',
      deviceId: deviceId,
      deviceName: deviceName,
    );
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final rawRole = (json['role'] ?? 'DOCTOR').toString().toUpperCase();
    final role = switch (rawRole) {
      'ADMIN' => UserRole.admin,
      'DATA_ENTRY' => UserRole.dataEntry,
      _ => UserRole.doctor,
    };

    final isAuthenticated =
        json['status'] == 'authenticated' ||
        json['accessToken'] != null ||
        json['isAuthenticated'] == true;

    return AuthSession(
      isAuthenticated: isAuthenticated,
      isDemo: json['isDemo'] == true,
      userName: (json['userName'] ?? json['email'] ?? 'User').toString(),
      role: role,
      email: (json['email'] ?? 'user@example.com').toString(),
      accessToken: json['accessToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      requiresOtp:
          json['requiresOtp'] == true || json['status'] == 'otp_required',
      otpCode: json['otpCode']?.toString(),
      expiresInSeconds: int.tryParse('${json['expiresInSeconds'] ?? 0}') ?? 0,
      userId: json['userId']?.toString(),
      status: json['status']?.toString(),
      deviceId: json['deviceId']?.toString(),
      deviceName: json['deviceName']?.toString(),
    );
  }
}

class AuthApi {
  static const String _defaultBaseUrl = 'http://localhost:3001';

  final String baseUrl;
  final http.Client client;

  AuthApi({String? baseUrl, http.Client? client})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'AUTH_API_URL',
            defaultValue: _defaultBaseUrl,
          ),
      client = client ?? http.Client();

  Future<AuthSession> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || password.trim().isEmpty) {
      throw const FormatException('Email and password are required');
    }

    throw UnsupportedError(
      'Firebase sign-in is not configured for ${role.name}; authentication cannot be simulated.',
    );
  }

  Future<AuthSession> verifyOtp({
    required String email,
    required String code,
    String? deviceId,
    String? deviceName,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || code.trim().length != 6) {
      throw const FormatException('A valid OTP is required');
    }

    final payload = {
      'email': normalizedEmail,
      'code': code.trim(),
      'deviceId': ?deviceId,
      'deviceName': ?deviceName,
    };

    final response = await client.post(
      Uri.parse('$baseUrl/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(decoded['message'] ?? 'OTP verification failed');
    }

    return AuthSession.fromJson(decoded);
  }

  Future<void> register({
    required String email,
    required String password,
    required String medicalRegistration,
    required String accessCode,
    required UserRole role,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || password.trim().isEmpty) {
      throw const FormatException('Registration details are required');
    }

    throw UnsupportedError(
      'Registration is not available in the auth service.',
    );
  }

  Future<void> forgotPassword({
    required String email,
    required UserRole role,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      throw const FormatException('Email is required');
    }

    throw UnsupportedError(
      'Password reset is not available in the auth service.',
    );
  }

  Future<void> signOut() async {
    return;
  }
}
