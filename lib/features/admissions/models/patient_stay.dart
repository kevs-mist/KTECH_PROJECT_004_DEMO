enum Relation { father, mother, gFather, uncle, mama, nana, nani, foi }

enum Prefix {
  so, // Son of
  do_, // Daughter of (renamed to avoid keyword conflict)
  bo, // Baby of
}

enum PatientStatus { alive, expire }

enum BirthType { single, twin, triplet }

enum AdmissionType { inborn, outborn }

enum AdmissionHistory { firstAdmission, reAdmission }

enum Branch { arpanMother, arpanViolet }

enum DischargeType { routine, expired, shift }

enum Sex { male, female }

enum WeightPercentile {
  afd, // Appropriate for gestational age
  sfd, // Small for gestational age
  lfd, // Large for gestational age
}

enum ANS { yes, no, incomplete }

enum ModeOfDelivery { vaginal, cesarian, forceps }

enum Surfactant { no, singleDose, multipleDose }

enum BPD { yes, no }

enum ROP { no, treated, notTreated }

enum DischargeStatus { admitted, discharged }

class PatientStay {
  // Admission fields (Field List A)
  final String? id;
  final int? serialNo; // S.NO - auto per financial year
  final int? financialYear;
  final Prefix prefix; // PT'S NAME prefix
  final String mothersName; // PT'S NAME - mother's name
  final String? babyName;
  final Branch? branch;
  final AdmissionType? admissionType;
  final AdmissionHistory? admissionHistory;
  final BirthType? birthType;
  final DateTime doa; // Date of Admission
  final DateTime? dod; // Date of Discharge (null at admission)
  final int? stay; // STAY - calculated days
  final String contactNumber; // CONTACT NUMBER
  final Relation contactRelation; // CONTACT NUMBER relation
  final String? contactNumber2; // CONTACT NUMBER2
  final Relation? contactRelation2; // CONTACT NUMBER2 relation
  final String? address; // ADDRESS
  final String? street; // STREET
  final String? area; // AREA
  final String city; // CITY (default AHMEDABAD)
  final String pin; // PIN - 6 digits
  final String del; // DEL - place of delivery
  final PatientStatus? status; // STATUS - ALIVE/EXPIRE
  final String? remarks;
  final String? lastRemarked;

  // Discharge fields (Field List B - nullable until discharge)
  final String? ipNo; // IP No.
  final Sex? sex;
  final String? state; // State (default Gujarat)
  final String? district; // District (mandatory)
  final DateTime? dateOfBirth; // Date of Birth
  final String? placeOfDeliveryDischarge; // Place of delivery (combobox)
  final int? gestAgeWeeks; // Gest Age - Week
  final int? gestAgeDays; // Gest Age - Days (0-6)
  final double? birthWeight; // Birth Weight in kg (3 decimals)
  final double? admissionWeight; // Admission WT in kg (3 decimals)
  final WeightPercentile? weightPercentile;
  final double? dischargeWeight; // Discharge Weight in kg (3 decimals)
  final double? headCircumference; // Head Circumference in cm (1 decimal)
  final double? length; // Length in cm (1 decimal)
  final List<String>? maternalMorbidities; // Multi-select
  final String? maternalMorbiditiesOther; // Other text
  final ANS? ans;
  final List<String>? antentalScan; // Multi-select
  final String? antentalScanOther; // Other text
  final ModeOfDelivery? modeOfDelivery;
  final List<String>? resuscitationAtBirth; // Multi-select
  final String? respiratorySystemOther; // Other text
  final List<String>? respiratorySystem; // Multi-select
  final List<String>? antibiotics;
  final String? cardiovascularSystem;
  final String? sepsisOther; // Other text
  final String? sepsis; // No Sepsis, Culture -ve, Culture +ve
  final String? organism;
  final List<String>? feeding; // Multi-select
  final String? feedingOther; // Other text
  final String? rtfStarted;
  final String? fullFeedsReached;
  final Surfactant? surfactant;
  final List<String>? ventilation; // Multi-select
  final BPD? bpd;
  final bool? probiotics;
  final bool? bloodTransfusion;
  final ROP? rop;
  final String? usgHead;
  final String? fileName;
  final String? adductaAngle;
  final String? cdcHeadControl;
  final String? cdcSitting;
  final String? cdcStanding;
  final String? dasiiMotorAgeAt50thCentile;
  final String? dasiiMotorAgeAt97thCentile;
  final String? dasiiMentalAgeAt50thCentile;
  final String? dasiiMentalAgeAt97thCentile;
  final String? other;
  final bool? picc;
  final String? user; // User who discharged
  final bool statusOk; // Status "OK" verified checkbox
  final DischargeType? dischargeType;
  final String? shiftedTo;
  final String? shiftReason;

