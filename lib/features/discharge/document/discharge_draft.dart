import '../../admissions/models/patient_stay.dart';

class DischargeDraft {
  final DateTime? dischargeDate;
  final String? dischargeTime;
  final DischargeType dischargeType;
  final String conditionAtDischarge;
  final String finalDiagnosis;
  final String ipNo;
  final String? stay; // Length of stay (days)

  // Anthropometry & Vitals
  final String weightAtDischarge;
  final String birthWeight;
  final String admissionWeight;
  final String headCircumference;
  final String length;
  final String gestAgeWeeks;
  final String gestAgeDays;
  final WeightPercentile? weightPercentile;
  final Sex? sex;
  final String? state;
  final String? district;
  final DateTime? dateOfBirth;
  final String? placeOfDeliveryDischarge;
  final ModeOfDelivery? modeOfDelivery;
  final ANS? ans;

  // Shift fields (for DischargeType.shift)
  final String shiftedTo;
  final String shiftReason;

  // Clinical Details & Interventions
  final List<String> maternalMorbidities;
  final String maternalMorbiditiesOther;
  final List<String> antentalScan;
  final String antentalScanOther;
  final List<String> respiratorySystem;
  final String respiratorySystemOther;
  final Surfactant? surfactant;
  final List<String> ventilation;
  final BPD? bpd;
  final String cardiovascularSystem;
  final String sepsis;
  final String sepsisOther;
  final String organism;
  final List<String> antibiotics;
  final List<String> feeding;
  final String feedingOther;
  final String rtfStarted;
  final String fullFeedsReached;
  final bool? probiotics;
  final bool? bloodTransfusion;
  final bool? picc;
  final ROP? rop;
  final String usgHead;

  // Developmental Assessments
  final String? adductaAngle;
  final String? cdcHeadControl;
  final String? cdcSitting;
  final String? cdcStanding;
  final String dasiiMotor50;
  final String dasiiMotor97;
  final String dasiiMental50;
  final String dasiiMental97;

  // Treatment, Advice & Follow-up
  final String treatmentSummary;
  final String adviceOnDischarge;
  final String followUpDate;
  final String attendingDoctor;
  final String remarks;
  final String other;
  final String user;

  const DischargeDraft({
    this.dischargeDate,
    this.dischargeTime,
    this.dischargeType = DischargeType.routine,
    this.conditionAtDischarge = '',
    this.finalDiagnosis = '',
    this.ipNo = '',
    this.stay,
    this.weightAtDischarge = '',
    this.birthWeight = '',
    this.admissionWeight = '',
    this.headCircumference = '',
    this.length = '',
    this.gestAgeWeeks = '',
    this.gestAgeDays = '',
    this.weightPercentile,
    this.sex,
    this.state,
    this.district,
    this.dateOfBirth,
    this.placeOfDeliveryDischarge,
    this.modeOfDelivery,
    this.ans,
    this.shiftedTo = '',
    this.shiftReason = '',
    this.maternalMorbidities = const [],
    this.maternalMorbiditiesOther = '',
    this.antentalScan = const [],
    this.antentalScanOther = '',
    this.respiratorySystem = const [],
    this.respiratorySystemOther = '',
    this.surfactant,
    this.ventilation = const [],
    this.bpd,
    this.cardiovascularSystem = '',
    this.sepsis = 'No Sepsis',
    this.sepsisOther = '',
    this.organism = '',
    this.antibiotics = const [],
    this.feeding = const [],
    this.feedingOther = '',
    this.rtfStarted = '',
    this.fullFeedsReached = '',
    this.probiotics,
    this.bloodTransfusion,
    this.picc,
    this.rop,
    this.usgHead = '',
    this.adductaAngle,
    this.cdcHeadControl,
    this.cdcSitting,
    this.cdcStanding,
    this.dasiiMotor50 = '',
    this.dasiiMotor97 = '',
    this.dasiiMental50 = '',
    this.dasiiMental97 = '',
    this.treatmentSummary = '',
    this.adviceOnDischarge = '',
    this.followUpDate = '',
    this.attendingDoctor = '',
    this.remarks = '',
    this.other = '',
    this.user = '',
  });

