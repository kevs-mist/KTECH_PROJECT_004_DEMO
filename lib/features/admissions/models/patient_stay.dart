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

const Object _unset = Object();

T? _resolve<T>(Object? value, T? current) =>
    identical(value, _unset) ? current : value as T?;

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
  final List<String>? antenatalScan; // Multi-select
  final String? antenatalScanOther; // Other text
  final ModeOfDelivery? modeOfDelivery;
  final List<String>? resuscitationAtBirth; // Multi-select
  final String? respiratorySystemOther; // Other text
  final List<String>? respiratorySystem; // Multi-select
  final List<String>? antibiotics;
  final bool? maternalReceivedAntibiotics;
  final List<String>? maternalAntibiotics;
  final String? maternalAntibioticsOther;
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
    this.antenatalScan,
    this.antenatalScanOther,
    this.modeOfDelivery,
    this.resuscitationAtBirth,
    this.respiratorySystemOther,
    this.respiratorySystem,
    this.antibiotics,
    this.maternalReceivedAntibiotics,
    this.maternalAntibiotics,
    this.maternalAntibioticsOther,
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
    Object? id = _unset,
    Object? serialNo = _unset,
    Object? financialYear = _unset,
    Prefix? prefix,
    String? mothersName,
    Object? babyName = _unset,
    Object? branch = _unset,
    Object? admissionType = _unset,
    Object? admissionHistory = _unset,
    Object? birthType = _unset,
    DateTime? doa,
    Object? dod = _unset,
    Object? stay = _unset,
    String? contactNumber,
    Relation? contactRelation,
    Object? contactNumber2 = _unset,
    Object? contactRelation2 = _unset,
    Object? address = _unset,
    Object? street = _unset,
    Object? area = _unset,
    String? city,
    String? pin,
    String? del,
    Object? status = _unset,
    Object? remarks = _unset,
    Object? lastRemarked = _unset,
    // Discharge fields
    Object? ipNo = _unset,
    Object? sex = _unset,
    Object? state = _unset,
    Object? district = _unset,
    Object? dateOfBirth = _unset,
    Object? placeOfDeliveryDischarge = _unset,
    Object? gestAgeWeeks = _unset,
    Object? gestAgeDays = _unset,
    Object? birthWeight = _unset,
    Object? admissionWeight = _unset,
    Object? weightPercentile = _unset,
    Object? dischargeWeight = _unset,
    Object? headCircumference = _unset,
    Object? length = _unset,
    Object? maternalMorbidities = _unset,
    Object? maternalMorbiditiesOther = _unset,
    Object? ans = _unset,
    Object? antenatalScan = _unset,
    Object? antenatalScanOther = _unset,
    Object? modeOfDelivery = _unset,
    Object? resuscitationAtBirth = _unset,
    Object? respiratorySystemOther = _unset,
    Object? respiratorySystem = _unset,
    Object? antibiotics = _unset,
    Object? maternalReceivedAntibiotics = _unset,
    Object? maternalAntibiotics = _unset,
    Object? maternalAntibioticsOther = _unset,
    Object? cardiovascularSystem = _unset,
    Object? sepsisOther = _unset,
    Object? sepsis = _unset,
    Object? organism = _unset,
    Object? feeding = _unset,
    Object? feedingOther = _unset,
    Object? rtfStarted = _unset,
    Object? fullFeedsReached = _unset,
    Object? surfactant = _unset,
    Object? ventilation = _unset,
    Object? bpd = _unset,
    Object? probiotics = _unset,
    Object? bloodTransfusion = _unset,
    bool clearBloodTransfusion = false,
    Object? rop = _unset,
    Object? usgHead = _unset,
    Object? fileName = _unset,
    Object? adductaAngle = _unset,
    Object? cdcHeadControl = _unset,
    Object? cdcSitting = _unset,
    Object? cdcStanding = _unset,
    Object? dasiiMotorAgeAt50thCentile = _unset,
    Object? dasiiMotorAgeAt97thCentile = _unset,
    Object? dasiiMentalAgeAt50thCentile = _unset,
    Object? dasiiMentalAgeAt97thCentile = _unset,
    Object? other = _unset,
    Object? picc = _unset,
    Object? user = _unset,
    bool? statusOk,
    Object? dischargeType = _unset,
    Object? shiftedTo = _unset,
    Object? shiftReason = _unset,
  }) {
    return PatientStay(
      id: _resolve(id, this.id),
      serialNo: _resolve(serialNo, this.serialNo),
      financialYear: _resolve(financialYear, this.financialYear),
      prefix: prefix ?? this.prefix,
      mothersName: mothersName ?? this.mothersName,
      babyName: _resolve(babyName, this.babyName),
      branch: _resolve(branch, this.branch),
      admissionType: _resolve(admissionType, this.admissionType),
      admissionHistory: _resolve(admissionHistory, this.admissionHistory),
      birthType: _resolve(birthType, this.birthType),
      doa: doa ?? this.doa,
      dod: _resolve(dod, this.dod),
      stay: _resolve(stay, this.stay),
      contactNumber: contactNumber ?? this.contactNumber,
      contactRelation: contactRelation ?? this.contactRelation,
      contactNumber2: _resolve(contactNumber2, this.contactNumber2),
      contactRelation2: _resolve(contactRelation2, this.contactRelation2),
      address: _resolve(address, this.address),
      street: _resolve(street, this.street),
      area: _resolve(area, this.area),
      city: city ?? this.city,
      pin: pin ?? this.pin,
      del: del ?? this.del,
      status: _resolve(status, this.status),
      remarks: _resolve(remarks, this.remarks),
      lastRemarked: _resolve(lastRemarked, this.lastRemarked),
      ipNo: _resolve(ipNo, this.ipNo),
      sex: _resolve(sex, this.sex),
      state: _resolve(state, this.state),
      district: _resolve(district, this.district),
      dateOfBirth: _resolve(dateOfBirth, this.dateOfBirth),
      placeOfDeliveryDischarge:
          _resolve(placeOfDeliveryDischarge, this.placeOfDeliveryDischarge),
      gestAgeWeeks: _resolve(gestAgeWeeks, this.gestAgeWeeks),
      gestAgeDays: _resolve(gestAgeDays, this.gestAgeDays),
      birthWeight: _resolve(birthWeight, this.birthWeight),
      admissionWeight: _resolve(admissionWeight, this.admissionWeight),
      weightPercentile: _resolve(weightPercentile, this.weightPercentile),
      dischargeWeight: _resolve(dischargeWeight, this.dischargeWeight),
      headCircumference: _resolve(headCircumference, this.headCircumference),
      length: _resolve(length, this.length),
      maternalMorbidities: _resolve(maternalMorbidities, this.maternalMorbidities),
      maternalMorbiditiesOther:
          _resolve(maternalMorbiditiesOther, this.maternalMorbiditiesOther),
      ans: _resolve(ans, this.ans),
      antenatalScan: _resolve(antenatalScan, this.antenatalScan),
      antenatalScanOther: _resolve(antenatalScanOther, this.antenatalScanOther),
      modeOfDelivery: _resolve(modeOfDelivery, this.modeOfDelivery),
      resuscitationAtBirth: _resolve(resuscitationAtBirth, this.resuscitationAtBirth),
      respiratorySystemOther:
          _resolve(respiratorySystemOther, this.respiratorySystemOther),
      respiratorySystem: _resolve(respiratorySystem, this.respiratorySystem),
      antibiotics: _resolve(antibiotics, this.antibiotics),
      maternalReceivedAntibiotics:
          _resolve(maternalReceivedAntibiotics, this.maternalReceivedAntibiotics),
      maternalAntibiotics: _resolve(maternalAntibiotics, this.maternalAntibiotics),
      maternalAntibioticsOther:
          _resolve(maternalAntibioticsOther, this.maternalAntibioticsOther),
      cardiovascularSystem: _resolve(cardiovascularSystem, this.cardiovascularSystem),
      sepsisOther: _resolve(sepsisOther, this.sepsisOther),
      sepsis: _resolve(sepsis, this.sepsis),
      organism: _resolve(organism, this.organism),
      feeding: _resolve(feeding, this.feeding),
      feedingOther: _resolve(feedingOther, this.feedingOther),
      rtfStarted: _resolve(rtfStarted, this.rtfStarted),
      fullFeedsReached: _resolve(fullFeedsReached, this.fullFeedsReached),
      surfactant: _resolve(surfactant, this.surfactant),
      ventilation: _resolve(ventilation, this.ventilation),
      bpd: _resolve(bpd, this.bpd),
      probiotics: _resolve(probiotics, this.probiotics),
      bloodTransfusion: clearBloodTransfusion
          ? null
          : (_resolve(bloodTransfusion, this.bloodTransfusion)),
      rop: _resolve(rop, this.rop),
      usgHead: _resolve(usgHead, this.usgHead),
      fileName: _resolve(fileName, this.fileName),
      adductaAngle: _resolve(adductaAngle, this.adductaAngle),
      cdcHeadControl: _resolve(cdcHeadControl, this.cdcHeadControl),
      cdcSitting: _resolve(cdcSitting, this.cdcSitting),
      cdcStanding: _resolve(cdcStanding, this.cdcStanding),
      dasiiMotorAgeAt50thCentile:
          _resolve(dasiiMotorAgeAt50thCentile, this.dasiiMotorAgeAt50thCentile),
      dasiiMotorAgeAt97thCentile:
          _resolve(dasiiMotorAgeAt97thCentile, this.dasiiMotorAgeAt97thCentile),
      dasiiMentalAgeAt50thCentile:
          _resolve(dasiiMentalAgeAt50thCentile, this.dasiiMentalAgeAt50thCentile),
      dasiiMentalAgeAt97thCentile:
          _resolve(dasiiMentalAgeAt97thCentile, this.dasiiMentalAgeAt97thCentile),
      other: _resolve(other, this.other),
      picc: _resolve(picc, this.picc),
      user: _resolve(user, this.user),
      statusOk: statusOk ?? this.statusOk,
      dischargeType: _resolve(dischargeType, this.dischargeType),
      shiftedTo: _resolve(shiftedTo, this.shiftedTo),
      shiftReason: _resolve(shiftReason, this.shiftReason),
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
      'antenatalScan': antenatalScan,
      'antenatalScanOther': antenatalScanOther,
      'modeOfDelivery': modeOfDelivery?.name,
      'resuscitationAtBirth': resuscitationAtBirth,
      'respiratorySystemOther': respiratorySystemOther,
      'respiratorySystem': respiratorySystem,
      'antibiotics': antibiotics,
      'maternalReceivedAntibiotics': maternalReceivedAntibiotics,
      'maternalAntibiotics': maternalAntibiotics,
      'maternalAntibioticsOther': maternalAntibioticsOther,
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
      antenatalScan:
          ((json['antenatalScan'] ?? json['antentalScan']) as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      antenatalScanOther:
          (json['antenatalScanOther'] ?? json['antentalScanOther'])
              as String?,
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
      maternalReceivedAntibiotics: json['maternalReceivedAntibiotics'] as bool?,
      maternalAntibiotics: (json['maternalAntibiotics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maternalAntibioticsOther: json['maternalAntibioticsOther'] as String?,
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