  // Computed fields
  String get displayName => babyName ?? 'Baby of $mothersName';
  String get babyNameWithPrefix {
    if (babyName != null && babyName!.trim().isNotEmpty) return babyName!;
    switch (prefix) {
      case Prefix.so:
        return 'S/O $mothersName';
      case Prefix.do_:
        return 'D/O $mothersName';
      case Prefix.bo:
        return 'B/O $mothersName';
    }
  }

  DischargeStatus get dischargeStatus {
    if (dod == null) return DischargeStatus.admitted;
    return DischargeStatus.discharged;
  }

  int get daysStayed {
    if (dod == null) {
      // Currently admitted - calculate days so far
      return DateTime.now().difference(doa).inDays;
    }
    return dod!.difference(doa).inDays;
  }

  String get daysStayedText {
    if (dod == null) {
      return '$daysStayed days so far';
    }
    return '$daysStayed days';
  }

  PatientStay({
    this.id,
    this.serialNo,
    this.financialYear,
    required this.prefix,
    required this.mothersName,
    this.babyName,
    this.branch,
    this.admissionType,
    this.admissionHistory,
    this.birthType,
    required this.doa,
    this.dod,
    this.stay,
    required this.contactNumber,
    required this.contactRelation,
    this.contactNumber2,
    this.contactRelation2,
    this.address,
    this.street,
    this.area,
    this.city = 'AHMEDABAD',
    required this.pin,
    required this.del,
    this.status,
    this.remarks,
    this.lastRemarked,
    // Discharge fields
    this.ipNo,
    this.sex,
    this.state = 'Gujarat',
    this.district,
    this.dateOfBirth,
    this.placeOfDeliveryDischarge,
    this.gestAgeWeeks,
    this.gestAgeDays,
    this.birthWeight,
    this.admissionWeight,
    this.weightPercentile,
    this.dischargeWeight,
    this.headCircumference,
    this.length,
    this.maternalMorbidities,
    this.maternalMorbiditiesOther,
    this.ans,
    this.antentalScan,
    this.antentalScanOther,
    this.modeOfDelivery,
    this.resuscitationAtBirth,
    this.respiratorySystemOther,
    this.respiratorySystem,
    this.antibiotics,
    this.cardiovascularSystem,
    this.sepsisOther,
    this.sepsis,
    this.organism,
    this.feeding,
    this.feedingOther,
    this.rtfStarted,
    this.fullFeedsReached,
    this.surfactant,
    this.ventilation,
    this.bpd,
    this.probiotics,
    this.bloodTransfusion,
    this.rop,
    this.usgHead,
    this.fileName,
    this.adductaAngle,
    this.cdcHeadControl,
    this.cdcSitting,
    this.cdcStanding,
    this.dasiiMotorAgeAt50thCentile,
    this.dasiiMotorAgeAt97thCentile,
    this.dasiiMentalAgeAt50thCentile,
    this.dasiiMentalAgeAt97thCentile,
    this.other,
    this.picc,
    this.user,
    this.statusOk = false,
    this.dischargeType,
    this.shiftedTo,
    this.shiftReason,
  });

