import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
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

/// Persists admissions and discharges in a JSON document with a `.data`
/// extension. Desktop app sessions read and write the same file so records
/// survive closing and reopening the application.
class DataFilePatientStayStore implements PatientStayStore {
  final String fileName;

  const DataFilePatientStayStore({
    this.fileName = 'ktech_clinical_registry.data',
  });

  Future<File> _file() async {
    late final Directory directory;
    try {
      directory = await getApplicationSupportDirectory();
    } catch (_) {
      directory = await getApplicationDocumentsDirectory();
    }
    await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }

  @override
  Future<List<PatientStay>?> readAll() async {
    final file = await _file();
    if (!await file.exists()) return null;

    final serialized = await file.readAsString();
    if (serialized.trim().isEmpty) return <PatientStay>[];

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
    final file = await _file();
    final serialized = jsonEncode(
      patients.map((patient) => patient.toJson()).toList(),
    );
    await file.writeAsString(serialized, flush: true);
  }
}