  DischargeDraft copyWith({
    DateTime? dischargeDate,
    String? dischargeTime,
    DischargeType? dischargeType,
    String? conditionAtDischarge,
    String? finalDiagnosis,
    String? ipNo,
    String? stay,
    String? weightAtDischarge,
    String? birthWeight,
    String? admissionWeight,
    String? headCircumference,
    String? length,
    String? gestAgeWeeks,
    String? gestAgeDays,
    WeightPercentile? weightPercentile,
    Sex? sex,
    String? state,
    String? district,
    DateTime? dateOfBirth,
    String? placeOfDeliveryDischarge,
    ModeOfDelivery? modeOfDelivery,
    ANS? ans,
    String? shiftedTo,
    String? shiftReason,
    List<String>? maternalMorbidities,
    String? maternalMorbiditiesOther,
    List<String>? antentalScan,
    String? antentalScanOther,
    List<String>? respiratorySystem,
    String? respiratorySystemOther,
    Surfactant? surfactant,
    List<String>? ventilation,
    BPD? bpd,
    String? cardiovascularSystem,
    String? sepsis,
    String? sepsisOther,
    String? organism,
    List<String>? antibiotics,
    List<String>? feeding,
    String? feedingOther,
    String? rtfStarted,
    String? fullFeedsReached,
    bool? probiotics,
    bool? bloodTransfusion,
    bool? picc,
    ROP? rop,
    String? usgHead,
    String? adductaAngle,
    String? cdcHeadControl,
    String? cdcSitting,
    String? cdcStanding,
    String? dasiiMotor50,
    String? dasiiMotor97,
    String? dasiiMental50,
    String? dasiiMental97,
    String? treatmentSummary,
    String? adviceOnDischarge,
    String? followUpDate,
    String? attendingDoctor,
    String? remarks,
    String? other,
    String? user,
  }) {
    return DischargeDraft(
      dischargeDate: dischargeDate ?? this.dischargeDate,
      dischargeTime: dischargeTime ?? this.dischargeTime,
      dischargeType: dischargeType ?? this.dischargeType,
      conditionAtDischarge: conditionAtDischarge ?? this.conditionAtDischarge,
      finalDiagnosis: finalDiagnosis ?? this.finalDiagnosis,
      ipNo: ipNo ?? this.ipNo,
      stay: stay ?? this.stay,
      weightAtDischarge: weightAtDischarge ?? this.weightAtDischarge,
      birthWeight: birthWeight ?? this.birthWeight,
      admissionWeight: admissionWeight ?? this.admissionWeight,
      headCircumference: headCircumference ?? this.headCircumference,
      length: length ?? this.length,
      gestAgeWeeks: gestAgeWeeks ?? this.gestAgeWeeks,
      gestAgeDays: gestAgeDays ?? this.gestAgeDays,
      weightPercentile: weightPercentile ?? this.weightPercentile,
      sex: sex ?? this.sex,
      state: state ?? this.state,
      district: district ?? this.district,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfDeliveryDischarge:
          placeOfDeliveryDischarge ?? this.placeOfDeliveryDischarge,
      modeOfDelivery: modeOfDelivery ?? this.modeOfDelivery,
      ans: ans ?? this.ans,
      shiftedTo: shiftedTo ?? this.shiftedTo,
      shiftReason: shiftReason ?? this.shiftReason,
      maternalMorbidities: maternalMorbidities ?? this.maternalMorbidities,
      maternalMorbiditiesOther:
          maternalMorbiditiesOther ?? this.maternalMorbiditiesOther,
      antentalScan: antentalScan ?? this.antentalScan,
      antentalScanOther: antentalScanOther ?? this.antentalScanOther,
      respiratorySystem: respiratorySystem ?? this.respiratorySystem,
      respiratorySystemOther:
          respiratorySystemOther ?? this.respiratorySystemOther,
      surfactant: surfactant ?? this.surfactant,
      ventilation: ventilation ?? this.ventilation,
      bpd: bpd ?? this.bpd,
      cardiovascularSystem: cardiovascularSystem ?? this.cardiovascularSystem,
      sepsis: sepsis ?? this.sepsis,
      sepsisOther: sepsisOther ?? this.sepsisOther,
      organism: organism ?? this.organism,
      antibiotics: antibiotics ?? this.antibiotics,
      feeding: feeding ?? this.feeding,
      feedingOther: feedingOther ?? this.feedingOther,
      rtfStarted: rtfStarted ?? this.rtfStarted,
      fullFeedsReached: fullFeedsReached ?? this.fullFeedsReached,
      probiotics: probiotics ?? this.probiotics,
      bloodTransfusion: bloodTransfusion ?? this.bloodTransfusion,
      picc: picc ?? this.picc,
      rop: rop ?? this.rop,
      usgHead: usgHead ?? this.usgHead,
      adductaAngle: adductaAngle ?? this.adductaAngle,
      cdcHeadControl: cdcHeadControl ?? this.cdcHeadControl,
      cdcSitting: cdcSitting ?? this.cdcSitting,
      cdcStanding: cdcStanding ?? this.cdcStanding,
      dasiiMotor50: dasiiMotor50 ?? this.dasiiMotor50,
      dasiiMotor97: dasiiMotor97 ?? this.dasiiMotor97,
      dasiiMental50: dasiiMental50 ?? this.dasiiMental50,
      dasiiMental97: dasiiMental97 ?? this.dasiiMental97,
      treatmentSummary: treatmentSummary ?? this.treatmentSummary,
      adviceOnDischarge: adviceOnDischarge ?? this.adviceOnDischarge,
      followUpDate: followUpDate ?? this.followUpDate,
      attendingDoctor: attendingDoctor ?? this.attendingDoctor,
      remarks: remarks ?? this.remarks,
      other: other ?? this.other,
      user: user ?? this.user,
    );
  }

