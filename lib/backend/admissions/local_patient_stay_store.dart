import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/admissions/models/patient_stay.dart';

abstract interface class PatientStayStore {
  Future<List<PatientStay>?> readAll();

  Future<void> writeAll(List<PatientStay> patients);
}

class SharedPreferencesPatientStayStore implements PatientStayStore {
  final String storageKey;

  const SharedPreferencesPatientStayStore({required this.storageKey});

  @override
  Future<List<PatientStay>?> readAll() async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = preferences.getString(storageKey);
    if (serialized == null) return null;

    final records = jsonDecode(serialized) as List<dynamic>;
    return records
        .map(
          (record) =>
              PatientStay.fromJson(Map<String, dynamic>.from(record as Map)),
        )
        .toList();
  }

  @override
  Future<void> writeAll(List<PatientStay> patients) async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = jsonEncode(
      patients.map((patient) => patient.toJson()).toList(),
    );
    await preferences.setString(storageKey, serialized);
  }
}
