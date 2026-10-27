import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/aggregation.dart';
import '../../data/providers/demo_providers.dart';
import '../../features/admissions/models/patient_stay.dart';
import '../../widgets/clinical_workspace.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailScreen> createState() =>
      _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  PatientStay? _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patient = await ref
          .read(admissionsRepositoryProvider)
          .getPatientById(widget.patientId);
      setState(() {
        _patient = patient;
      });
    } catch (e) {
      setState(() {
        _patient = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClinicalWorkspace(
      title: 'Patient Details',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patient == null
          ? _buildErrorState()
          : _buildPatientDetail(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: AppTheme.space16),
          Text(
            'Patient not found',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.space16),
          ElevatedButton.icon(
            onPressed: _loadPatient,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetail() {
    final patient = _patient!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientHeader(patient),
          const SizedBox(height: AppTheme.space24),
          _buildSection(
            title: 'Admission Details',
            child: _buildAdmissionDetails(patient),
          ),
          if (patient.dod != null) ...[
            const SizedBox(height: AppTheme.space24),
            _buildSection(
              title: 'Discharge Details',
              child: _buildDischargeDetails(patient),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientHeader(PatientStay patient) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.displayName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppTheme.space8),
                    _PrefixChip(prefix: patient.prefix),
                  ],
                ),
              ),
              _StatusChip(status: patient.dischargeStatus),
            ],
          ),
          const SizedBox(height: AppTheme.space16),
          _DetailRow(
            label: 'Serial No',
            value: patient.serialNo?.toString() ?? 'N/A',
          ),
          _DetailRow(
            label: 'Date of Admission',
            value: formatDate(patient.doa),
          ),
          if (patient.dod != null)
            _DetailRow(
              label: 'Date of Discharge',
              value: formatDate(patient.dod!),
            ),
          _DetailRow(label: 'Days Stayed', value: patient.daysStayedText),
        ],
      ),
    );
  }

  Widget _buildAdmissionDetails(PatientStay patient) {
    return Column(
      children: [
        if (patient.branch != null)
          _DetailRow(
            label: 'Branch',
            value: patient.branch == Branch.arpanMother
                ? 'Arpan Mother'
                : 'Arpan Violet',
          ),
        if (patient.admissionType != null)
          _DetailRow(
            label: 'Type of Admission',
            value: patient.admissionType == AdmissionType.inborn
                ? 'Inborn'
                : 'Outborn',
          ),
        if (patient.admissionHistory != null)
          _DetailRow(
            label: 'First or Readmission',
            value: patient.admissionHistory == AdmissionHistory.firstAdmission
                ? 'First Admission'
                : 'Re Admission',
          ),
        if (patient.birthType != null)
          _DetailRow(
            label: 'Birth Type',
            value: switch (patient.birthType!) {
              BirthType.single => 'Single',
              BirthType.twin => 'Twin',
              BirthType.triplet => 'Triplet',
            },
          ),
        _DetailRow(label: 'Mother\'s Name', value: patient.mothersName),
        _DetailRow(
          label: 'Contact Number',
          value:
              '${patient.contactNumber} (${_relationToString(patient.contactRelation)})',
        ),
        if (patient.contactNumber2 != null)
          _DetailRow(
            label: 'Contact Number 2',
            value:
                '${patient.contactNumber2} (${_relationToString(patient.contactRelation2 ?? Relation.father)})',
          ),
        if (patient.address != null)
          _DetailRow(label: 'Address', value: patient.address!),
        if (patient.street != null)
          _DetailRow(label: 'Street', value: patient.street!),
        if (patient.area != null)
          _DetailRow(label: 'Area', value: patient.area!),
        _DetailRow(label: 'City', value: patient.city),
        _DetailRow(label: 'PIN', value: patient.pin),
        _DetailRow(label: 'Place of Delivery', value: patient.del),
        if (patient.status != null)
          _DetailRow(
            label: 'Status',
            value: patient.status == PatientStatus.alive ? 'Alive' : 'Expired',
          ),
      ],
    );
  }

  Widget _buildDischargeDetails(PatientStay patient) {
    return Column(
      children: [
        if (patient.ipNo != null)
          _DetailRow(label: 'IP No', value: patient.ipNo!),
        if (patient.dischargeType != null)
          _DetailRow(
            label: 'Discharge Type',
            value: switch (patient.dischargeType!) {
              DischargeType.routine => 'Routine',
              DischargeType.expired => 'Expired',
              DischargeType.shift => 'Shift',
            },
          ),
        if (patient.shiftedTo != null)
          _DetailRow(label: 'Shifted To', value: patient.shiftedTo!),
        if (patient.shiftReason != null)
          _DetailRow(label: 'Reason for Shift', value: patient.shiftReason!),
        if (patient.sex != null)
          _DetailRow(
            label: 'Sex',
            value: patient.sex == Sex.male ? 'Male' : 'Female',
          ),
        if (patient.state != null)
          _DetailRow(label: 'State', value: patient.state!),
        if (patient.district != null)
          _DetailRow(label: 'District', value: patient.district!),
        if (patient.dateOfBirth != null)
          _DetailRow(
            label: 'Date of Birth',
            value: formatDate(patient.dateOfBirth!),
          ),
        if (patient.placeOfDeliveryDischarge != null)
          _DetailRow(
            label: 'Place of Delivery',
            value: patient.placeOfDeliveryDischarge!,
          ),
        if (patient.gestAgeWeeks != null)
          _DetailRow(
            label: 'Gestational Age',
            value:
                '${patient.gestAgeWeeks} weeks ${patient.gestAgeDays ?? 0} days',
          ),
        if (patient.birthWeight != null)
          _DetailRow(
            label: 'Birth Weight',
            value: '${patient.birthWeight!.toStringAsFixed(3)} kg',
          ),
        if (patient.admissionWeight != null)
          _DetailRow(
            label: 'Admission Weight',
            value: '${patient.admissionWeight!.toStringAsFixed(3)} kg',
          ),
        if (patient.weightPercentile != null)
          _DetailRow(
            label: 'Weight Percentile',
            value: _weightPercentileToString(patient.weightPercentile!),
          ),
        if (patient.dischargeWeight != null)
          _DetailRow(
            label: 'Discharge Weight',
            value: '${patient.dischargeWeight!.toStringAsFixed(3)} kg',
          ),
        if (patient.headCircumference != null)
          _DetailRow(
            label: 'Head Circumference',
            value: '${patient.headCircumference!.toStringAsFixed(1)} cm',
          ),
        if (patient.length != null)
          _DetailRow(
            label: 'Length',
            value: '${patient.length!.toStringAsFixed(1)} cm',
          ),
        if (patient.maternalMorbidities != null &&
            patient.maternalMorbidities!.isNotEmpty)
          _DetailRow(
            label: 'Maternal Morbidities',
            value: patient.maternalMorbidities!.join(', '),
          ),
        if (patient.ans != null)
          _DetailRow(label: 'ANS', value: _ansToString(patient.ans!)),
        if (patient.antentalScan != null && patient.antentalScan!.isNotEmpty)
          _DetailRow(
            label: 'Antental Scan',
            value: patient.antentalScan!.join(', '),
          ),
        if (patient.modeOfDelivery != null)
          _DetailRow(
            label: 'Mode of Delivery',
            value: _modeOfDeliveryToString(patient.modeOfDelivery!),
          ),
        if (patient.resuscitationAtBirth != null &&
            patient.resuscitationAtBirth!.isNotEmpty)
          _DetailRow(
            label: 'Resuscitation at Birth',
            value: patient.resuscitationAtBirth!.join(', '),
          ),
        if (patient.respiratorySystem != null &&
            patient.respiratorySystem!.isNotEmpty)
          _DetailRow(
            label: 'Respiratory System',
            value: patient.respiratorySystem!.join(', '),
          ),
        if (patient.cardiovascularSystem != null)
          _DetailRow(
            label: 'Cardiovascular System',
            value: patient.cardiovascularSystem!,
          ),
        if (patient.sepsis != null)
          _DetailRow(label: 'Sepsis', value: patient.sepsis!),
        if (patient.organism != null)
          _DetailRow(label: 'Organism', value: patient.organism!),
        if (patient.feeding != null && patient.feeding!.isNotEmpty)
          _DetailRow(label: 'Feeding', value: patient.feeding!.join(', ')),
        if (patient.rtfStarted != null)
          _DetailRow(label: 'RTF Started', value: patient.rtfStarted!),
        if (patient.fullFeedsReached != null)
          _DetailRow(
            label: 'Full Feeds Reached',
            value: patient.fullFeedsReached!,
          ),
        if (patient.surfactant != null)
          _DetailRow(
            label: 'Surfactant',
            value: _surfactantToString(patient.surfactant!),
          ),
        if (patient.ventilation != null && patient.ventilation!.isNotEmpty)
          _DetailRow(
            label: 'Ventilation',
            value: patient.ventilation!.join(', '),
          ),
        if (patient.bpd != null)
          _DetailRow(
            label: 'BPD',
            value: patient.bpd == BPD.yes ? 'Yes' : 'No',
          ),
        if (patient.probiotics != null)
          _DetailRow(
            label: 'Probiotics',
            value: patient.probiotics! ? 'Yes' : 'No',
          ),
        if (patient.bloodTransfusion != null)
          _DetailRow(
            label: 'Blood Transfusion',
            value: patient.bloodTransfusion! ? 'Yes' : 'No',
          ),
        if (patient.rop != null)
          _DetailRow(label: 'ROP', value: _ropToString(patient.rop!)),
        if (patient.usgHead != null)
          _DetailRow(label: 'USG Head', value: patient.usgHead!),
        if (patient.other != null)
          _DetailRow(label: 'Other', value: patient.other!),
        if (patient.picc != null)
          _DetailRow(label: 'PICC', value: patient.picc! ? 'Yes' : 'No'),
        if (patient.user != null)
          _DetailRow(label: 'User', value: patient.user!),
        _DetailRow(label: 'Status OK', value: patient.statusOk ? 'Yes' : 'No'),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.space16),
          child,
        ],
      ),
    );
  }

  String _relationToString(Relation relation) {
    switch (relation) {
      case Relation.father:
        return 'Father';
      case Relation.mother:
        return 'Mother';
      case Relation.gFather:
        return 'G.Father';
      case Relation.uncle:
        return 'Uncle';
      case Relation.mama:
        return 'Mama';
      case Relation.nana:
        return 'Nana';
      case Relation.nani:
        return 'Nani';
      case Relation.foi:
        return 'FOI';
    }
  }

  String _weightPercentileToString(WeightPercentile percentile) {
    switch (percentile) {
      case WeightPercentile.afd:
        return 'AFD';
      case WeightPercentile.sfd:
        return 'SFD';
      case WeightPercentile.lfd:
        return 'LFD';
    }
  }

  String _ansToString(ANS ans) {
    switch (ans) {
      case ANS.yes:
        return 'Yes';
      case ANS.no:
        return 'No';
      case ANS.incomplete:
        return 'Incomplete';
    }
  }

  String _modeOfDeliveryToString(ModeOfDelivery mode) {
    switch (mode) {
      case ModeOfDelivery.vaginal:
        return 'Vaginal';
      case ModeOfDelivery.cesarian:
        return 'Cesarian';
      case ModeOfDelivery.forceps:
        return 'Forceps';
    }
  }

  String _surfactantToString(Surfactant surfactant) {
    switch (surfactant) {
      case Surfactant.no:
        return 'No';
      case Surfactant.singleDose:
        return 'Single dose';
      case Surfactant.multipleDose:
        return 'Multiple dose';
    }
  }

  String _ropToString(ROP rop) {
    switch (rop) {
      case ROP.no:
        return 'No';
      case ROP.treated:
        return 'Treated';
      case ROP.notTreated:
        return 'Not Treated';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _PrefixChip extends StatelessWidget {
  final Prefix prefix;

  const _PrefixChip({required this.prefix});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (prefix) {
      case Prefix.so:
        label = 'S/O';
        break;
      case Prefix.do_:
        label = 'D/O';
        break;
      case Prefix.bo:
        label = 'B/O';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.inkTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppTheme.inkTeal, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DischargeStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isAdmitted = status == DischargeStatus.admitted;
    final label = isAdmitted ? 'Admitted' : 'Discharged';
    final color = isAdmitted ? AppTheme.success : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