  factory DischargeDraft.fromPatient(PatientStay patient) {
    return DischargeDraft(
      dischargeDate: patient.dod,
      dischargeType: patient.dischargeType ?? DischargeType.routine,
      conditionAtDischarge: patient.status == PatientStatus.expire ? 'Expired' : 'Stable',
      finalDiagnosis: patient.sepsis ?? '',
      ipNo: patient.ipNo ?? '',
      stay: patient.stay?.toString(),
      weightAtDischarge: patient.dischargeWeight?.toString() ?? '',
      birthWeight: patient.birthWeight?.toString() ?? '',
      admissionWeight: patient.admissionWeight?.toString() ?? '',
      headCircumference: patient.headCircumference?.toString() ?? '',
      length: patient.length?.toString() ?? '',
      gestAgeWeeks: patient.gestAgeWeeks?.toString() ?? '',
      gestAgeDays: patient.gestAgeDays?.toString() ?? '',
      weightPercentile: patient.weightPercentile,
      sex: patient.sex,
      state: patient.state,
      district: patient.district,
      dateOfBirth: patient.dateOfBirth,
      placeOfDeliveryDischarge: patient.placeOfDeliveryDischarge,
      modeOfDelivery: patient.modeOfDelivery,
      ans: patient.ans,
      shiftedTo: patient.shiftedTo ?? '',
      shiftReason: patient.shiftReason ?? '',
      maternalMorbidities: patient.maternalMorbidities ?? const [],
      maternalMorbiditiesOther: patient.maternalMorbiditiesOther ?? '',
      antentalScan: patient.antentalScan ?? const [],
      antentalScanOther: patient.antentalScanOther ?? '',
      respiratorySystem: patient.respiratorySystem ?? const [],
      respiratorySystemOther: patient.respiratorySystemOther ?? '',
      surfactant: patient.surfactant,
      ventilation: patient.ventilation ?? const [],
      bpd: patient.bpd,
      cardiovascularSystem: patient.cardiovascularSystem ?? '',
      sepsis: patient.sepsis ?? 'No Sepsis',
      sepsisOther: patient.sepsisOther ?? '',
      organism: patient.organism ?? '',
      antibiotics: patient.antibiotics ?? const [],
      feeding: patient.feeding ?? const [],
      feedingOther: patient.feedingOther ?? '',
      rtfStarted: patient.rtfStarted ?? '',
      fullFeedsReached: patient.fullFeedsReached ?? '',
      probiotics: patient.probiotics,
      bloodTransfusion: patient.bloodTransfusion,
      picc: patient.picc,
      rop: patient.rop,
      usgHead: patient.usgHead ?? '',
      adductaAngle: patient.adductaAngle,
      cdcHeadControl: patient.cdcHeadControl,
      cdcSitting: patient.cdcSitting,
      cdcStanding: patient.cdcStanding,
      dasiiMotor50: patient.dasiiMotorAgeAt50thCentile ?? '',
      dasiiMotor97: patient.dasiiMotorAgeAt97thCentile ?? '',
      dasiiMental50: patient.dasiiMentalAgeAt50thCentile ?? '',
      dasiiMental97: patient.dasiiMentalAgeAt97thCentile ?? '',
      treatmentSummary: '',
      adviceOnDischarge: '',
      followUpDate: '',
      attendingDoctor: patient.user ?? '',
      remarks: patient.remarks ?? '',
      other: patient.other ?? '',
      user: patient.user ?? '',
    );
  }

