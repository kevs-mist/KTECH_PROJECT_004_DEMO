import 'dart:math';

import '../../backend/admissions/demo_seed.dart';
import '../../backend/admissions/local_patient_stay_store.dart';
import '../../features/admissions/models/patient_stay.dart';
import 'admissions_api.dart';

List<Admission> buildSeedAdmissions() {
  return DemoSeed.generateSeedData();
}

class MockAdmissionsApi implements AdmissionsApi {
  final Duration? latency;
  final double failureRate;
  final PatientStayStore? store;
  final bool seedDemoData;
  final Random _rng = Random();
  final List<Admission> _admissions = [];
  int _idCounter = 0;
  bool _initialized = false;

  MockAdmissionsApi({
    this.latency,
    this.failureRate = 0.0,
    this.store,
    this.seedDemoData = true,
  }) {
    if (store == null && seedDemoData) {
      _initData();
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    final currentStore = store;
    if (currentStore != null) {
      final stored = await currentStore.readAll();
      if (stored != null) {
        _admissions.clear();
        _admissions.addAll(stored);
        return;
      }
      if (seedDemoData) _initData();
      return;
    }
    if (_admissions.isEmpty && seedDemoData) {
      _initData();
    }
  }

  void _initData() {
    _initialized = true;
    _admissions.clear();
    _admissions.addAll(buildSeedAdmissions());
    final currentStore = store;
    if (currentStore != null) {
      currentStore.writeAll(_admissions);
    }
  }

  @override
  void reset() {
    if (seedDemoData) {
      _initData();
    } else {
      clear();
    }
  }

  @override
  void clear() {
    _initialized = true;
    _admissions.clear();
    final currentStore = store;
    if (currentStore != null) {
      currentStore.writeAll(_admissions);
    }
  }

  Future<void> _simulateLatencyAndErrors() async {
    if (failureRate > 0 && _rng.nextDouble() < failureRate) {
      throw const MockApiException('Simulated network error');
    }
    if (latency != null) {
      if (latency! > Duration.zero) {
        await Future.delayed(latency!);
      }
    } else {
      await Future.delayed(Duration(milliseconds: 250 + _rng.nextInt(250)));
    }
  }

  int _getFinancialYear(DateTime date) {
    return date.month >= 4 ? date.year : date.year - 1;
  }

  int _maxSerialForFinancialYear(int fy) {
    return _admissions
        .where((a) => (a.financialYear ?? _getFinancialYear(a.doa)) == fy)
        .map((a) => a.serialNo ?? 0)
        .fold<int>(0, (max, s) => s > max ? s : max);
  }

  @override
  Future<List<Admission>> listAdmissions({
    String? query,
    String? branch,
    DateTime? from,
    DateTime? to,
    bool? dischargedOnly,
  }) async {
    await _ensureInitialized();
    await _simulateLatencyAndErrors();

    var results = List<Admission>.from(_admissions);

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where((a) {
        if (a.mothersName.toLowerCase().contains(q)) return true;
        if (a.displayName.toLowerCase().contains(q)) return true;
        if (a.contactNumber.contains(q)) return true;
        if (a.contactNumber2 != null && a.contactNumber2!.contains(q)) {
          return true;
        }
        if (a.ipNo != null && a.ipNo!.toLowerCase().contains(q)) return true;
        return false;
      }).toList();
    }

    if (branch != null && branch.trim().isNotEmpty) {
      final bLower = branch.trim().toLowerCase();
      results = results.where((a) {
        if (a.branch == null) return false;
        final name = a.branch == Branch.arpanMother
            ? 'arpan mother'
            : 'arpan violet';
        return name.contains(bLower) ||
            a.branch.toString().toLowerCase().contains(bLower);
      }).toList();
    }

    if (from != null) {
      results = results.where((a) => !a.doa.isBefore(from)).toList();
    }

    if (to != null) {
      results = results.where((a) => !a.doa.isAfter(to)).toList();
    }

    if (dischargedOnly != null) {
      if (dischargedOnly) {
        results = results.where((a) => a.dod != null).toList();
      } else {
        results = results.where((a) => a.dod == null).toList();
      }
    }

    // Newest first
    results.sort((a, b) {
      final cmp = b.doa.compareTo(a.doa);
      if (cmp != 0) return cmp;
      return (b.serialNo ?? 0).compareTo(a.serialNo ?? 0);
    });

    return results;
  }

