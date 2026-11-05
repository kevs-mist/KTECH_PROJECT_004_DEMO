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

  static final Map<String, Future<void>> _writeQueues = {};

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }

  List<PatientStay> _decode(String serialized) {
    if (serialized.trim().isEmpty) return <PatientStay>[];
    final records = jsonDecode(serialized) as List<dynamic>;
    return records
        .map(
          (record) =>
              PatientStay.fromJson(Map<String, dynamic>.from(record as Map)),
        )
        .toList();
  }

  Future<List<PatientStay>?> _readLegacyPreferences() async {
    return const SharedPreferencesPatientStayStore(
      storageKey: 'mock_api_patient_stays',
    ).readAll();
  }

  @override
  Future<List<PatientStay>?> readAll() async {
    final file = await _file();
    if (!await file.exists()) {
      final legacy = await _readLegacyPreferences();
      if (legacy == null) return null;
      await writeAll(legacy);
      return legacy;
    }

    return _decode(await file.readAsString());
  }

  Future<void> _withFileLock(Future<void> Function() action) async {
    final file = await _file();
    final lock = File('${file.path}.lock');
    while (true) {
      if (await lock.exists()) {
        final changedAt = await lock.lastModified();
        if (DateTime.now().difference(changedAt) > const Duration(minutes: 2)) {
          await lock.delete();
        }
      }
      try {
        await lock.create(exclusive: true);
        break;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }
    }
    try {
      await action();
    } finally {
      if (await lock.exists()) await lock.delete();
    }
  }

  @override
  Future<void> writeAll(List<PatientStay> patients) async {
    final previous = _writeQueues[fileName] ?? Future<void>.value();
    final queued = previous.then(
      (_) => _withFileLock(() async {
        final file = await _file();
        final serialized = jsonEncode(
          patients.map((patient) => patient.toJson()).toList(),
        );
        final random = Random.secure();
        final suffix = List.generate(
          4,
          (_) => random.nextInt(1 << 32),
        ).join('-');
        final temp = File('${file.path}.$suffix.tmp');
        await temp.create(exclusive: true);
        try {
          await temp.writeAsString(serialized, flush: true);
          if (await file.exists()) await file.delete();
          await temp.rename(file.path);
        } finally {
          if (await temp.exists()) await temp.delete();
        }
      }),
    );
    _writeQueues[fileName] = queued.catchError((Object _) {});
    await queued;
  }
}