  Map<String, dynamic> toDischargeData(PatientStay existing) {
    final dod = dischargeDate ?? DateTime.now();
    final stayDays = int.tryParse(stay ?? '') ??
        dod.difference(existing.doa).inDays;

    return {
      'dod': dod,
      'stay': stayDays,
      'dischargeType': dischargeType,
      'ipNo': ipNo.isNotEmpty ? ipNo : null,
      'sex': sex,
      'state': state,
      'district': district,
      'dateOfBirth': dateOfBirth,
      'placeOfDeliveryDischarge': placeOfDeliveryDischarge,
      'gestAgeWeeks': int.tryParse(gestAgeWeeks),
      'gestAgeDays': int.tryParse(gestAgeDays),
      'birthWeight': double.tryParse(birthWeight),
      'admissionWeight': double.tryParse(admissionWeight),
      'weightPercentile': weightPercentile,
      'dischargeWeight': double.tryParse(weightAtDischarge),
      'headCircumference': double.tryParse(headCircumference),
      'length': double.tryParse(length),
      'shiftedTo': dischargeType == DischargeType.shift ? shiftedTo : null,
      'shiftReason': dischargeType == DischargeType.shift ? shiftReason : null,
      'maternalMorbidities': maternalMorbidities.isNotEmpty ? maternalMorbidities : null,
      'maternalMorbiditiesOther': maternalMorbiditiesOther.isNotEmpty ? maternalMorbiditiesOther : null,
      'ans': ans,
      'antentalScan': antentalScan.isNotEmpty ? antentalScan : null,
      'antentalScanOther': antentalScanOther.isNotEmpty ? antentalScanOther : null,
      'modeOfDelivery': modeOfDelivery,
      'respiratorySystem': respiratorySystem.isNotEmpty ? respiratorySystem : null,
      'respiratorySystemOther': respiratorySystemOther.isNotEmpty ? respiratorySystemOther : null,
      'antibiotics': antibiotics.isNotEmpty ? antibiotics : null,
      'cardiovascularSystem': cardiovascularSystem.isNotEmpty ? cardiovascularSystem : null,
      'sepsis': sepsis,
      'sepsisOther': sepsisOther.isNotEmpty ? sepsisOther : null,
      'organism': organism.isNotEmpty ? organism : null,
      'feeding': feeding.isNotEmpty ? feeding : null,
      'feedingOther': feedingOther.isNotEmpty ? feedingOther : null,
      'rtfStarted': rtfStarted.isNotEmpty ? rtfStarted : null,
      'fullFeedsReached': fullFeedsReached.isNotEmpty ? fullFeedsReached : null,
      'surfactant': surfactant,
      'ventilation': ventilation.isNotEmpty ? ventilation : null,
      'bpd': bpd,
      'probiotics': probiotics,
      'bloodTransfusion': bloodTransfusion,
      'rop': rop,
      'usgHead': usgHead.isNotEmpty ? usgHead : null,
      'picc': picc,
      'adductaAngle': adductaAngle,
      'cdcHeadControl': cdcHeadControl,
      'cdcSitting': cdcSitting,
      'cdcStanding': cdcStanding,
      'dasiiMotorAgeAt50thCentile': dasiiMotor50.isNotEmpty ? dasiiMotor50 : null,
      'dasiiMotorAgeAt97thCentile': dasiiMotor97.isNotEmpty ? dasiiMotor97 : null,
      'dasiiMentalAgeAt50thCentile': dasiiMental50.isNotEmpty ? dasiiMental50 : null,
      'dasiiMentalAgeAt97thCentile': dasiiMental97.isNotEmpty ? dasiiMental97 : null,
      'remarks': remarks.isNotEmpty ? remarks : null,
      'other': other.isNotEmpty ? other : null,
      'user': user.isNotEmpty ? user : null,
      'statusOk': true,
    };
  }
}
