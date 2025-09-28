import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../models/anc_visit.dart';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';

class ANCVisitForm extends StatefulWidget {
  final Patient? selectedPatient;
  final ANCVisit? editingVisit;

  const ANCVisitForm({
    super.key,
    this.selectedPatient,
    this.editingVisit,
  });

  @override
  State<ANCVisitForm> createState() => _ANCVisitFormState();
}

class _ANCVisitFormState extends State<ANCVisitForm>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  int _currentTabIndex = 0;

  // Controllers for form fields
  final TextEditingController _complaintsNotesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _systolicBPController = TextEditingController();
  final TextEditingController _diastolicBPController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _respiratoryRateController = TextEditingController();
  final TextEditingController _fundalHeightController = TextEditingController();
  final TextEditingController _fetalHRController = TextEditingController();
  final TextEditingController _fetalPositionController = TextEditingController();
  final TextEditingController _hemoglobinController = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();
  final TextEditingController _tshValueController = TextEditingController();
  final TextEditingController _ironCountController = TextEditingController();
  final TextEditingController _calciumCountController = TextEditingController();
  final TextEditingController _riskNotesController = TextEditingController();
  final TextEditingController _counselingNotesController = TextEditingController();
  final TextEditingController _clinicalNotesController = TextEditingController();
  final TextEditingController _treatmentPlanController = TextEditingController();
  final TextEditingController _specialInstructionsController = TextEditingController();
  final TextEditingController _referralReasonController = TextEditingController();

  // Form state variables
  Patient? _selectedPatient;
  DateTime _visitDate = DateTime.now();
  int _gestationalWeeks = 1;
  int _gestationalDays = 0;
  ANCVisitType _visitType = ANCVisitType.routine;
  int _visitNumber = 1;
  List<String> _selectedComplaints = [];
  String? _generalCondition = 'Good';
  FetalPresentation _fetalPresentation = FetalPresentation.vertex;
  bool _pallor = false;
  bool _pedemaFeet = false;
  bool _pedemaFace = false;
  bool _pedemaGeneralized = false;
  bool _fetalMovements = true;
  bool? _uterineContractions;
  String? _bloodGroup;
  String? _rhFactor;
  bool? _hivTest;
  String? _hivResult;
  bool? _syphilisTest;
  String? _syphilisResult;
  bool? _hepatitisBTest;
  String? _hepatitisBResult;
  String? _urineAlbumin;
  String? _urineSugar;
  bool? _tshTest;
  bool? _ttVaccine1;
  DateTime? _ttVaccine1Date;
  bool? _ttVaccine2;
  DateTime? _ttVaccine2Date;
  bool? _ttBooster;
  DateTime? _ttBoosterDate;
  bool _ironGiven = false;
  bool _calciumGiven = false;
  List<String> _otherMedications = [];
  RiskCategory _riskCategory = RiskCategory.low;
  List<String> _riskFactors = [];
  List<String> _counselingTopics = [];
  DateTime? _nextVisitDate;
  String? _referralRequired = 'No';
  String? _referralTo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    // Initialize with selected patient or editing visit
    if (widget.selectedPatient != null) {
      _selectedPatient = widget.selectedPatient;
    }

    if (widget.editingVisit != null) {
      _initializeFromExistingVisit(widget.editingVisit!);
    }
  }

  void _initializeFromExistingVisit(ANCVisit visit) {
    // Initialize form fields from existing visit data
    _visitDate = visit.visitDate;
    _gestationalWeeks = visit.gestationalWeeks;
    _gestationalDays = visit.gestationalDays;
    _visitType = visit.visitType;
    _visitNumber = visit.visitNumber;
    _selectedComplaints = List.from(visit.complaints);
    _complaintsNotesController.text = visit.complaintsNotes;
    
    // Set all other fields from the visit
    if (visit.weight != null) _weightController.text = visit.weight!.toString();
    if (visit.height != null) _heightController.text = visit.height!.toString();
    // ... (initialize all other fields similarly)
  }

  @override
  void dispose() {
    _tabController.dispose();
    _complaintsNotesController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    // ... dispose all controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingVisit != null ? 'Edit ANC Visit' : 'New ANC Visit'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              if (_selectedPatient != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          _selectedPatient!.name.isNotEmpty 
                              ? _selectedPatient!.name[0].toUpperCase() 
                              : 'P',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedPatient!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'ID: ${_selectedPatient!.id} • Age: ${_selectedPatient!.age}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.selectedPatient == null)
                        TextButton(
                          onPressed: _selectPatient,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                          child: const Text('Change Patient'),
                        ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _selectPatient,
                    icon: const Icon(Icons.person_search),
                    label: const Text('Select Patient'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.primaryColor,
                    ),
                  ),
                ),
              ],
              
              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: (_currentTabIndex + 1) / 6,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: _selectedPatient == null
          ? _buildPatientSelectionPrompt()
          : Column(
              children: [
                // Tab Bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: theme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: theme.primaryColor,
                    tabs: const [
                      Tab(text: 'Visit Info'),
                      Tab(text: 'Vitals'),
                      Tab(text: 'Examination'),
                      Tab(text: 'Lab Tests'),
                      Tab(text: 'Treatment'),
                      Tab(text: 'Plan'),
                    ],
                  ),
                ),
                
                // Tab Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildVisitInfoTab(),
                        _buildVitalsTab(),
                        _buildExaminationTab(),
                        _buildLabTestsTab(),
                        _buildTreatmentTab(),
                        _buildPlanTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _selectedPatient != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentTabIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _tabController.animateTo(_currentTabIndex - 1);
                        },
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentTabIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _currentTabIndex == 0 ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: _currentTabIndex == 5 ? _saveVisit : () {
                        _tabController.animateTo(_currentTabIndex + 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_currentTabIndex == 5 ? 'Save Visit' : 'Next'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildPatientSelectionPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Select a Patient',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a pregnant patient to start the ANC visit',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _selectPatient,
            icon: const Icon(Icons.person_add),
            label: const Text('Select Patient'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Visit Information'),
          
          // Visit Date
          _buildDateField(
            label: 'Visit Date',
            value: _visitDate,
            onChanged: (date) {
              setState(() {
                _visitDate = date;
              });
            },
          ),
          
          // Gestational Age
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildNumericField(
                  label: 'Gestational Weeks',
                  value: _gestationalWeeks,
                  onChanged: (value) {
                    setState(() {
                      _gestationalWeeks = value ?? 1;
                    });
                  },
                  min: 1,
                  max: 42,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumericField(
                  label: 'Days',
                  value: _gestationalDays,
                  onChanged: (value) {
                    setState(() {
                      _gestationalDays = value ?? 0;
                    });
                  },
                  min: 0,
                  max: 6,
                ),
              ),
            ],
          ),
          
          // Visit Type
          _buildDropdownField<ANCVisitType>(
            label: 'Visit Type',
            value: _visitType,
            items: ANCVisitType.values,
            itemLabel: (type) => type.displayName,
            onChanged: (type) {
              setState(() {
                _visitType = type!;
              });
            },
          ),
          
          // Visit Number
          _buildNumericField(
            label: 'Visit Number',
            value: _visitNumber,
            onChanged: (value) {
              setState(() {
                _visitNumber = value ?? 1;
              });
            },
            min: 1,
            max: 10,
          ),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Chief Complaints'),
          
          // Common Complaints
          _buildMultiSelectChips(
            title: 'Common Complaints',
            options: [
              'Nausea/Vomiting',
              'Abdominal Pain',
              'Headache',
              'Dizziness',
              'Fatigue',
              'Heartburn',
              'Constipation',
              'Back Pain',
              'Leg Cramps',
              'Difficulty Sleeping',
              'Frequent Urination',
              'Vaginal Discharge',
              'Bleeding',
              'Reduced Fetal Movement',
            ],
            selectedValues: _selectedComplaints,
            onChanged: (complaints) {
              setState(() {
                _selectedComplaints = complaints;
              });
            },
          ),
          
          // Additional Notes
          _buildTextField(
            controller: _complaintsNotesController,
            label: 'Additional Complaint Notes',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Physical Measurements'),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isNotEmpty == true) {
                      final weight = double.tryParse(value!);
                      if (weight == null || weight < 30 || weight > 200) {
                        return 'Enter valid weight (30-200 kg)';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _heightController,
                  label: 'Height (cm)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isNotEmpty == true) {
                      final height = double.tryParse(value!);
                      if (height == null || height < 100 || height > 250) {
                        return 'Enter valid height (100-250 cm)';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Vital Signs'),
          
          // Blood Pressure
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _systolicBPController,
                  label: 'Systolic BP (mmHg)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _diastolicBPController,
                  label: 'Diastolic BP (mmHg)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _pulseController,
                  label: 'Pulse Rate (bpm)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _temperatureController,
                  label: 'Temperature (°C)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          
          _buildTextField(
            controller: _respiratoryRateController,
            label: 'Respiratory Rate (per min)',
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('General Assessment'),
          
          _buildDropdownField<String>(
            label: 'General Condition',
            value: _generalCondition,
            items: ['Good', 'Fair', 'Poor'],
            itemLabel: (condition) => condition,
            onChanged: (condition) {
              setState(() {
                _generalCondition = condition;
              });
            },
          ),
          
          // Clinical Signs
          _buildSectionTitle('Clinical Signs'),
          _buildCheckboxTile('Pallor', _pallor, (value) {
            setState(() {
              _pallor = value!;
            });
          }),
          _buildCheckboxTile('Pedema - Feet', _pedemaFeet, (value) {
            setState(() {
              _pedemaFeet = value!;
            });
          }),
          _buildCheckboxTile('Pedema - Face', _pedemaFace, (value) {
            setState(() {
              _pedemaFace = value!;
            });
          }),
          _buildCheckboxTile('Generalized Pedema', _pedemaGeneralized, (value) {
            setState(() {
              _pedemaGeneralized = value!;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildExaminationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Obstetric Examination'),
          
          _buildTextField(
            controller: _fundalHeightController,
            label: 'Fundal Height (cm)',
            keyboardType: TextInputType.number,
          ),
          
          _buildDropdownField<FetalPresentation>(
            label: 'Fetal Presentation',
            value: _fetalPresentation,
            items: FetalPresentation.values,
            itemLabel: (presentation) => presentation.displayName,
            onChanged: (presentation) {
              setState(() {
                _fetalPresentation = presentation!;
              });
            },
          ),
          
          _buildTextField(
            controller: _fetalHRController,
            label: 'Fetal Heart Rate (bpm)',
            keyboardType: TextInputType.number,
          ),
          
          _buildTextField(
            controller: _fetalPositionController,
            label: 'Fetal Position (e.g., LOA, ROA)',
          ),
          
          _buildCheckboxTile('Fetal Movements Present', _fetalMovements, (value) {
            setState(() {
              _fetalMovements = value!;
            });
          }),
          
          if (_uterineContractions != null)
            _buildCheckboxTile('Uterine Contractions Present', _uterineContractions!, (value) {
              setState(() {
                _uterineContractions = value!;
              });
            })
          else
            ListTile(
              title: const Text('Uterine Contractions'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _uterineContractions = false;
                      });
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _uterineContractions = true;
                      });
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabTestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Blood Tests'),
          
          _buildTextField(
            controller: _hemoglobinController,
            label: 'Hemoglobin (g/dl)',
            keyboardType: TextInputType.number,
          ),
          
          Row(
            children: [
              Expanded(
                child: _buildDropdownField<String>(
                  label: 'Blood Group',
                  value: _bloodGroup,
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                  itemLabel: (group) => group,
                  onChanged: (group) {
                    setState(() {
                      _bloodGroup = group;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField<String>(
                  label: 'Rh Factor',
                  value: _rhFactor,
                  items: ['Positive', 'Negative'],
                  itemLabel: (rh) => rh,
                  onChanged: (rh) {
                    setState(() {
                      _rhFactor = rh;
                    });
                  },
                ),
              ),
            ],
          ),
          
          _buildTextField(
            controller: _bloodSugarController,
            label: 'Blood Sugar (mg/dl)',
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Screening Tests'),
          
          // HIV Test
          _buildTestSection(
            testName: 'HIV Test',
            testPerformed: _hivTest,
            result: _hivResult,
            onTestChanged: (performed) {
              setState(() {
                _hivTest = performed;
                if (!performed!) _hivResult = null;
              });
            },
            onResultChanged: (result) {
              setState(() {
                _hivResult = result;
              });
            },
            resultOptions: ['Reactive', 'Non-Reactive'],
          ),
          
          // Syphilis Test
          _buildTestSection(
            testName: 'Syphilis Test',
            testPerformed: _syphilisTest,
            result: _syphilisResult,
            onTestChanged: (performed) {
              setState(() {
                _syphilisTest = performed;
                if (!performed!) _syphilisResult = null;
              });
            },
            onResultChanged: (result) {
              setState(() {
                _syphilisResult = result;
              });
            },
            resultOptions: ['Positive', 'Negative'],
          ),
          
          // Hepatitis B Test
          _buildTestSection(
            testName: 'Hepatitis B Test',
            testPerformed: _hepatitisBTest,
            result: _hepatitisBResult,
            onTestChanged: (performed) {
              setState(() {
                _hepatitisBTest = performed;
                if (!performed!) _hepatitisBResult = null;
              });
            },
            onResultChanged: (result) {
              setState(() {
                _hepatitisBResult = result;
              });
            },
            resultOptions: ['Positive', 'Negative'],
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Urine Tests'),
          
          Row(
            children: [
              Expanded(
                child: _buildDropdownField<String>(
                  label: 'Urine Albumin',
                  value: _urineAlbumin,
                  items: ['Nil', 'Trace', '+', '++', '+++'],
                  itemLabel: (albumin) => albumin,
                  onChanged: (albumin) {
                    setState(() {
                      _urineAlbumin = albumin;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField<String>(
                  label: 'Urine Sugar',
                  value: _urineSugar,
                  items: ['Nil', 'Trace', '+', '++', '+++'],
                  itemLabel: (sugar) => sugar,
                  onChanged: (sugar) {
                    setState(() {
                      _urineSugar = sugar;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Thyroid Function'),
          
          Row(
            children: [
              Expanded(
                child: _buildCheckboxTile('TSH Test Performed', _tshTest ?? false, (value) {
                  setState(() {
                    _tshTest = value;
                    if (!value!) _tshValueController.clear();
                  });
                }),
              ),
            ],
          ),
          
          if (_tshTest == true)
            _buildTextField(
              controller: _tshValueController,
              label: 'TSH Value (mIU/L)',
              keyboardType: TextInputType.number,
            ),
        ],
      ),
    );
  }

  Widget _buildTreatmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Immunization Status'),
          
          // TT Vaccines
          _buildVaccineSection(
            vaccineName: 'TT Vaccine - 1st Dose',
            vaccineGiven: _ttVaccine1,
            vaccineDate: _ttVaccine1Date,
            onVaccineChanged: (given) {
              setState(() {
                _ttVaccine1 = given;
                if (!given!) _ttVaccine1Date = null;
              });
            },
            onDateChanged: (date) {
              setState(() {
                _ttVaccine1Date = date;
              });
            },
          ),
          
          _buildVaccineSection(
            vaccineName: 'TT Vaccine - 2nd Dose',
            vaccineGiven: _ttVaccine2,
            vaccineDate: _ttVaccine2Date,
            onVaccineChanged: (given) {
              setState(() {
                _ttVaccine2 = given;
                if (!given!) _ttVaccine2Date = null;
              });
            },
            onDateChanged: (date) {
              setState(() {
                _ttVaccine2Date = date;
              });
            },
          ),
          
          _buildVaccineSection(
            vaccineName: 'TT Booster',
            vaccineGiven: _ttBooster,
            vaccineDate: _ttBoosterDate,
            onVaccineChanged: (given) {
              setState(() {
                _ttBooster = given;
                if (!given!) _ttBoosterDate = null;
              });
            },
            onDateChanged: (date) {
              setState(() {
                _ttBoosterDate = date;
              });
            },
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Supplements & Medications'),
          
          // Iron & Folic Acid
          _buildSupplementSection(
            supplementName: 'Iron & Folic Acid Tablets',
            supplementGiven: _ironGiven,
            countController: _ironCountController,
            onSupplementChanged: (given) {
              setState(() {
                _ironGiven = given!;
                if (!given) _ironCountController.clear();
              });
            },
          ),
          
          // Calcium
          _buildSupplementSection(
            supplementName: 'Calcium Tablets',
            supplementGiven: _calciumGiven,
            countController: _calciumCountController,
            onSupplementChanged: (given) {
              setState(() {
                _calciumGiven = given!;
                if (!given) _calciumCountController.clear();
              });
            },
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Other Medications'),
          
          // Add mechanism to add/remove other medications
          _buildOtherMedications(),
        ],
      ),
    );
  }

  Widget _buildPlanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Risk Assessment'),
          
          _buildDropdownField<RiskCategory>(
            label: 'Risk Category',
            value: _riskCategory,
            items: RiskCategory.values,
            itemLabel: (risk) => risk.displayName,
            onChanged: (risk) {
              setState(() {
                _riskCategory = risk!;
              });
            },
          ),
          
          _buildMultiSelectChips(
            title: 'Risk Factors',
            options: [
              'Age < 18 or > 35',
              'Previous C-Section',
              'Previous Stillbirth',
              'Previous Preterm Birth',
              'Multiple Pregnancy',
              'High Blood Pressure',
              'Diabetes',
              'Anemia',
              'Heart Disease',
              'Kidney Disease',
              'Previous Miscarriage',
              'Bleeding Disorders',
            ],
            selectedValues: _riskFactors,
            onChanged: (factors) {
              setState(() {
                _riskFactors = factors;
              });
            },
          ),
          
          _buildTextField(
            controller: _riskNotesController,
            label: 'Risk Assessment Notes',
            maxLines: 3,
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Counseling & Education'),
          
          _buildMultiSelectChips(
            title: 'Counseling Topics Covered',
            options: [
              'Nutrition & Diet',
              'Rest & Exercise',
              'Danger Signs',
              'Birth Preparedness',
              'Breastfeeding',
              'Family Planning',
              'Immunization',
              'Personal Hygiene',
              'Iron Tablet Intake',
              'Regular Checkups',
            ],
            selectedValues: _counselingTopics,
            onChanged: (topics) {
              setState(() {
                _counselingTopics = topics;
              });
            },
          ),
          
          _buildTextField(
            controller: _counselingNotesController,
            label: 'Counseling Notes',
            maxLines: 3,
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Follow-up & Referral'),
          
          _buildDateField(
            label: 'Next Visit Date',
            value: _nextVisitDate,
            onChanged: (date) {
              setState(() {
                _nextVisitDate = date;
              });
            },
            allowClear: true,
          ),
          
          _buildDropdownField<String>(
            label: 'Referral Required',
            value: _referralRequired,
            items: ['No', 'Yes'],
            itemLabel: (referral) => referral,
            onChanged: (referral) {
              setState(() {
                _referralRequired = referral;
                if (referral == 'No') {
                  _referralTo = null;
                  _referralReasonController.clear();
                }
              });
            },
          ),
          
          if (_referralRequired == 'Yes') ...[
            _buildDropdownField<String>(
              label: 'Refer To',
              value: _referralTo,
              items: ['PHC', 'CHC', 'District Hospital', 'Medical College', 'Private Hospital'],
              itemLabel: (place) => place,
              onChanged: (place) {
                setState(() {
                  _referralTo = place;
                });
              },
            ),
            
            _buildTextField(
              controller: _referralReasonController,
              label: 'Referral Reason',
              maxLines: 2,
            ),
          ],
          
          const SizedBox(height: 16),
          _buildSectionTitle('Clinical Notes'),
          
          _buildTextField(
            controller: _clinicalNotesController,
            label: 'Clinical Notes',
            maxLines: 3,
          ),
          
          _buildTextField(
            controller: _treatmentPlanController,
            label: 'Treatment Plan',
            maxLines: 3,
          ),
          
          _buildTextField(
            controller: _specialInstructionsController,
            label: 'Special Instructions',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // Helper methods for building form components
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required Function(DateTime) onChanged,
    bool allowClear = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            onChanged(date);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (allowClear && value != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        if (label.contains('Next Visit')) {
                          _nextVisitDate = null;
                        }
                      });
                    },
                  ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
          child: Text(
            value != null 
                ? '${value.day}/${value.month}/${value.year}'
                : 'Select date',
            style: TextStyle(
              color: value != null ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumericField({
    required String label,
    required int value,
    required Function(int?) onChanged,
    int min = 0,
    int max = 1000,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value.toString(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) {
          final intVal = int.tryParse(val);
          if (intVal != null && intVal >= min && intVal <= max) {
            onChanged(intVal);
          }
        },
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel(item)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildMultiSelectChips({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                final newList = List<String>.from(selectedValues);
                if (selected) {
                  newList.add(option);
                } else {
                  newList.remove(option);
                }
                onChanged(newList);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTestSection({
    required String testName,
    required bool? testPerformed,
    required String? result,
    required Function(bool?) onTestChanged,
    required Function(String?) onResultChanged,
    required List<String> resultOptions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxTile('$testName Performed', testPerformed ?? false, onTestChanged),
        if (testPerformed == true)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: _buildDropdownField<String>(
              label: '$testName Result',
              value: result,
              items: resultOptions,
              itemLabel: (res) => res,
              onChanged: onResultChanged,
            ),
          ),
      ],
    );
  }

  Widget _buildVaccineSection({
    required String vaccineName,
    required bool? vaccineGiven,
    required DateTime? vaccineDate,
    required Function(bool?) onVaccineChanged,
    required Function(DateTime?) onDateChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxTile('$vaccineName Given', vaccineGiven ?? false, onVaccineChanged),
        if (vaccineGiven == true)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildDateField(
              label: '$vaccineName Date',
              value: vaccineDate,
              onChanged: (date) => onDateChanged(date),
            ),
          ),
      ],
    );
  }

  Widget _buildSupplementSection({
    required String supplementName,
    required bool supplementGiven,
    required TextEditingController countController,
    required Function(bool?) onSupplementChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxTile('$supplementName Given', supplementGiven, onSupplementChanged),
        if (supplementGiven)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildTextField(
              controller: countController,
              label: 'Number of Tablets',
              keyboardType: TextInputType.number,
            ),
          ),
      ],
    );
  }

  Widget _buildOtherMedications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Other Medications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton.icon(
              onPressed: _addMedication,
              icon: const Icon(Icons.add),
              label: const Text('Add Medication'),
            ),
          ],
        ),
        ..._otherMedications.map((medication) => ListTile(
          title: Text(medication),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              setState(() {
                _otherMedications.remove(medication);
              });
            },
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }

  void _selectPatient() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final pregnantPatients = dataProvider.patients.where((patient) {
      // Filter for female patients who could be pregnant
      return patient.gender == Gender.female && patient.age >= 15 && patient.age <= 50;
    }).toList();

    if (pregnantPatients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No eligible patients found. Please register pregnant patients first.'),
        ),
      );
      return;
    }

    final selectedPatient = await showDialog<Patient>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Patient'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pregnantPatients.length,
            itemBuilder: (context, index) {
              final patient = pregnantPatients[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(patient.name.isNotEmpty ? patient.name[0] : 'P'),
                ),
                title: Text(patient.name),
                subtitle: Text('ID: ${patient.id} • Age: ${patient.age}'),
                onTap: () {
                  Navigator.of(context).pop(patient);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedPatient != null) {
      setState(() {
        _selectedPatient = selectedPatient;
      });
    }
  }

  void _addMedication() async {
    final medication = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Medication'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Medication Name',
              hintText: 'Enter medication name and dosage',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.of(context).pop(controller.text);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (medication != null) {
      setState(() {
        _otherMedications.add(medication);
      });
    }
  }

  void _saveVisit() async {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient first')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    
    final visit = ANCVisit(
      id: widget.editingVisit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _selectedPatient!.id,
      patientName: _selectedPatient!.name,
      visitDate: _visitDate,
      gestationalWeeks: _gestationalWeeks,
      gestationalDays: _gestationalDays,
      trimester: _getTrimesetFromWeeks(_gestationalWeeks),
      visitType: _visitType,
      visitNumber: _visitNumber,
      complaints: _selectedComplaints,
      complaintsNotes: _complaintsNotesController.text,
      weight: double.tryParse(_weightController.text),
      height: double.tryParse(_heightController.text),
      bmi: _calculateBMI(),
      systolicBP: int.tryParse(_systolicBPController.text),
      diastolicBP: int.tryParse(_diastolicBPController.text),
      pulseRate: int.tryParse(_pulseController.text),
      temperature: double.tryParse(_temperatureController.text),
      respiratoryRate: int.tryParse(_respiratoryRateController.text),
      pallor: _pallor,
      pedemaFeet: _pedemaFeet,
      pedemaFace: _pedemaFace,
      pedemaGeneralized: _pedemaGeneralized,
      generalCondition: _generalCondition,
      fundalHeight: double.tryParse(_fundalHeightController.text),
      fetalPresentation: _fetalPresentation,
      fetalHeartRate: int.tryParse(_fetalHRController.text),
      fetalMovementsPresent: _fetalMovements,
      fetalPosition: _fetalPositionController.text.isEmpty ? null : _fetalPositionController.text,
      uterineContractionsPresent: _uterineContractions,
      hemoglobin: double.tryParse(_hemoglobinController.text),
      bloodGroup: _bloodGroup,
      rhFactor: _rhFactor,
      hivTest: _hivTest,
      hivResult: _hivResult,
      syphilisTest: _syphilisTest,
      syphilisResult: _syphilisResult,
      hepatitisBTest: _hepatitisBTest,
      hepatitisBResult: _hepatitisBResult,
      urineAlbumin: _urineAlbumin,
      urineSugar: _urineSugar,
      bloodSugar: double.tryParse(_bloodSugarController.text),
      tshTest: _tshTest,
      tshValue: double.tryParse(_tshValueController.text),
      ttVaccine1: _ttVaccine1,
      ttVaccine1Date: _ttVaccine1Date,
      ttVaccine2: _ttVaccine2,
      ttVaccine2Date: _ttVaccine2Date,
      ttBooster: _ttBooster,
      ttBoosterDate: _ttBoosterDate,
      ironFolicAcidGiven: _ironGiven,
      ironTabletCount: int.tryParse(_ironCountController.text) ?? 0,
      calciumGiven: _calciumGiven,
      calciumTabletCount: int.tryParse(_calciumCountController.text) ?? 0,
      otherMedications: _otherMedications,
      riskCategory: _riskCategory,
      riskFactors: _riskFactors,
      riskAssessmentNotes: _riskNotesController.text,
      counselingTopics: _counselingTopics,
      counselingNotes: _counselingNotesController.text,
      nextVisitDate: _nextVisitDate,
      referralRequired: _referralRequired,
      referralReason: _referralReasonController.text.isEmpty ? null : _referralReasonController.text,
      referralTo: _referralTo,
      clinicalNotes: _clinicalNotesController.text.isEmpty ? null : _clinicalNotesController.text,
      treatmentPlan: _treatmentPlanController.text.isEmpty ? null : _treatmentPlanController.text,
      specialInstructions: _specialInstructionsController.text.isEmpty ? null : _specialInstructionsController.text,
      conductedBy: authProvider.user!.id,
      conductedByName: authProvider.user!.name,
      createdAt: widget.editingVisit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save the visit
    await dataProvider.saveANCVisit(visit);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editingVisit != null 
              ? 'ANC visit updated successfully' 
              : 'ANC visit saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(visit);
    }
  }

  PregnancyTrimester _getTrimesetFromWeeks(int weeks) {
    if (weeks <= 12) return PregnancyTrimester.first;
    if (weeks <= 26) return PregnancyTrimester.second;
    return PregnancyTrimester.third;
  }

  double? _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    if (weight != null && height != null && height > 0) {
      final heightInMeters = height / 100;
      return weight / (heightInMeters * heightInMeters);
    }
    return null;
  }
}