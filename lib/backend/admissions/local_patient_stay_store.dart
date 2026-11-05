import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }

  @override
  Future<List<PatientStay>?> readAll() async {
    final file = await _file();
    if (!await file.exists()) {
      final records = await const SharedPreferencesPatientStayStore(
        storageKey: 'mock_api_patient_stays',
      ).readAll();
      if (records != null) await _writeFile(file, records);
      return records;
    }

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
    await _writeFile(file, patients);
  }

  Future<void> _writeFile(File file, List<PatientStay> patients) async {
    final serialized = jsonEncode(
      patients.map((patient) => patient.toJson()).toList(),
    );
    final random = Random.secure();
    final suffix = List.generate(4, (_) => random.nextInt(1 << 32)).join('-');
    final temporary = File('${file.path}.$suffix.tmp');
    await temporary.create(exclusive: true);
    try {
      await temporary.writeAsString(serialized, flush: true);
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