  PatientStay copyWith({
    String? id,
    int? serialNo,
    int? financialYear,
    Prefix? prefix,
    String? mothersName,
    String? babyName,
    Branch? branch,
    AdmissionType? admissionType,
    AdmissionHistory? admissionHistory,
    BirthType? birthType,
    DateTime? doa,
    DateTime? dod,
    int? stay,
    String? contactNumber,
    Relation? contactRelation,
    String? contactNumber2,
    Relation? contactRelation2,
    String? address,
    String? street,
    String? area,
    String? city,
    String? pin,
    String? del,
    PatientStatus? status,
    String? remarks,
    String? lastRemarked,
    // Discharge fields
    String? ipNo,
    Sex? sex,
    String? state,
    String? district,
    DateTime? dateOfBirth,
    String? placeOfDeliveryDischarge,
    int? gestAgeWeeks,
    int? gestAgeDays,
    double? birthWeight,
    double? admissionWeight,
    WeightPercentile? weightPercentile,
    double? dischargeWeight,
    double? headCircumference,
    double? length,
    List<String>? maternalMorbidities,
    String? maternalMorbiditiesOther,
    ANS? ans,
    List<String>? antentalScan,
    String? antentalScanOther,
    ModeOfDelivery? modeOfDelivery,
    List<String>? resuscitationAtBirth,
    String? respiratorySystemOther,
    List<String>? respiratorySystem,
    List<String>? antibiotics,
    String? cardiovascularSystem,
    String? sepsisOther,
    String? sepsis,
    String? organism,
    List<String>? feeding,
    String? feedingOther,
    String? rtfStarted,
    String? fullFeedsReached,
    Surfactant? surfactant,
    List<String>? ventilation,
    BPD? bpd,
    bool? probiotics,
    bool? bloodTransfusion,
    ROP? rop,
    String? usgHead,
    String? fileName,
    String? adductaAngle,
    String? cdcHeadControl,
    String? cdcSitting,
    String? cdcStanding,
    String? dasiiMotorAgeAt50thCentile,
    String? dasiiMotorAgeAt97thCentile,
    String? dasiiMentalAgeAt50thCentile,
    String? dasiiMentalAgeAt97thCentile,
    String? other,
    bool? picc,
    String? user,
    bool? statusOk,
    DischargeType? dischargeType,
    String? shiftedTo,
    String? shiftReason,
  }) {
    return PatientStay(
      id: id ?? this.id,
      serialNo: serialNo ?? this.serialNo,
      financialYear: financialYear ?? this.financialYear,
      prefix: prefix ?? this.prefix,
      mothersName: mothersName ?? this.mothersName,
      babyName: babyName ?? this.babyName,
      branch: branch ?? this.branch,
      admissionType: admissionType ?? this.admissionType,
      admissionHistory: admissionHistory ?? this.admissionHistory,
      birthType: birthType ?? this.birthType,
      doa: doa ?? this.doa,
      dod: dod ?? this.dod,
      stay: stay ?? this.stay,
      contactNumber: contactNumber ?? this.contactNumber,
      contactRelation: contactRelation ?? this.contactRelation,
      contactNumber2: contactNumber2 ?? this.contactNumber2,
      contactRelation2: contactRelation2 ?? this.contactRelation2,
      address: address ?? this.address,
      street: street ?? this.street,
      area: area ?? this.area,
      city: city ?? this.city,
      pin: pin ?? this.pin,
      del: del ?? this.del,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      lastRemarked: lastRemarked ?? this.lastRemarked,
      ipNo: ipNo ?? this.ipNo,
      sex: sex ?? this.sex,
      state: state ?? this.state,
      district: district ?? this.district,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfDeliveryDischarge:
          placeOfDeliveryDischarge ?? this.placeOfDeliveryDischarge,
      gestAgeWeeks: gestAgeWeeks ?? this.gestAgeWeeks,
      gestAgeDays: gestAgeDays ?? this.gestAgeDays,
      birthWeight: birthWeight ?? this.birthWeight,
      admissionWeight: admissionWeight ?? this.admissionWeight,
      weightPercentile: weightPercentile ?? this.weightPercentile,
      dischargeWeight: dischargeWeight ?? this.dischargeWeight,
      headCircumference: headCircumference ?? this.headCircumference,
      length: length ?? this.length,
      maternalMorbidities: maternalMorbidities ?? this.maternalMorbidities,
      maternalMorbiditiesOther:
          maternalMorbiditiesOther ?? this.maternalMorbiditiesOther,
      ans: ans ?? this.ans,
      antentalScan: antentalScan ?? this.antentalScan,
      antentalScanOther: antentalScanOther ?? this.antentalScanOther,
      modeOfDelivery: modeOfDelivery ?? this.modeOfDelivery,
      resuscitationAtBirth: resuscitationAtBirth ?? this.resuscitationAtBirth,
      respiratorySystemOther:
          respiratorySystemOther ?? this.respiratorySystemOther,
      respiratorySystem: respiratorySystem ?? this.respiratorySystem,
      antibiotics: antibiotics ?? this.antibiotics,
      cardiovascularSystem: cardiovascularSystem ?? this.cardiovascularSystem,
      sepsisOther: sepsisOther ?? this.sepsisOther,
      sepsis: sepsis ?? this.sepsis,
      organism: organism ?? this.organism,
      feeding: feeding ?? this.feeding,
      feedingOther: feedingOther ?? this.feedingOther,
      rtfStarted: rtfStarted ?? this.rtfStarted,
      fullFeedsReached: fullFeedsReached ?? this.fullFeedsReached,
      surfactant: surfactant ?? this.surfactant,
      ventilation: ventilation ?? this.ventilation,
      bpd: bpd ?? this.bpd,
      probiotics: probiotics ?? this.probiotics,
      bloodTransfusion: bloodTransfusion ?? this.bloodTransfusion,
      rop: rop ?? this.rop,
      usgHead: usgHead ?? this.usgHead,
      fileName: fileName ?? this.fileName,
      adductaAngle: adductaAngle ?? this.adductaAngle,
      cdcHeadControl: cdcHeadControl ?? this.cdcHeadControl,
      cdcSitting: cdcSitting ?? this.cdcSitting,
      cdcStanding: cdcStanding ?? this.cdcStanding,
      dasiiMotorAgeAt50thCentile:
          dasiiMotorAgeAt50thCentile ?? this.dasiiMotorAgeAt50thCentile,
      dasiiMotorAgeAt97thCentile:
          dasiiMotorAgeAt97thCentile ?? this.dasiiMotorAgeAt97thCentile,
      dasiiMentalAgeAt50thCentile:
          dasiiMentalAgeAt50thCentile ?? this.dasiiMentalAgeAt50thCentile,
      dasiiMentalAgeAt97thCentile:
          dasiiMentalAgeAt97thCentile ?? this.dasiiMentalAgeAt97thCentile,
      other: other ?? this.other,
      picc: picc ?? this.picc,
      user: user ?? this.user,
      statusOk: statusOk ?? this.statusOk,
      dischargeType: dischargeType ?? this.dischargeType,
      shiftedTo: shiftedTo ?? this.shiftedTo,
      shiftReason: shiftReason ?? this.shiftReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serialNo': serialNo,
      'financialYear': financialYear,
      'prefix': prefix.name,
      'mothersName': mothersName,
      'babyName': babyName,
      'branch': branch?.name,
      'admissionType': admissionType?.name,
      'admissionHistory': admissionHistory?.name,
      'birthType': birthType?.name,
      'doa': doa.toIso8601String(),
      'dod': dod?.toIso8601String(),
      'stay': stay,
      'contactNumber': contactNumber,
      'contactRelation': contactRelation.name,
      'contactNumber2': contactNumber2,
      'contactRelation2': contactRelation2?.name,
      'address': address,
      'street': street,
      'area': area,
      'city': city,
      'pin': pin,
      'del': del,
      'status': status?.name,
      'remarks': remarks,
      'lastRemarked': lastRemarked,
      // Discharge fields
      'ipNo': ipNo,
      'sex': sex?.name,
      'state': state,
      'district': district,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'placeOfDeliveryDischarge': placeOfDeliveryDischarge,
      'gestAgeWeeks': gestAgeWeeks,
      'gestAgeDays': gestAgeDays,
      'birthWeight': birthWeight,
      'admissionWeight': admissionWeight,
      'weightPercentile': weightPercentile?.name,
      'dischargeWeight': dischargeWeight,
      'headCircumference': headCircumference,
      'length': length,
      'maternalMorbidities': maternalMorbidities,
      'maternalMorbiditiesOther': maternalMorbiditiesOther,
      'ans': ans?.name,
      'antentalScan': antentalScan,
      'antentalScanOther': antentalScanOther,
      'modeOfDelivery': modeOfDelivery?.name,
      'resuscitationAtBirth': resuscitationAtBirth,
      'respiratorySystemOther': respiratorySystemOther,
      'respiratorySystem': respiratorySystem,
      'antibiotics': antibiotics,
      'cardiovascularSystem': cardiovascularSystem,
      'sepsisOther': sepsisOther,
      'sepsis': sepsis,
      'organism': organism,
      'feeding': feeding,
      'feedingOther': feedingOther,
      'rtfStarted': rtfStarted,
      'fullFeedsReached': fullFeedsReached,
      'surfactant': surfactant?.name,
      'ventilation': ventilation,
      'bpd': bpd?.name,
      'probiotics': probiotics,
      'bloodTransfusion': bloodTransfusion,
      'rop': rop?.name,
      'usgHead': usgHead,
      'fileName': fileName,
      'adductaAngle': adductaAngle,
      'cdcHeadControl': cdcHeadControl,
      'cdcSitting': cdcSitting,
      'cdcStanding': cdcStanding,
      'dasiiMotorAgeAt50thCentile': dasiiMotorAgeAt50thCentile,
      'dasiiMotorAgeAt97thCentile': dasiiMotorAgeAt97thCentile,
      'dasiiMentalAgeAt50thCentile': dasiiMentalAgeAt50thCentile,
      'dasiiMentalAgeAt97thCentile': dasiiMentalAgeAt97thCentile,
      'other': other,
      'picc': picc,
      'user': user,
      'statusOk': statusOk,
      'dischargeType': dischargeType?.name,
      'shiftedTo': shiftedTo,
      'shiftReason': shiftReason,
    };
  }

