import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/backend/admissions/local_patient_stay_store.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory directory;
  const store = DataFilePatientStayStore();

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('patient-store-test-');
    SharedPreferences.setMockInitialValues({});
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationSupportDirectory') {
        return directory.path;
      }
      throw MissingPluginException('Unexpected lookup: ${call.method}');
    });
  });

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
    await directory.delete(recursive: true);
  });

  test('migrates legacy records before repository seeding', () async {
    final patient = _patient('Legacy');
    SharedPreferences.setMockInitialValues({
      'mock_api_patient_stays': jsonEncode([patient.toJson()]),
    });

    expect((await store.readAll())!.single.mothersName, 'Legacy');
    SharedPreferences.setMockInitialValues({});
    expect((await store.readAll())!.single.mothersName, 'Legacy');
    expect(
      await File('${directory.path}/ktech_clinical_registry.data').exists(),
      isTrue,
    );
  });

  test('migrates an empty legacy registry without seeding', () async {
    SharedPreferences.setMockInitialValues({'mock_api_patient_stays': '[]'});
    expect(await store.readAll(), isEmpty);
    final content = await File(
      '${directory.path}/ktech_clinical_registry.data',
    ).readAsString();
    // Registry must be stored encrypted, never as plaintext JSON.
    expect(content, isNot('[]'));
    expect(content, contains('cipherText'));
  });

  test(
    'existing file takes precedence over preferences and is replaced',
    () async {
      SharedPreferences.setMockInitialValues({
        'mock_api_patient_stays': jsonEncode([_patient('Legacy').toJson()]),
      });
      await store.writeAll([_patient('First')]);
      expect((await store.readAll())!.single.mothersName, 'First');
      await store.writeAll([_patient('Second')]);
      expect((await store.readAll())!.single.mothersName, 'Second');
      // Registry, key file and pre-overwrite backup exist; no temp/lock
      // files may be left behind.
      final leftovers = await directory
          .list()
          .where(
            (entity) => entity.path.endsWith('.tmp') ||
                entity.path.endsWith('.lock'),
          )
          .toList();
      expect(leftovers, isEmpty);
      // The on-disk registry must not contain plaintext patient data.
      final content = await File(
        '${directory.path}/ktech_clinical_registry.data',
      ).readAsString();
      expect(content, isNot(contains('Second')));
      expect(content, contains('cipherText'));
    },
  );

  test('lookup failure propagates without switching directories', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'unavailable');
    });
    await expectLater(store.readAll(), throwsA(isA<PlatformException>()));
    await expectLater(store.writeAll([]), throwsA(isA<PlatformException>()));
  });

  test('serialization failure leaves the existing registry intact', () async {
    await store.writeAll([_patient('Existing')]);
    final file = File('${directory.path}/ktech_clinical_registry.data');
    final before = await file.readAsString();
    await expectLater(store.writeAll([_FailingPatient()]), throwsStateError);
    expect(await file.readAsString(), before);
  });
}

PatientStay _patient(String name) => PatientStay(
  prefix: Prefix.bo,
  mothersName: name,
  doa: DateTime(2026, 1, 1),
  contactNumber: '1234567890',
  contactRelation: Relation.mother,
  pin: '380001',
  del: 'Hospital',
);

class _FailingPatient extends PatientStay {
  _FailingPatient()
    : super(
        prefix: Prefix.bo,
        mothersName: 'Failure',
        doa: DateTime(2026, 1, 1),
        contactNumber: '1234567890',
        contactRelation: Relation.mother,
        pin: '380001',
        del: 'Hospital',
      );

  @override
  Map<String, dynamic> toJson() => throw StateError('serialization failed');
}
