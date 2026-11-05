import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ktech_project_004/backend/admissions/demo_admissions_repository.dart';
import 'package:ktech_project_004/data/providers/demo_providers.dart';
import 'package:ktech_project_004/features/admissions/discharge_form_screen.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';

void main() {
  testWidgets('open action follows document type and layout', (tester) async {
    final previousPicker = FilePickerPlatform.instance;
    final picker = _Picker();
    FilePickerPlatform.instance = picker;
    addTearDown(() => FilePickerPlatform.instance = previousPicker);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const DischargeFormScreen()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          admissionsRepositoryProvider.overrideWithValue(
            DemoAdmissionsRepository(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    picker.file = _File('notes.txt', Uri.file('/tmp/notes.txt'));
    await tester.tap(find.text('Open Document').first);
    await tester.pumpAndSettle();
    expect(find.text('Open in default app'), findsOneWidget);

    tester.view.physicalSize = const Size(1400, 800);
    await tester.pumpAndSettle();
    expect(find.text('Open in default app'), findsOneWidget);

    tester.view.physicalSize = const Size(900, 800);
    await tester.pumpAndSettle();
    picker.file = _File('scan.pdf', Uri.file('/tmp/scan.pdf'));
    await tester.tap(find.text('Open Document').first);
    await tester.pumpAndSettle();
    expect(find.text('Open in default app'), findsNothing);

    picker.file = _File('notes.txt', Uri.parse('memory:notes'));
    await tester.tap(find.text('Open Document').first);
    await tester.pumpAndSettle();
    expect(find.text('Open in default app'), findsNothing);
  });

  testWidgets('clearing transfusion saves null and exposes distinct labels', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _Admissions();
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const DischargeFormScreen()),
        GoRoute(path: '/dashboard', builder: (_, _) => const Scaffold()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [admissionsRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<PatientStay>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(repository.patient.displayName).last);
    await tester.pumpAndSettle();
    final yes = find.byWidgetPredicate(
      (widget) =>
          widget is Checkbox && widget.semanticLabel == 'Blood Transfusion Yes',
    );
    final no = find.byWidgetPredicate(
      (widget) =>
          widget is Checkbox && widget.semanticLabel == 'Blood Transfusion No',
    );
    expect(yes, findsOneWidget);
    expect(no, findsOneWidget);
    expect(tester.widget<Checkbox>(yes).value, isTrue);
    await tester.ensureVisible(yes);
    await tester.tap(yes);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(yes).value, isFalse);
    expect(tester.widget<Checkbox>(no).value, isFalse);
    await tester.ensureVisible(find.text('SAVE'));
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(repository.saved, isNotNull);
    expect(repository.saved!.bloodTransfusion, isNull);
  });
}

class _Picker extends FilePickerPlatform {
  PlatformFile? file;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => file;
}

base class _File extends PlatformFile {
  _File(this.name, this.uri);
  @override
  final String name;
  @override
  final Uri uri;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Admissions extends DemoAdmissionsRepository {
  final patient = PatientStay(
    id: 'test',
    prefix: Prefix.bo,
    mothersName: 'Test Mother',
    doa: DateTime(2020, 1, 1),
    contactNumber: '1234567890',
    contactRelation: Relation.mother,
    pin: '380001',
    del: 'Hospital',
    bloodTransfusion: true,
  );
  PatientStay? saved;

  @override
  Future<List<PatientStay>> getAdmittedPatients() async => [patient];

  @override
  Future<PatientStay> updatePatient(PatientStay value) async {
    saved = value;
    return value;
  }
}