  factory PatientStay.fromJson(Map<String, dynamic> json) {
    return PatientStay(
      id: json['id'] as String?,
      serialNo: json['serialNo'] as int?,
      financialYear:
          json['financialYear'] as int? ??
          _financialYearForDate(DateTime.parse(json['doa'] as String)),
      prefix: Prefix.values.firstWhere(
        (e) => e.name == json['prefix'],
        orElse: () => Prefix.bo,
      ),
      mothersName: json['mothersName'] as String,
      babyName: json['babyName'] as String?,
      branch: _enumValue(Branch.values, json['branch']),
      admissionType: _enumValue(AdmissionType.values, json['admissionType']),
      admissionHistory: _enumValue(
        AdmissionHistory.values,
        json['admissionHistory'],
      ),
      birthType: _enumValue(BirthType.values, json['birthType']),
      doa: DateTime.parse(json['doa'] as String),
      dod: json['dod'] != null ? DateTime.parse(json['dod'] as String) : null,
      stay: json['stay'] as int?,
      contactNumber: json['contactNumber'] as String,
      contactRelation: Relation.values.firstWhere(
        (e) => e.name == json['contactRelation'],
        orElse: () => Relation.father,
      ),
      contactNumber2: json['contactNumber2'] as String?,
      contactRelation2: json['contactRelation2'] != null
          ? Relation.values.firstWhere(
              (e) => e.name == json['contactRelation2'],
              orElse: () => Relation.father,
            )
          : null,
      address: json['address'] as String?,
      street: json['street'] as String?,
      area: json['area'] as String?,
      city: json['city'] as String? ?? 'AHMEDABAD',
      pin: json['pin'] as String,
      del: json['del'] as String,
      status: json['status'] != null
          ? PatientStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => PatientStatus.alive,
            )
          : null,
      remarks: json['remarks'] as String?,
      lastRemarked: json['lastRemarked'] as String?,
      // Discharge fields
      ipNo: json['ipNo'] as String?,
      sex: json['sex'] != null
          ? Sex.values.firstWhere(
              (e) => e.name == json['sex'],
              orElse: () => Sex.male,
            )
          : null,
      state: json['state'] as String? ?? 'Gujarat',
      district: json['district'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      placeOfDeliveryDischarge: json['placeOfDeliveryDischarge'] as String?,
      gestAgeWeeks: json['gestAgeWeeks'] as int?,
      gestAgeDays: json['gestAgeDays'] as int?,
      birthWeight: (json['birthWeight'] as num?)?.toDouble(),
      admissionWeight: (json['admissionWeight'] as num?)?.toDouble(),
      weightPercentile: json['weightPercentile'] != null
          ? WeightPercentile.values.firstWhere(
              (e) => e.name == json['weightPercentile'],
              orElse: () => WeightPercentile.afd,
            )
          : null,
      dischargeWeight: (json['dischargeWeight'] as num?)?.toDouble(),
      headCircumference: (json['headCircumference'] as num?)?.toDouble(),
      length: (json['length'] as num?)?.toDouble(),
      maternalMorbidities: (json['maternalMorbidities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maternalMorbiditiesOther: json['maternalMorbiditiesOther'] as String?,
      ans: json['ans'] != null
          ? ANS.values.firstWhere(
              (e) => e.name == json['ans'],
              orElse: () => ANS.no,
            )
          : null,
      antentalScan: (json['antentalScan'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      antentalScanOther: json['antentalScanOther'] as String?,
      modeOfDelivery: json['modeOfDelivery'] != null
          ? ModeOfDelivery.values.firstWhere(
              (e) => e.name == json['modeOfDelivery'],
              orElse: () => ModeOfDelivery.vaginal,
            )
          : null,
      resuscitationAtBirth: (json['resuscitationAtBirth'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      respiratorySystemOther: json['respiratorySystemOther'] as String?,
      respiratorySystem: (json['respiratorySystem'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      antibiotics: (json['antibiotics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      cardiovascularSystem: json['cardiovascularSystem'] as String?,
      sepsisOther: json['sepsisOther'] as String?,
      sepsis: json['sepsis'] as String?,
      organism: json['organism'] as String?,
      feeding: (json['feeding'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      feedingOther: json['feedingOther'] as String?,
      rtfStarted: json['rtfStarted'] as String?,
      fullFeedsReached: json['fullFeedsReached'] as String?,
      surfactant: json['surfactant'] != null
          ? Surfactant.values.firstWhere(
              (e) => e.name == json['surfactant'],
              orElse: () => Surfactant.no,
            )
          : null,
      ventilation: (json['ventilation'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      bpd: json['bpd'] != null
          ? BPD.values.firstWhere(
              (e) => e.name == json['bpd'],
              orElse: () => BPD.no,
            )
          : null,
      probiotics: json['probiotics'] as bool?,
      bloodTransfusion: json['bloodTransfusion'] as bool?,
      rop: json['rop'] != null
          ? ROP.values.firstWhere(
              (e) => e.name == json['rop'],
              orElse: () => ROP.no,
            )
          : null,
      usgHead: json['usgHead'] as String?,
      fileName: json['fileName'] as String?,
      adductaAngle: json['adductaAngle'] as String?,
      cdcHeadControl: json['cdcHeadControl'] as String?,
      cdcSitting: json['cdcSitting'] as String?,
      cdcStanding: json['cdcStanding'] as String?,
      dasiiMotorAgeAt50thCentile: json['dasiiMotorAgeAt50thCentile'] as String?,
      dasiiMotorAgeAt97thCentile: json['dasiiMotorAgeAt97thCentile'] as String?,
      dasiiMentalAgeAt50thCentile:
          json['dasiiMentalAgeAt50thCentile'] as String?,
      dasiiMentalAgeAt97thCentile:
          json['dasiiMentalAgeAt97thCentile'] as String?,
      other: json['other'] as String?,
      picc: json['picc'] as bool?,
      user: json['user'] as String?,
      statusOk: json['statusOk'] as bool? ?? false,
      dischargeType: _enumValue(DischargeType.values, json['dischargeType']),
      shiftedTo: json['shiftedTo'] as String?,
      shiftReason: json['shiftReason'] as String?,
    );
  }
}

T? _enumValue<T extends Enum>(Iterable<T> values, Object? value) {
  for (final item in values) {
    if (item.name == value) return item;
  }
  return null;
}

int _financialYearForDate(DateTime date) =>
    date.month >= 4 ? date.year : date.year - 1;