  @override
  Future<Admission?> getAdmission(String id) async {
    await _ensureInitialized();
    await _simulateLatencyAndErrors();
    try {
      return _admissions.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Admission> createAdmission(Admission admission) async {
    await _ensureInitialized();
    await _simulateLatencyAndErrors();

    // A new admission is always Admitted. Discharge data is only ever added
    // later through dischargeAdmission.
    if (admission.dod != null ||
        admission.stay != null ||
        admission.dischargeType != null) {
      throw const MockApiException(
        'A new admission cannot be created as discharged. '
        'Use the discharge form to discharge a patient.',
      );
    }

    final fy = admission.financialYear ?? _getFinancialYear(admission.doa);
    final nextSerial = _maxSerialForFinancialYear(fy) + 1;
    final id =
        admission.id ??
        'mock_${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

    String babyName = admission.babyName ?? '';
    if (admission.birthType == BirthType.twin ||
        admission.birthType == BirthType.triplet) {
      final siblings = _admissions.where(
        (a) =>
            a.mothersName.trim().toLowerCase() ==
            admission.mothersName.trim().toLowerCase(),
      );
      final usedSuffixes = siblings
          .map((a) => RegExp(r' - ([A-Z])$').firstMatch(a.babyName ?? ''))
          .whereType<RegExpMatch>()
          .map((m) => m.group(1)!)
          .toSet();
      final suffix = ['A', 'B', 'C', 'D'].firstWhere(
        (candidate) => !usedSuffixes.contains(candidate),
        orElse: () => 'A',
      );

      final prefixStr = switch (admission.prefix) {
        Prefix.so => 'S/O',
        Prefix.do_ => 'D/O',
        Prefix.bo => 'B/O',
      };
      babyName = '$prefixStr ${admission.mothersName.trim()} - $suffix';
    } else if (babyName.isEmpty) {
      final prefixStr = switch (admission.prefix) {
        Prefix.so => 'S/O',
        Prefix.do_ => 'D/O',
        Prefix.bo => 'B/O',
      };
      babyName = '$prefixStr ${admission.mothersName.trim()}';
    }

    final saved = admission.copyWith(
      id: id,
      serialNo: nextSerial,
      financialYear: fy,
      babyName: babyName,
    );

    _admissions.add(saved);
    final currentStore = store;
    if (currentStore != null) {
      await currentStore.writeAll(_admissions);
    }
    return saved;
  }

  @override
  Future<Admission> updateAdmission(Admission admission) async {
    await _ensureInitialized();
    await _simulateLatencyAndErrors();

    final id = admission.id;
    if (id == null) {
      throw const MockApiException('Admission id is required for updates');
    }
    final index = _admissions.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw const MockApiException('Admission not found');
    }

    _admissions[index] = admission;
    final currentStore = store;
    if (currentStore != null) {
      await currentStore.writeAll(_admissions);
    }
    return admission;
  }

  @override
  Future<Admission> dischargeAdmission(
    String id,
    Map<String, dynamic> dischargeData,
  ) async {
    await _ensureInitialized();
    await _simulateLatencyAndErrors();

    final index = _admissions.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw const MockApiException('Admission not found');
    }

    final existing = _admissions[index];
    if (existing.dod != null) {
      throw const MockApiException('Admission is already discharged');
    }

    // Merge discharge data
    if (dischargeData.containsKey('patient') &&
        dischargeData['patient'] is PatientStay) {
      final PatientStay p = dischargeData['patient'] as PatientStay;
      final dod = p.dod ?? DateTime.now();
      final stay = p.stay ?? dod.difference(existing.doa).inDays;
      final updated = p.copyWith(
        id: existing.id,
        serialNo: existing.serialNo,
        financialYear: existing.financialYear,
        doa: existing.doa,
        dod: dod,
        stay: stay,
      );
      _admissions[index] = updated;
      final currentStore = store;
      if (currentStore != null) {
        await currentStore.writeAll(_admissions);
      }
      return updated;
    }

    DateTime dod;
    final rawDod = dischargeData['dod'];
    if (rawDod is DateTime) {
      dod = rawDod;
    } else if (rawDod is String) {
      dod = DateTime.tryParse(rawDod) ?? DateTime.now();
    } else {
      dod = DateTime.now();
    }

    final stay =
        dischargeData['stay'] as int? ?? dod.difference(existing.doa).inDays;

    final dischargeType = dischargeData['dischargeType'] is DischargeType
        ? dischargeData['dischargeType'] as DischargeType
        : null;

    final updated = existing.copyWith(
      dod: dod,
      stay: stay,
      dischargeType: dischargeType ?? existing.dischargeType,
      ipNo: dischargeData['ipNo'] as String? ?? existing.ipNo,
      sex: dischargeData['sex'] is Sex
          ? dischargeData['sex'] as Sex
          : existing.sex,
      state: dischargeData['state'] as String? ?? existing.state,
      district: dischargeData['district'] as String? ?? existing.district,
      dateOfBirth: dischargeData['dateOfBirth'] is DateTime
          ? dischargeData['dateOfBirth'] as DateTime
          : existing.dateOfBirth,
      placeOfDeliveryDischarge:
          dischargeData['placeOfDeliveryDischarge'] as String? ??
          existing.placeOfDeliveryDischarge,
      gestAgeWeeks:
          dischargeData['gestAgeWeeks'] as int? ?? existing.gestAgeWeeks,
      gestAgeDays: dischargeData['gestAgeDays'] as int? ?? existing.gestAgeDays,
      birthWeight:
          (dischargeData['birthWeight'] as num?)?.toDouble() ??
          existing.birthWeight,
      admissionWeight:
          (dischargeData['admissionWeight'] as num?)?.toDouble() ??
          existing.admissionWeight,
      weightPercentile: dischargeData['weightPercentile'] is WeightPercentile
          ? dischargeData['weightPercentile'] as WeightPercentile
          : existing.weightPercentile,
      dischargeWeight:
          (dischargeData['dischargeWeight'] as num?)?.toDouble() ??
          existing.dischargeWeight,
      headCircumference:
          (dischargeData['headCircumference'] as num?)?.toDouble() ??
          existing.headCircumference,
      length: (dischargeData['length'] as num?)?.toDouble() ?? existing.length,
      shiftedTo: dischargeData['shiftedTo'] as String? ?? existing.shiftedTo,
      shiftReason:
          dischargeData['shiftReason'] as String? ?? existing.shiftReason,
      maternalMorbidities:
          dischargeData['maternalMorbidities'] as List<String>? ??
          existing.maternalMorbidities,
      maternalReceivedAntibiotics:
          dischargeData['maternalReceivedAntibiotics'] as bool? ??
          existing.maternalReceivedAntibiotics,
      maternalAntibiotics:
          dischargeData['maternalAntibiotics'] as List<String>? ??
          existing.maternalAntibiotics,
      maternalAntibioticsOther:
          dischargeData['maternalAntibioticsOther'] as String? ??
          existing.maternalAntibioticsOther,
      cardiovascularSystem:
          dischargeData['cardiovascularSystem'] as String? ??
          existing.cardiovascularSystem,
      sepsis: dischargeData['sepsis'] as String? ?? existing.sepsis,
      organism: dischargeData['organism'] as String? ?? existing.organism,
      feeding:
          dischargeData['feeding'] as List<String>? ?? existing.feeding,
      rtfStarted:
          dischargeData['rtfStarted'] as String? ?? existing.rtfStarted,
      fullFeedsReached:
          dischargeData['fullFeedsReached'] as String? ??
          existing.fullFeedsReached,
      surfactant: dischargeData['surfactant'] is Surfactant
          ? dischargeData['surfactant'] as Surfactant
          : existing.surfactant,
      ventilation:
          dischargeData['ventilation'] as List<String>? ??
          existing.ventilation,
      bpd: dischargeData['bpd'] is BPD
          ? dischargeData['bpd'] as BPD
          : existing.bpd,
      probiotics:
          dischargeData['probiotics'] as bool? ?? existing.probiotics,
      bloodTransfusion:
          dischargeData['bloodTransfusion'] as bool? ??
          existing.bloodTransfusion,
      rop: dischargeData['rop'] is ROP
          ? dischargeData['rop'] as ROP
          : existing.rop,
      usgHead: dischargeData['usgHead'] as String? ?? existing.usgHead,
      fileName: dischargeData['fileName'] as String? ?? existing.fileName,
      adductaAngle:
          dischargeData['adductaAngle'] as String? ?? existing.adductaAngle,
      cdcHeadControl:
          dischargeData['cdcHeadControl'] as String? ?? existing.cdcHeadControl,
      cdcSitting:
          dischargeData['cdcSitting'] as String? ?? existing.cdcSitting,
      cdcStanding:
          dischargeData['cdcStanding'] as String? ?? existing.cdcStanding,
      dasiiMotorAgeAt50thCentile:
          dischargeData['dasiiMotorAgeAt50thCentile'] as String? ??
          existing.dasiiMotorAgeAt50thCentile,
      dasiiMotorAgeAt97thCentile:
          dischargeData['dasiiMotorAgeAt97thCentile'] as String? ??
          existing.dasiiMotorAgeAt97thCentile,
      dasiiMentalAgeAt50thCentile:
          dischargeData['dasiiMentalAgeAt50thCentile'] as String? ??
          existing.dasiiMentalAgeAt50thCentile,
      dasiiMentalAgeAt97thCentile:
          dischargeData['dasiiMentalAgeAt97thCentile'] as String? ??
          existing.dasiiMentalAgeAt97thCentile,
      other: dischargeData['other'] as String? ?? existing.other,
      remarks: dischargeData['remarks'] as String? ?? existing.remarks,
      picc: dischargeData['picc'] as bool? ?? existing.picc,
      user: dischargeData['user'] as String? ?? existing.user,
      statusOk: dischargeData['statusOk'] as bool? ?? true,
    );

    _admissions[index] = updated;
    final currentStore = store;
    if (currentStore != null) {
      await currentStore.writeAll(_admissions);
    }
    return updated;
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    await _ensureInitialized();
    await _simulateLatencyAndErrors();

    final totalAdmissions = _admissions.length;
    final totalDischarges = _admissions.where((a) => a.dod != null).length;
    final currentlyAdmitted = _admissions.where((a) => a.dod == null).length;

    final Map<String, int> admissionsByMonth = {};
    final Map<String, int> dischargesByMonth = {};
    final Map<String, int> admissionsByDay = {};
    final Map<String, int> dischargesByDay = {};
    final Map<String, int> admissionsByYear = {};
    final Map<String, int> dischargesByYear = {};

    for (final a in _admissions) {
      final y = a.doa.year.toString();
      final ym = '$y-${a.doa.month.toString().padLeft(2, '0')}';
      final ymd = '$ym-${a.doa.day.toString().padLeft(2, '0')}';

      admissionsByYear[y] = (admissionsByYear[y] ?? 0) + 1;
      admissionsByMonth[ym] = (admissionsByMonth[ym] ?? 0) + 1;
      admissionsByDay[ymd] = (admissionsByDay[ymd] ?? 0) + 1;

      if (a.dod != null) {
        final dy = a.dod!.year.toString();
        final dym = '$dy-${a.dod!.month.toString().padLeft(2, '0')}';
        final dymd = '$dym-${a.dod!.day.toString().padLeft(2, '0')}';

        dischargesByYear[dy] = (dischargesByYear[dy] ?? 0) + 1;
        dischargesByMonth[dym] = (dischargesByMonth[dym] ?? 0) + 1;
        dischargesByDay[dymd] = (dischargesByDay[dymd] ?? 0) + 1;
      }
    }

    return DashboardStats(
      totalAdmissions: totalAdmissions,
      totalDischarges: totalDischarges,
      currentlyAdmitted: currentlyAdmitted,
      admissionsByMonth: admissionsByMonth,
      dischargesByMonth: dischargesByMonth,
      admissionsByDay: admissionsByDay,
      dischargesByDay: dischargesByDay,
      admissionsByYear: admissionsByYear,
      dischargesByYear: dischargesByYear,
    );
  }
}
