import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

/// Persists admissions and discharges in an AES-256-GCM encrypted JSON
/// document with a `.data` extension. The registry key is stored in the
/// platform secure keystore (Keychain / DPAPI) when available, falling back
/// to a permission-restricted key file for environments without one.
/// Desktop app sessions read and write the same file so records survive
/// closing and reopening the application.
class DataFilePatientStayStore implements PatientStayStore {
  final String fileName;

  const DataFilePatientStayStore({
    this.fileName = 'ktech_clinical_registry.data',
  });

  static const String _keyAccount = 'ktech_clinical_registry_key';
  static final AesGcm _algorithm = AesGcm.with256bits();

  static final Map<String, Future<void>> _writeQueues = {};
  static final Map<String, Future<SecretKey>> _keyFutures = {};

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }

  Future<File> _keyFile() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return File(
      '${directory.path}${Platform.pathSeparator}$fileName.key',
    );
  }

  List<int> _randomKeyBytes() {
    final random = Random.secure();
    return List<int>.generate(32, (_) => random.nextInt(256));
  }

  Future<SecretKey> _registryKey() {
    return _keyFutures[fileName] ??= _loadOrCreateKey();
  }

  Future<SecretKey> _loadOrCreateKey() async {
    try {
      const storage = FlutterSecureStorage();
      final encoded = await storage.read(key: _keyAccount);
      if (encoded != null && encoded.isNotEmpty) {
        return SecretKey(base64Decode(encoded));
      }
      final generatedBytes = _randomKeyBytes();
      await storage.write(
        key: _keyAccount,
        value: base64Encode(generatedBytes),
      );
      return SecretKey(generatedBytes);
    } on MissingPluginException {
      return _fileBackedKey();
    } catch (_) {
      return _fileBackedKey();
    }
  }

  Future<SecretKey> _fileBackedKey() async {
    final file = await _keyFile();
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      if (bytes.length == 32) return SecretKey(bytes);
    }
    final bytes = _randomKeyBytes();
    await file.writeAsBytes(bytes, flush: true);
    try {
      await Process.run('chmod', ['600', file.path]);
    } catch (_) {
      // Best effort: some platforms do not support chmod.
    }
    return SecretKey(bytes);
  }

  Future<String> _encrypt(String plaintext, SecretKey key) async {
    final box = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
    );
    return jsonEncode({
      'v': 1,
      'nonce': base64Encode(box.nonce),
      'cipherText': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  Future<String> _decryptEnvelope(String content, SecretKey key) async {
    final trimmed = content.trimLeft();
    if (!trimmed.startsWith('{')) return content;

    final envelope = jsonDecode(trimmed) as Map<String, dynamic>;
    if (!envelope.containsKey('nonce') ||
        !envelope.containsKey('cipherText') ||
        !envelope.containsKey('mac')) {
      return content;
    }

    final box = SecretBox(
      base64Decode(envelope['cipherText'] as String),
      nonce: base64Decode(envelope['nonce'] as String),
      mac: Mac(base64Decode(envelope['mac'] as String)),
    );
    final plain = await _algorithm.decrypt(box, secretKey: key);
    return utf8.decode(plain);
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

    final content = await file.readAsString();
    try {
      final key = await _registryKey();
      final serialized = await _decryptEnvelope(content, key);
      return _decode(serialized);
    } catch (_) {
      // Undecryptable or corrupted registry: preserve it for manual
      // recovery, then report missing data so callers reseed cleanly.
      try {
        final stamp = DateTime.now().millisecondsSinceEpoch;
        await file.rename('${file.path}.corrupt-$stamp');
      } catch (_) {}
      return null;
    }
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
        final key = await _registryKey();
        final envelope = await _encrypt(serialized, key);
        final random = Random.secure();
        final suffix = List.generate(
          4,
          (_) => random.nextInt(1 << 32),
        ).join('-');
        final temp = File('${file.path}.$suffix.tmp');
        await temp.create(exclusive: true);
        try {
          await temp.writeAsString(envelope, flush: true);
          if (await file.exists()) {
            await file.copy('${file.path}.bak');
            await file.delete();
          }
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
