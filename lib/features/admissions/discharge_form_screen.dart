import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../app/theme.dart';
import '../../core/aggregation.dart';
import '../../core/discharge_validation.dart';
import '../../features/auth/auth_controller.dart';
import '../../data/providers/demo_providers.dart';
import '../../features/admissions/models/patient_stay.dart';
import '../../widgets/clinical_workspace.dart';
import '../../widgets/demo_banner.dart';

class DischargeFormScreen extends ConsumerStatefulWidget {
  const DischargeFormScreen({super.key});

  @override
  ConsumerState<DischargeFormScreen> createState() =>
      _DischargeFormScreenState();
}

class _DischargeFormScreenState extends ConsumerState<DischargeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  PatientStay? _selectedPatient;
  List<PatientStay> _admittedPatients = [];
  bool _isLoadingPatients = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  PlatformFile? _selectedDocument;

  // Discharge form fields
  final _ipNoController = TextEditingController();
  final _fileNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _districtController = TextEditingController();
  final _gestAgeWeeksController = TextEditingController();
  final _gestAgeDaysController = TextEditingController();
  final _birthWeightController = TextEditingController();
  final _admissionWeightController = TextEditingController();
  final _dischargeWeightController = TextEditingController();
  final _headCircumferenceController = TextEditingController();
  final _lengthController = TextEditingController();
  final _maternalMorbiditiesOtherController = TextEditingController();
  final _antentalScanOtherController = TextEditingController();
  final _respiratorySystemOtherController = TextEditingController();
  final _sepsisOtherController = TextEditingController();
  final _feedingOtherController = TextEditingController();
  final _rtfStartedController = TextEditingController();
  final _fullFeedsReachedController = TextEditingController();
  final _cardiovascularSystemController = TextEditingController();
  final _organismController = TextEditingController();
  final _usgHeadController = TextEditingController();
  final _otherController = TextEditingController();
  final _remarksController = TextEditingController();
  final _shiftedToController = TextEditingController();
  final _shiftReasonController = TextEditingController();
  final _dasiiMotor50Controller = TextEditingController();
  final _dasiiMotor97Controller = TextEditingController();
  final _dasiiMental50Controller = TextEditingController();
  final _dasiiMental97Controller = TextEditingController();

  // Dropdown/checkbox selections
  Sex? _sex;
  WeightPercentile? _weightPercentile;
  ANS? _ans;
  ModeOfDelivery? _modeOfDelivery;
  Surfactant? _surfactant;
  BPD? _bpd;
  ROP? _rop;
  String? _sepsis;
  DischargeType _dischargeType = DischargeType.routine;
  String? _placeOfDeliveryDischarge;
  Prefix? _prefix;
  String? _state = 'Gujarat';
  String? _adductaAngle;
  String? _cdcHeadControl;
  String? _cdcSitting;
  String? _cdcStanding;
  final List<String> _states = ['Gujarat'];
  final List<String> _districts = [
    'Ahmedabad',
    'Amreli',
    'Anand',
    'Aravalli',
    'Banaskantha',
    'Bharuch',
    'Bhavnagar',
    'Botad',
    'Chhota Udepur',
    'Dahod',
    'Dang',
    'Devbhoomi Dwarka',
    'Gandhinagar',
    'Gir Somnath',
    'Jamnagar',
    'Junagadh',
    'Kachchh',
    'Kheda',
    'Mahisagar',
    'Mehsana',
    'Morbi',
    'Narmada',
    'Navsari',
    'Panchmahal',
    'Patan',
    'Porbandar',
    'Rajkot',
    ' साबरकांઠા',
    'Surat',
    'Surendranagar',
    'Tapi',
    'Vadodara',
    'Valsad',
  ];

  // Multi-select lists
  Set<String> _maternalMorbidities = {};
  Set<String> _antentalScan = {};
  Set<String> _resuscitationAtBirth = {};
  Set<String> _respiratorySystem = {};
  Set<String> _ventilation = {};
  Set<String> _feeding = {};
  Set<String> _antibiotics = {};

  // Checkboxes
  bool? _probiotics;
  bool _bloodTransfusion = false;
  bool? _picc;
  bool _statusOk = false;

  DateTime _dod = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAdmittedPatients();
  }

  @override
  void dispose() {
    _ipNoController.dispose();
    _fileNameController.dispose();
    _dateOfBirthController.dispose();
    _districtController.dispose();
    _gestAgeWeeksController.dispose();
    _gestAgeDaysController.dispose();
    _birthWeightController.dispose();
    _admissionWeightController.dispose();
    _dischargeWeightController.dispose();
    _headCircumferenceController.dispose();
    _lengthController.dispose();
    _maternalMorbiditiesOtherController.dispose();
    _antentalScanOtherController.dispose();
    _respiratorySystemOtherController.dispose();
    _sepsisOtherController.dispose();
    _feedingOtherController.dispose();
    _rtfStartedController.dispose();
    _fullFeedsReachedController.dispose();
    _cardiovascularSystemController.dispose();
    _organismController.dispose();
    _usgHeadController.dispose();
    _otherController.dispose();
    _remarksController.dispose();
    _shiftedToController.dispose();
    _shiftReasonController.dispose();
    _dasiiMotor50Controller.dispose();
    _dasiiMotor97Controller.dispose();
    _dasiiMental50Controller.dispose();
    _dasiiMental97Controller.dispose();
    super.dispose();
  }

  Future<void> _loadAdmittedPatients() async {
    setState(() {
      _isLoadingPatients = true;
    });

    try {
      final patients = await ref
          .read(admissionsRepositoryProvider)
          .getAdmittedPatients();
      setState(() {
        _admittedPatients = patients;
        _isLoadingPatients = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPatients = false;
      });
    }
  }

  Future<void> _pickDocument() async {
    final file = await FilePicker.pickFile();
    if (file != null && mounted) {
      setState(() {
        _selectedDocument = file;
        _fileNameController.text = file.name;
      });
    }
  }

  Future<void> _addListValue({required bool addState}) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(addState ? 'Add State' : 'Add District'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: addState ? 'State name' : 'District name',
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty || !mounted) return;
    setState(() {
      final values = addState ? _states : _districts;
      if (!values.contains(value)) values.add(value);
      if (addState) {
        _state = value;
      } else {
        _districtController.text = value;
      }
    });
  }

  Future<void> _searchPatients() async {
    final controller = TextEditingController();
    final patient = await showDialog<PatientStay>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final query = controller.text.trim().toLowerCase();
          final matches = _admittedPatients.where((patient) {
            return patient.displayName.toLowerCase().contains(query) ||
                (patient.ipNo ?? '').toLowerCase().contains(query) ||
                patient.contactNumber.contains(query);
          }).toList();
          return AlertDialog(
            title: const Text('Search patients'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Name, IP No. or mobile',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: AppTheme.space12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        return ListTile(
                          title: Text(match.displayName),
                          subtitle: Text(match.ipNo ?? match.contactNumber),
                          onTap: () => Navigator.of(context).pop(match),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
    if (patient != null) _onPatientSelected(patient);
  }

  void _onPatientSelected(PatientStay? patient) {
    setState(() {
      _selectedPatient = patient;
      if (patient != null) {
        _dischargeType = patient.dischargeType ?? DischargeType.routine;
        _shiftedToController.clear();
        _shiftReasonController.clear();
        _autoFillFromAdmission(patient);
      }
    });
  }

  void _autoFillFromAdmission(PatientStay patient) {
    // Auto-fill fields marked as AUTO
    _ipNoController.text = patient.ipNo ?? '';
    _districtController.text = patient.district ?? '';
    _state = patient.state ?? 'Gujarat';
    if (!_states.contains(_state)) _states.add(_state!);
    if (patient.district != null && !_districts.contains(patient.district)) {
      _districts.add(patient.district!);
    }
    _prefix = patient.prefix;
    _placeOfDeliveryDischarge = patient.del;
    _sex = patient.sex;
    _dateOfBirthController.text = patient.dateOfBirth == null
        ? ''
        : formatDate(patient.dateOfBirth!);
    _fileNameController.text = patient.fileName ?? '';
    _gestAgeWeeksController.text = patient.gestAgeWeeks?.toString() ?? '';
    _gestAgeDaysController.text = patient.gestAgeDays?.toString() ?? '';
    _birthWeightController.text = patient.birthWeight?.toString() ?? '';
    _admissionWeightController.text = patient.admissionWeight?.toString() ?? '';
    _dischargeWeightController.text = patient.dischargeWeight?.toString() ?? '';
    _headCircumferenceController.text =
        patient.headCircumference?.toString() ?? '';
    _lengthController.text = patient.length?.toString() ?? '';
    _maternalMorbiditiesOtherController.text =
        patient.maternalMorbiditiesOther ?? '';
    _antentalScanOtherController.text = patient.antentalScanOther ?? '';
    _respiratorySystemOtherController.text =
        patient.respiratorySystemOther ?? '';
    _sepsisOtherController.text = patient.sepsisOther ?? '';
    _feedingOtherController.text = patient.feedingOther ?? '';
    _rtfStartedController.text = patient.rtfStarted ?? '';
    _fullFeedsReachedController.text = patient.fullFeedsReached ?? '';
    _cardiovascularSystemController.text = patient.cardiovascularSystem ?? '';
    _organismController.text = patient.organism ?? '';
    _usgHeadController.text = patient.usgHead ?? '';
    _otherController.text = patient.other ?? '';
    _remarksController.text = patient.remarks ?? '';
    _dasiiMotor50Controller.text = patient.dasiiMotorAgeAt50thCentile ?? '';
    _dasiiMotor97Controller.text = patient.dasiiMotorAgeAt97thCentile ?? '';
    _dasiiMental50Controller.text = patient.dasiiMentalAgeAt50thCentile ?? '';
    _dasiiMental97Controller.text = patient.dasiiMentalAgeAt97thCentile ?? '';
    _weightPercentile = patient.weightPercentile;
    _ans = patient.ans;
    _modeOfDelivery = patient.modeOfDelivery;
    _surfactant = patient.surfactant;
    _bpd = patient.bpd;
    _rop = patient.rop;
    _sepsis = patient.sepsis;
    _adductaAngle = patient.adductaAngle;
    _cdcHeadControl = patient.cdcHeadControl;
    _cdcSitting = patient.cdcSitting;
    _cdcStanding = patient.cdcStanding;
    _maternalMorbidities = {...?patient.maternalMorbidities};
    _antentalScan = {...?patient.antentalScan};
    _resuscitationAtBirth = {...?patient.resuscitationAtBirth};
    _respiratorySystem = {...?patient.respiratorySystem};
    _ventilation = {...?patient.ventilation};
    _feeding = {...?patient.feeding};
    _antibiotics = {...?patient.antibiotics};
    _probiotics = patient.probiotics;
    _bloodTransfusion = patient.bloodTransfusion ?? false;
    _picc = patient.picc;
    _statusOk = patient.statusOk;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPatient == null) {
      setState(() {
        _errorMessage = 'Please select a patient to discharge';
      });
      return;
    }

    // Validate discharge date not before admission
    if (_dod.isBefore(_selectedPatient!.doa)) {
      setState(() {
        _errorMessage = 'Discharge date cannot be before admission date';
      });
      return;
    }

    final shiftValidation = validateShiftDetails(
      dischargeType: _dischargeType,
      hospital: _shiftedToController.text,
      reason: _shiftReasonController.text,
    );
    if (shiftValidation != null) {
      setState(() => _errorMessage = shiftValidation);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final updatedPatient = _selectedPatient!.copyWith(
        dod: _dod,
        dischargeType: _dischargeType,
        shiftedTo: _dischargeType == DischargeType.shift
            ? _shiftedToController.text.trim()
            : null,
        shiftReason: _dischargeType == DischargeType.shift
            ? _shiftReasonController.text.trim()
            : null,
        ipNo: _ipNoController.text.trim().isEmpty
            ? null
            : _ipNoController.text.trim(),
        sex: _sex,
        prefix: _prefix,
        state: _state,
        district: _districtController.text.trim().isEmpty
            ? null
            : _districtController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim().isEmpty
            ? null
            : DateFormat('dd/MM/yyyy')
                  .tryParseStrict(_dateOfBirthController.text.trim()),
        placeOfDeliveryDischarge: _placeOfDeliveryDischarge,
        gestAgeWeeks: int.tryParse(_gestAgeWeeksController.text.trim()),
        gestAgeDays: int.tryParse(_gestAgeDaysController.text.trim()),
        birthWeight: double.tryParse(_birthWeightController.text.trim()),
        admissionWeight: double.tryParse(
          _admissionWeightController.text.trim(),
        ),
        weightPercentile: _weightPercentile,
        dischargeWeight: double.tryParse(
          _dischargeWeightController.text.trim(),
        ),
        headCircumference: double.tryParse(
          _headCircumferenceController.text.trim(),
        ),
        length: double.tryParse(_lengthController.text.trim()),
        maternalMorbidities: _maternalMorbidities.isEmpty
            ? null
            : _maternalMorbidities.toList(),
        maternalMorbiditiesOther:
            _maternalMorbiditiesOtherController.text.trim().isEmpty
            ? null
            : _maternalMorbiditiesOtherController.text.trim(),
        ans: _ans,
        antentalScan: _antentalScan.isEmpty ? null : _antentalScan.toList(),
        antentalScanOther: _antentalScanOtherController.text.trim().isEmpty
            ? null
            : _antentalScanOtherController.text.trim(),
        modeOfDelivery: _modeOfDelivery,
        resuscitationAtBirth: _resuscitationAtBirth.isEmpty
            ? null
            : _resuscitationAtBirth.toList(),
        respiratorySystemOther:
            _respiratorySystemOtherController.text.trim().isEmpty
            ? null
            : _respiratorySystemOtherController.text.trim(),
        respiratorySystem: _respiratorySystem.isEmpty
            ? null
            : _respiratorySystem.toList(),
        antibiotics: _antibiotics.isEmpty ? null : _antibiotics.toList(),
        cardiovascularSystem:
            _cardiovascularSystemController.text.trim().isEmpty
            ? null
            : _cardiovascularSystemController.text.trim(),
        sepsisOther: _sepsisOtherController.text.trim().isEmpty
            ? null
            : _sepsisOtherController.text.trim(),
        sepsis: _sepsis,
        organism: _organismController.text.trim().isEmpty
            ? null
            : _organismController.text.trim(),
        feeding: _feeding.isEmpty ? null : _feeding.toList(),
        feedingOther: _feedingOtherController.text.trim().isEmpty
            ? null
            : _feedingOtherController.text.trim(),
        rtfStarted: _rtfStartedController.text.trim().isEmpty
            ? null
            : _rtfStartedController.text.trim(),
        fullFeedsReached: _fullFeedsReachedController.text.trim().isEmpty
            ? null
            : _fullFeedsReachedController.text.trim(),
        surfactant: _surfactant,
        ventilation: _ventilation.isEmpty ? null : _ventilation.toList(),
        bpd: _bpd,
        probiotics: _probiotics,
        bloodTransfusion: _bloodTransfusion,
        rop: _rop,
        usgHead: _usgHeadController.text.trim().isEmpty
            ? null
            : _usgHeadController.text.trim(),
        fileName: _fileNameController.text.trim().isEmpty
            ? null
            : _fileNameController.text.trim(),
        adductaAngle: _adductaAngle,
        cdcHeadControl: _cdcHeadControl,
        cdcSitting: _cdcSitting,
        cdcStanding: _cdcStanding,
        dasiiMotorAgeAt50thCentile: _dasiiMotor50Controller.text.trim().isEmpty
            ? null
            : _dasiiMotor50Controller.text.trim(),
        dasiiMotorAgeAt97thCentile: _dasiiMotor97Controller.text.trim().isEmpty
            ? null
            : _dasiiMotor97Controller.text.trim(),
        dasiiMentalAgeAt50thCentile:
            _dasiiMental50Controller.text.trim().isEmpty
            ? null
            : _dasiiMental50Controller.text.trim(),
        dasiiMentalAgeAt97thCentile:
            _dasiiMental97Controller.text.trim().isEmpty
            ? null
            : _dasiiMental97Controller.text.trim(),
        other: _otherController.text.trim().isEmpty
            ? null
            : _otherController.text.trim(),
        remarks: _remarksController.text.trim().isEmpty
            ? null
            : _remarksController.text.trim(),
        picc: _picc,
        user: ref.read(authControllerProvider).userName,
        statusOk: _statusOk,
      );

      await ref
          .read(admissionsRepositoryProvider)
          .updatePatient(updatedPatient);
      ref.invalidate(admissionsListProvider);
      ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        final isDemo = ref.read(authControllerProvider).isDemo;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDemo
                  ? 'Added to the demo session only. Data is cleared when you exit.'
                  : 'Patient discharged successfully',
            ),
          ),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to discharge patient: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClinicalWorkspace(
      title: 'Discharge Patient',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showDocumentBesideForm =
              _selectedDocument != null && constraints.maxWidth >= 1000;
          if (!showDocumentBesideForm) return _buildDischargeFormContent();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 6, child: _buildDischargeFormContent()),
              const SizedBox(width: AppTheme.space12),
              Expanded(flex: 5, child: _buildDocumentPreview()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDischargeFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1380),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ref.watch(authControllerProvider.select((s) => s.isDemo))) ...[
                  const DemoBanner(),
                  const SizedBox(height: AppTheme.space16),
                ],
                if (_errorMessage != null) ...[
                  _buildErrorBanner(_errorMessage!),
                  const SizedBox(height: AppTheme.space16),
                ],
                Wrap(
                  spacing: AppTheme.space8,
                  runSpacing: AppTheme.space8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Open Document'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _searchPatients,
                      icon: const Icon(Icons.search),
                      label: const Text('SEARCH'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/admission/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('New'),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space16),
                _buildPatientSelector(),
                if (_selectedPatient != null) ...[
                  const SizedBox(height: AppTheme.space24),
                  _buildDischargeForm(),
                  const SizedBox(height: AppTheme.space24),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('SAVE'),
                      ),
                      const SizedBox(width: AppTheme.space16),
                      TextButton(
                        onPressed: () => context.go('/dashboard'),
                        child: const Text('CANCEL'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentPreview() {
    final file = _selectedDocument!;
    final extension = (file.extension ?? '').toLowerCase();
    final path = file.path;

    Widget content;
    if (extension == 'pdf' && path != null) {
      content = PdfViewer.file(path);
    } else if ({
          'png',
          'jpg',
          'jpeg',
          'webp',
          'gif',
          'bmp',
        }.contains(extension) &&
        path != null) {
      content = InteractiveViewer(
        child: Image.file(File(path), fit: BoxFit.contain),
      );
    } else {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.description_outlined, size: 48),
              const SizedBox(height: AppTheme.space12),
              Text(
                file.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                'Side-by-side preview supports PDF and image files.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        0,
        AppTheme.space24,
        AppTheme.space24,
        AppTheme.space24,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.hairline),
        borderRadius: BorderRadius.circular(AppTheme.radius12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.space16,
              top: AppTheme.space8,
              bottom: AppTheme.space8,
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 18),
                const SizedBox(width: AppTheme.space8),
                Expanded(
                  child: Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close document',
                  onPressed: () => setState(() => _selectedDocument = null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: AppTheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: AppTheme.error, size: 20),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppTheme.error),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSelector() {
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
            'Select Patient to Discharge',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.space16),
          if (_isLoadingPatients)
            const Center(child: CircularProgressIndicator())
          else if (_admittedPatients.isEmpty)
            Text(
              'No admitted patients found',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppTheme.textSecondary),
            )
          else
            DropdownButtonFormField<PatientStay>(
              initialValue: _selectedPatient,
              decoration: const InputDecoration(
                hintText: 'Select a patient',
                border: OutlineInputBorder(),
              ),
              items: _admittedPatients.map((patient) {
                return DropdownMenuItem(
                  value: patient,
                  child: Text(patient.displayName),
                );
              }).toList(),
              onChanged: _onPatientSelected,
            ),
        ],
      ),
    );
  }

  Widget _buildDischargeForm() {
    final patient = _selectedPatient!;
    final daysStayed = calculateDaysStayed(patient.doa, _dod);

    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient identity, contact and admission details.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeading('Patient Details'),
                _buildDropdownField<DischargeType>(
                  label: 'Discharge Type',
                  value: _dischargeType,
                  items: const [
                    DropdownMenuItem(
                      value: DischargeType.routine,
                      child: Text('Routine Discharge'),
                    ),
                    DropdownMenuItem(
                      value: DischargeType.expired,
                      child: Text('Expired'),
                    ),
                    DropdownMenuItem(
                      value: DischargeType.shift,
                      child: Text('Shift'),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _dischargeType = value ?? DischargeType.routine;
                    if (_dischargeType != DischargeType.shift) {
                      _shiftedToController.clear();
                      _shiftReasonController.clear();
                    }
                  }),
                ),
                const SizedBox(height: AppTheme.space16),
                if (_dischargeType == DischargeType.shift) ...[
                  _buildTextField(
                    label: 'Hospital shifted to',
                    controller: _shiftedToController,
                    validator: (value) => validateShiftDetails(
                      dischargeType: _dischargeType,
                      hospital: value ?? '',
                      reason: 'valid',
                    ),
                  ),
                  const SizedBox(height: AppTheme.space16),
                  _buildTextField(
                    label: 'Reason for shifting',
                    controller: _shiftReasonController,
                    validator: (value) => validateShiftDetails(
                      dischargeType: _dischargeType,
                      hospital: 'valid',
                      reason: value ?? '',
                    ),
                  ),
                  const SizedBox(height: AppTheme.space16),
                ],
                // Field 1: Sr. No. (AUTO, read-only)
                _buildReadOnlyField(
                  label: 'Sr. No.',
                  value: patient.serialNo?.toString() ?? 'N/A',
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 2: IP No.
                _buildTextField(
                  label: 'IP No.',
                  controller: _ipNoController,
                  hintText: 'Format 999DDMMYYYY',
                ),
                const SizedBox(height: AppTheme.space16),
                _buildDropdownField<Prefix>(
                  label: 'Name prefix',
                  value: _prefix,
                  items: const [
                    DropdownMenuItem(value: Prefix.so, child: Text('S/O')),
                    DropdownMenuItem(value: Prefix.do_, child: Text('D/O')),
                    DropdownMenuItem(value: Prefix.bo, child: Text('B/O')),
                  ],
                  onChanged: (value) => setState(() => _prefix = value),
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'Name',
                  value: patient.displayName.isNotEmpty
                      ? patient.displayName
                      : _nameWithSelectedPrefix(patient),
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'Branch',
                  value: patient.branch == null
                      ? 'N/A'
                      : patient.branch == Branch.arpanMother
                      ? 'Arpan Mother'
                      : 'Arpan Violet',
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'Type of Admission',
                  value: patient.admissionType == null
                      ? 'N/A'
                      : patient.admissionType == AdmissionType.inborn
                      ? 'Inborn'
                      : 'Outborn',
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'First or Readmission',
                  value: patient.admissionHistory == null
                      ? 'N/A'
                      : patient.admissionHistory ==
                            AdmissionHistory.firstAdmission
                      ? 'First Admission'
                      : 'Re Admission',
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'Birth Type',
                  value: switch (patient.birthType) {
                    BirthType.single => 'Single',
                    BirthType.twin => 'Twin',
                    BirthType.triplet => 'Triplet',
                    null => 'N/A',
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 4: Sex
                _buildDropdownField<Sex>(
                  label: 'Gender',
                  value: _sex,
                  items: const [
                    DropdownMenuItem(value: Sex.male, child: Text('Male')),
                    DropdownMenuItem(value: Sex.female, child: Text('Female')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sex = value;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'Address',
                  value:
                      [
                            patient.address,
                            patient.street,
                            patient.area,
                            patient.city,
                          ]
                          .whereType<String>()
                          .where((part) => part.isNotEmpty)
                          .join('\n'),
                ),
                const SizedBox(height: AppTheme.space16),
                _buildDropdownField<String>(
                  label: 'State',
                  value: _state,
                  items: _states
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _state = value),
                ),
                const SizedBox(height: AppTheme.space16),
                _buildDropdownField<String>(
                  label: 'District',
                  value: _districtController.text.isEmpty
                      ? null
                      : _districtController.text,
                  items: _districts
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _districtController.text = value ?? '';
                  }),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _addListValue(addState: false),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add District'),
                  ),
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 11: Date of Birth
                _buildDateField(
                  label: 'Date of Birth',
                  controller: _dateOfBirthController,
                ),
                const SizedBox(height: AppTheme.space16),
                _buildTextField(
                  label: 'File Name',
                  controller: _fileNameController,
                  readOnly: true,
                  suffixIcon: IconButton(
                    tooltip: 'Choose document',
                    onPressed: _pickDocument,
                    icon: const Icon(Icons.folder_open),
                  ),
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 12: Date of admission (AUTO from DOA)
                _buildReadOnlyField(
                  label: 'Date of Admission',
                  value: formatDate(patient.doa),
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 13: Date of Discharge (required)
                _buildDateField(
                  label: 'Date of Discharge',
                  controller: TextEditingController(text: formatDate(_dod)),
                  onChanged: (date) {
                    if (date != null) {
                      setState(() {
                        _dod = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 14: Place of delivery (AUTO from DEL)
                _buildDeliveryDropdown(),
                const SizedBox(height: AppTheme.space16),
                // Field 15-16: Gest Age
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Gest Age - Week',
                        controller: _gestAgeWeeksController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Gest Age - Days',
                        controller: _gestAgeDaysController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 17: Birth Weight
                _buildTextField(
                  label: 'Birth Weight (kg)',
                  controller: _birthWeightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  hintText: '0.000',
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 18: Admission WT
                _buildTextField(
                  label: 'Admission WT (kg)',
                  controller: _admissionWeightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  hintText: '0.000',
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 19: Weight Percentile
                _buildDropdownField<WeightPercentile>(
                  label: 'Weight Percentile',
                  value: _weightPercentile,
                  items: const [
                    DropdownMenuItem(
                      value: WeightPercentile.afd,
                      child: Text('AFD'),
                    ),
                    DropdownMenuItem(
                      value: WeightPercentile.sfd,
                      child: Text('SFD'),
                    ),
                    DropdownMenuItem(
                      value: WeightPercentile.lfd,
                      child: Text('LFD'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _weightPercentile = value;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 20: Discharge Weight
                _buildTextField(
                  label: 'Discharge Weight (kg)',
                  controller: _dischargeWeightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  hintText: '0.000',
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 21: Head Circumference
                _buildTextField(
                  label: 'Head Circumference (cm)',
                  controller: _headCircumferenceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  hintText: '0.0',
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 22: Length
                _buildTextField(
                  label: 'Length (cm)',
                  controller: _lengthController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  hintText: '0.0',
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 22: Maternal Morbidities (multi)
                _buildMultiSelectField(
                  label: 'Maternal Morbidities',
                  options: const [
                    'PIH',
                    'PROM',
                    'APH',
                    'Meconium stained liquor',
                    'Diabetes',
                    'Hypothyroidism',
                  ],
                  selected: _maternalMorbidities,
                  otherController: _maternalMorbiditiesOtherController,
                  onChanged: (set) {
                    setState(() {
                      _maternalMorbidities = set;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space24),
          // Birth, clinical course and developmental assessment.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeading('Birth and Clinical Course'),
                // Field 23: ANS
                _buildDropdownField<ANS>(
                  label: 'ANS',
                  value: _ans,
                  items: const [
                    DropdownMenuItem(value: ANS.yes, child: Text('Yes')),
                    DropdownMenuItem(value: ANS.no, child: Text('No')),
                    DropdownMenuItem(
                      value: ANS.incomplete,
                      child: Text('Incomplete'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _ans = value;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 24: Antental Scane (multi)
                _buildMultiSelectField(
                  label: 'Antental Scan',
                  options: const [
                    'Normal',
                    'Oligohydroamnios',
                    'AEDF/REDF',
                    'Brain sparing effect',
                    'Polyhydroamnios',
                  ],
                  selected: _antentalScan,
                  otherController: _antentalScanOtherController,
                  onChanged: (set) {
                    setState(() {
                      _antentalScan = set;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 25: Mode of Delivery
                _buildDropdownField<ModeOfDelivery>(
                  label: 'Mode of Delivery',
                  value: _modeOfDelivery,
                  items: const [
                    DropdownMenuItem(
                      value: ModeOfDelivery.vaginal,
                      child: Text('Vaginal'),
                    ),
                    DropdownMenuItem(
                      value: ModeOfDelivery.cesarian,
                      child: Text('Cesarian'),
                    ),
                    DropdownMenuItem(
                      value: ModeOfDelivery.forceps,
                      child: Text('Forceps'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _modeOfDelivery = value;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 26: Resuscit. at Birth (multi)
                _buildMultiSelectField(
                  label: 'Resuscit. at Birth',
                  options: const [
                    'None',
                    'Oxygen',
                    'Bag and Mask',
                    'Bag and Tube',
                    'Drugs',
                  ],
                  selected: _resuscitationAtBirth,
                  onChanged: (set) {
                    setState(() {
                      _resuscitationAtBirth = set;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Section heading
                Text(
                  'Systems and Infection',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.space16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildMultiSelectField(
                        label: 'Respiratory System',
                        options: const ['TTN', 'HMD', 'MAS', 'Pneumothorax'],
                        selected: _respiratorySystem,
                        otherController: _respiratorySystemOtherController,
                        onChanged: (set) =>
                            setState(() => _respiratorySystem = set),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Cardiovascular System',
                        controller: _cardiovascularSystemController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 28: Sepsis
                _buildDropdownField<String>(
                  label: 'Sepsis',
                  value: _sepsis,
                  items: const [
                    DropdownMenuItem(
                      value: 'No Sepsis',
                      child: Text('No Sepsis'),
                    ),
                    DropdownMenuItem(
                      value: 'Culture -ve',
                      child: Text('Culture -ve'),
                    ),
                    DropdownMenuItem(
                      value: 'Culture +ve',
                      child: Text('Culture +ve'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sepsis = value;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 29: Organism
                _buildTextField(
                  label: 'Organism',
                  controller: _organismController,
                ),
                const SizedBox(height: AppTheme.space16),
                _buildMultiSelectField(
                  label: 'Antibiotics',
                  options: const [
                    'Ampicillin',
                    'Gentamicin',
                    'Amikacin',
                    'Cefotaxime',
                    'Piperacillin/Tazobactam',
                    'Meropenem',
                    'Vancomycin',
                  ],
                  selected: _antibiotics,
                  onChanged: (set) => setState(() => _antibiotics = set),
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 30: Feeding (multi)
                _buildMultiSelectField(
                  label: 'Feeding',
                  options: const ['NEC', 'GER', 'Feed Intolerance'],
                  selected: _feeding,
                  otherController: _feedingOtherController,
                  onChanged: (set) {
                    setState(() {
                      _feeding = set;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 31: RTF started
                _buildTextField(
                  label: 'RTF started',
                  controller: _rtfStartedController,
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 32: FULL feeds reached
                _buildTextField(
                  label: 'FULL feeds reached',
                  controller: _fullFeedsReachedController,
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 33: Surfactant
                _buildDropdownField<Surfactant>(
                  label: 'Surfactant',
                  value: _surfactant,
                  items: const [
                    DropdownMenuItem(value: Surfactant.no, child: Text('No')),
                    DropdownMenuItem(
                      value: Surfactant.singleDose,
                      child: Text('Single dose'),
                    ),
                    DropdownMenuItem(
                      value: Surfactant.multipleDose,
                      child: Text('Multiple dose'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _surfactant = value;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 34: Ventilation (multi)
                _buildMultiSelectField(
                  label: 'Ventilation',
                  options: const [
                    'CPAP',
                    'HHHFNC',
                    'NIMV',
                    'HFOV',
                    'Conventinal',
                  ],
                  selected: _ventilation,
                  onChanged: (set) {
                    setState(() {
                      _ventilation = set;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'Ventilation summary',
                  value: _ventilation.join(', '),
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 35: BPD
                _buildDropdownField<BPD>(
                  label: 'BPD',
                  value: _bpd,
                  items: const [
                    DropdownMenuItem(value: BPD.yes, child: Text('Yes')),
                    DropdownMenuItem(value: BPD.no, child: Text('No')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _bpd = value;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 36: Probiotics
                _buildYesNoDropdown(
                  label: 'Probiotics',
                  value: _probiotics,
                  onChanged: (value) => setState(() => _probiotics = value),
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 37: Blood Transfusion
                _buildCheckboxField(
                  label: 'Blood Transfusion',
                  value: _bloodTransfusion,
                  onChanged: (value) => setState(() {
                    _bloodTransfusion = value;
                  }),
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 38: ROP
                _buildDropdownField<ROP>(
                  label: 'ROP',
                  value: _rop,
                  items: const [
                    DropdownMenuItem(value: ROP.no, child: Text('No')),
                    DropdownMenuItem(
                      value: ROP.treated,
                      child: Text('Treated'),
                    ),
                    DropdownMenuItem(
                      value: ROP.notTreated,
                      child: Text('Not Treated'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _rop = value;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 39: USG Head
                _buildTextField(
                  label: 'USG Head',
                  controller: _usgHeadController,
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 40: Other
                _buildTextField(label: 'Other', controller: _otherController),
                const SizedBox(height: AppTheme.space16),
                // Field 41: PICC
                _buildYesNoDropdown(
                  label: 'PICC',
                  value: _picc,
                  onChanged: (value) => setState(() => _picc = value),
                ),
                const SizedBox(height: AppTheme.space16),
                // Additional fields: Mobile-1, Mobile-2 (AUTO)
                _buildReadOnlyField(
                  label: 'Mobile-1',
                  value: patient.contactNumber,
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'Mobile-2',
                  value: patient.contactNumber2 ?? 'N/A',
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'YYYYMM',
                  value: formatYearMonth(_dod),
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'User',
                  value: ref.read(authControllerProvider).userName ?? 'N/A',
                ),
                const SizedBox(height: AppTheme.space16),
                // Field 42: Status OK (verified checkbox)
                _buildCheckboxField(
                  label: 'Status OK (Verified)',
                  value: _statusOk,
                  onChanged: (value) {
                    setState(() {
                      _statusOk = value;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.space16),
                _buildReadOnlyField(
                  label: 'Days Stayed',
                  value: '$daysStayed days',
                ),
                const SizedBox(height: AppTheme.space24),
                Text(
                  'Neuro-developmental assessment',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.space16),
                _buildDropdownField<String>(
                  label: 'Amiel-Tison: Adducta angle',
                  value: _adductaAngle,
                  items: const [
                    DropdownMenuItem(value: 'Tight', child: Text('Tight')),
                    DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                  ],
                  onChanged: (value) => setState(() => _adductaAngle = value),
                ),
                const SizedBox(height: AppTheme.space16),
                _buildCdcDropdown(
                  label: 'CDC Grading: Head Control',
                  value: _cdcHeadControl,
                  onChanged: (value) => setState(() => _cdcHeadControl = value),
                ),
                const SizedBox(height: AppTheme.space16),
                _buildCdcDropdown(
                  label: 'CDC Grading: Sitting',
                  value: _cdcSitting,
                  onChanged: (value) => setState(() => _cdcSitting = value),
                ),
                const SizedBox(height: AppTheme.space16),
                _buildCdcDropdown(
                  label: 'CDC Grading: Standing',
                  value: _cdcStanding,
                  onChanged: (value) => setState(() => _cdcStanding = value),
                ),
                const SizedBox(height: AppTheme.space16),
                _buildTextField(
                  label: 'DASII Motor Age: At 50th Centile',
                  controller: _dasiiMotor50Controller,
                ),
                const SizedBox(height: AppTheme.space16),
                _buildTextField(
                  label: 'DASII Motor Age: At 97th Centile',
                  controller: _dasiiMotor97Controller,
                ),
                const SizedBox(height: AppTheme.space16),
                _buildTextField(
                  label: 'DASII Mental Age: At 50th Centile',
                  controller: _dasiiMental50Controller,
                ),
                const SizedBox(height: AppTheme.space16),
                _buildTextField(
                  label: 'DASII Mental Age: At 97th Centile',
                  controller: _dasiiMental97Controller,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.space16),
          decoration: BoxDecoration(
            color: AppTheme.hairline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            border: Border.all(color: AppTheme.hairline),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.space8),
          const Divider(height: 1),
        ],
      ),
    );
  }

  String _nameWithSelectedPrefix(PatientStay patient) {
    final prefix = switch (_prefix ?? patient.prefix) {
      Prefix.so => 'S/O',
      Prefix.do_ => 'D/O',
      Prefix.bo => 'B/O',
    };
    return '$prefix ${patient.mothersName}';
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        DropdownButtonFormField<T>(
          initialValue: value,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCdcDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    const grades = [
      'Grade 0',
      'Grade I',
      'Grade II',
      'Grade III',
      'Grade IV',
      'Grade V',
      'Grade VI',
    ];
    return _buildDropdownField<String>(
      label: label,
      value: value,
      items: grades
          .map((grade) => DropdownMenuItem(value: grade, child: Text(grade)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    ValueChanged<DateTime?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              controller.text = formatDate(picked);
              onChanged?.call(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.hairline),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.space12),
                Text(
                  controller.text.isEmpty ? 'Select date' : controller.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: controller.text.isEmpty
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryDropdown() {
    final options = const [
      'Munshi',
      'Bavishi',
      'Sheth',
      'Amin',
      'Mayflower',
      'Rupal Parikh',
      'Sushrusha hospital',
      'Dr.Akshay Shah',
      'Dr. Kiran Desai',
      'Dr. Suresh Kothari',
      'Sunflower',
      'Dr. Seema Talati',
      'Dr. Bharat Parikh',
      'Dr. Prashant Acharya',
      'Dr. Ashish Nanavati',
    ];

    // If current value is not in options, set it to null or 'other'
    String? dropdownValue = _placeOfDeliveryDischarge;
    if (dropdownValue != null &&
        !options.contains(dropdownValue) &&
        dropdownValue != 'other') {
      dropdownValue = 'other';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Place of Delivery',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.space8),
        DropdownButtonFormField<String>(
          initialValue: dropdownValue,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            ...options.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }),
            const DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            setState(() {
              _placeOfDeliveryDischarge = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> options,
    required Set<String> selected,
    TextEditingController? otherController,
    required ValueChanged<Set<String>> onChanged,
  }) {
    Future<void> openOptions() async {
      final draft = Set<String>.from(selected);
      final result = await showDialog<Set<String>>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(label),
            content: SizedBox(
              width: 380,
              child: ListView(
                shrinkWrap: true,
                children: options
                    .map(
                      (option) => CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(option),
                        value: draft.contains(option),
                        onChanged: (checked) {
                          setDialogState(() {
                            if (checked ?? false) {
                              draft.add(option);
                            } else {
                              draft.remove(option);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(draft),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
      if (result != null) onChanged(result);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        InputDecorator(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          child: InkWell(
            onTap: openOptions,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected.isEmpty ? 'Select $label' : selected.join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected.isEmpty
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (otherController != null) ...[
          const SizedBox(height: AppTheme.space8),
          TextFormField(
            controller: otherController,
            decoration: const InputDecoration(
              hintText: 'Other (if applicable)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildYesNoDropdown({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return _buildDropdownField<bool>(
      label: label,
      value: value,
      items: const [
        DropdownMenuItem(value: true, child: Text('Yes')),
        DropdownMenuItem(value: false, child: Text('No')),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildCheckboxField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (bool? newValue) {
            onChanged(newValue ?? false);
          },
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
