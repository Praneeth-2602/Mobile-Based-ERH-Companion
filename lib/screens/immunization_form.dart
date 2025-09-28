import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../models/immunization.dart';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';

class ImmunizationForm extends StatefulWidget {
  final Patient? selectedPatient;
  final ImmunizationRecord? editingRecord;

  const ImmunizationForm({
    super.key,
    this.selectedPatient,
    this.editingRecord,
  });

  @override
  State<ImmunizationForm> createState() => _ImmunizationFormState();
}

class _ImmunizationFormState extends State<ImmunizationForm>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  int _currentTabIndex = 0;

  // Controllers
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();
  final TextEditingController _doseVolumeController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _consentGivenByController = TextEditingController();
  final TextEditingController _adverseEventNotesController = TextEditingController();
  final TextEditingController _nextVaccineNotesController = TextEditingController();
  final TextEditingController _storageTemperatureController = TextEditingController();
  final TextEditingController _vvmStatusController = TextEditingController();
  final TextEditingController _sessionIdController = TextEditingController();
  final TextEditingController _facilityNameController = TextEditingController();

  // Form state variables
  Patient? _selectedPatient;
  DateTime _vaccinationDate = DateTime.now();
  VaccineType _vaccineType = VaccineType.bcg;
  VaccineManufacturer _manufacturer = VaccineManufacturer.sii;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));
  int _doseNumber = 1;
  int _totalDosesRequired = 1;
  VaccinationStatus _status = VaccinationStatus.given;
  String _administrationSite = 'Left upper arm';
  String _administrationRoute = 'Intramuscular';
  List<String> _contraindications = [];
  bool _consentGiven = true;
  String _relationshipToPatient = 'Self';
  AdverseEventSeverity _adverseEventSeverity = AdverseEventSeverity.none;
  List<String> _adverseEvents = [];
  DateTime? _adverseEventOnsetTime;
  bool _adverseEventReported = false;
  DateTime? _nextDueDate;
  VaccineType? _nextVaccineType;
  bool _followUpRequired = false;
  DateTime? _followUpDate;
  bool _coldChainMaintained = true;
  bool _openVialDiscarded = true;
  String _programType = 'Routine';
  bool _isCatchUp = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    // Initialize with selected patient or editing record
    if (widget.selectedPatient != null) {
      _selectedPatient = widget.selectedPatient;
    }

    if (widget.editingRecord != null) {
      _initializeFromExistingRecord(widget.editingRecord!);
    } else {
      // Set default facility name
      _facilityNameController.text = 'Primary Health Center';
      _sessionIdController.text = 'SESSION_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void _initializeFromExistingRecord(ImmunizationRecord record) {
    _vaccinationDate = record.vaccinationDate;
    _vaccineType = record.vaccineType;
    _vaccineNameController.text = record.vaccineName;
    _manufacturer = record.manufacturer;
    _batchNumberController.text = record.batchNumber;
    _expiryDate = record.expiryDate;
    _doseNumber = record.doseNumber;
    _totalDosesRequired = record.totalDosesRequired;
    _status = record.status;
    _administrationSite = record.administrationSite;
    _administrationRoute = record.administrationRoute;
    _doseVolumeController.text = record.doseVolume.toString();
    _facilityNameController.text = record.facilityName;
    _contraindications = List.from(record.contraindications);
    _medicalHistoryController.text = record.medicalHistory;
    _consentGiven = record.consentGiven;
    _consentGivenByController.text = record.consentGivenBy;
    _relationshipToPatient = record.relationshipToPatient;
    _adverseEventSeverity = record.adverseEventSeverity;
    _adverseEvents = List.from(record.adverseEvents);
    _adverseEventNotesController.text = record.adverseEventNotes;
    _adverseEventOnsetTime = record.adverseEventOnsetTime;
    _adverseEventReported = record.adverseEventReported;
    _nextDueDate = record.nextDueDate;
    _nextVaccineType = record.nextVaccineType;
    _nextVaccineNotesController.text = record.nextVaccineNotes ?? '';
    _followUpRequired = record.followUpRequired;
    _followUpDate = record.followUpDate;
    if (record.storageTemperature != null) {
      _storageTemperatureController.text = record.storageTemperature!.toString();
    }
    _coldChainMaintained = record.coldChainMaintained;
    _vvmStatusController.text = record.vvmStatus ?? '';
    _openVialDiscarded = record.openVialDiscarded;
    _sessionIdController.text = record.sessionId;
    _programType = record.programType;
    _isCatchUp = record.isCatchUp;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vaccineNameController.dispose();
    _batchNumberController.dispose();
    _doseVolumeController.dispose();
    _medicalHistoryController.dispose();
    _consentGivenByController.dispose();
    _adverseEventNotesController.dispose();
    _nextVaccineNotesController.dispose();
    _storageTemperatureController.dispose();
    _vvmStatusController.dispose();
    _sessionIdController.dispose();
    _facilityNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingRecord != null ? 'Edit Immunization' : 'New Immunization'),
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
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                                color: Colors.white.withValues(alpha: 0.8),
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
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                  value: (_currentTabIndex + 1) / 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
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
                      Tab(text: 'Vaccine'),
                      Tab(text: 'Administration'),
                      Tab(text: 'Consent & Medical'),
                      Tab(text: 'Adverse Events'),
                      Tab(text: 'Quality & Follow-up'),
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
                        _buildVaccineTab(),
                        _buildAdministrationTab(),
                        _buildConsentMedicalTab(),
                        _buildAdverseEventsTab(),
                        _buildQualityFollowUpTab(),
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
                    color: Colors.grey.withValues(alpha: 0.1),
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
                      onPressed: _currentTabIndex == 4 ? _saveImmunization : () {
                        _tabController.animateTo(_currentTabIndex + 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_currentTabIndex == 4 ? 'Save Record' : 'Next'),
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
            Icons.vaccines,
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
            'Choose a patient to record immunization',
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

  Widget _buildVaccineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Vaccine Information'),
          
          _buildDateField(
            label: 'Vaccination Date',
            value: _vaccinationDate,
            onChanged: (date) {
              setState(() {
                _vaccinationDate = date;
                _updateNextDueDate();
              });
            },
          ),
          
          _buildDropdownField<VaccineType>(
            label: 'Vaccine Type',
            value: _vaccineType,
            items: VaccineType.values,
            itemLabel: (type) => '${type.code} - ${type.displayName}',
            onChanged: (type) {
              setState(() {
                _vaccineType = type!;
                _updateVaccineDefaults();
                _updateNextDueDate();
              });
            },
          ),
          
          _buildTextField(
            controller: _vaccineNameController,
            label: 'Vaccine Brand/Name',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter vaccine name';
              }
              return null;
            },
          ),
          
          _buildDropdownField<VaccineManufacturer>(
            label: 'Manufacturer',
            value: _manufacturer,
            items: VaccineManufacturer.values,
            itemLabel: (manufacturer) => manufacturer.displayName,
            onChanged: (manufacturer) {
              setState(() {
                _manufacturer = manufacturer!;
              });
            },
          ),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _batchNumberController,
                  label: 'Batch Number',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter batch number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'Expiry Date',
                  value: _expiryDate,
                  onChanged: (date) {
                    setState(() {
                      _expiryDate = date;
                    });
                  },
                ),
              ),
            ],
          ),
          
          Row(
            children: [
              Expanded(
                child: _buildNumericField(
                  label: 'Dose Number',
                  value: _doseNumber,
                  onChanged: (value) {
                    setState(() {
                      _doseNumber = value ?? 1;
                      _updateNextDueDate();
                    });
                  },
                  min: 1,
                  max: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumericField(
                  label: 'Total Doses Required',
                  value: _totalDosesRequired,
                  onChanged: (value) {
                    setState(() {
                      _totalDosesRequired = value ?? 1;
                    });
                  },
                  min: 1,
                  max: 10,
                ),
              ),
            ],
          ),
          
          _buildDropdownField<VaccinationStatus>(
            label: 'Status',
            value: _status,
            items: VaccinationStatus.values,
            itemLabel: (status) => status.displayName,
            onChanged: (status) {
              setState(() {
                _status = status!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Administration Details'),
          
          _buildDropdownField<String>(
            label: 'Administration Site',
            value: _administrationSite,
            items: [
              'Left upper arm',
              'Right upper arm',
              'Left thigh',
              'Right thigh',
              'Left deltoid',
              'Right deltoid',
              'Oral',
            ],
            itemLabel: (site) => site,
            onChanged: (site) {
              setState(() {
                _administrationSite = site!;
              });
            },
          ),
          
          _buildDropdownField<String>(
            label: 'Administration Route',
            value: _administrationRoute,
            items: [
              'Intramuscular',
              'Subcutaneous',
              'Intradermal',
              'Oral',
              'Intranasal',
            ],
            itemLabel: (route) => route,
            onChanged: (route) {
              setState(() {
                _administrationRoute = route!;
              });
            },
          ),
          
          _buildTextField(
            controller: _doseVolumeController,
            label: 'Dose Volume (ml)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter dose volume';
              }
              final volume = double.tryParse(value!);
              if (volume == null || volume <= 0) {
                return 'Enter valid volume';
              }
              return null;
            },
          ),
          
          _buildTextField(
            controller: _facilityNameController,
            label: 'Facility Name',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter facility name';
              }
              return null;
            },
          ),
          
          _buildTextField(
            controller: _sessionIdController,
            label: 'Session ID',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter session ID';
              }
              return null;
            },
          ),
          
          _buildDropdownField<String>(
            label: 'Program Type',
            value: _programType,
            items: ['Routine', 'Campaign', 'Outbreak Response', 'Catch-up'],
            itemLabel: (program) => program,
            onChanged: (program) {
              setState(() {
                _programType = program!;
                _isCatchUp = program == 'Catch-up';
              });
            },
          ),
          
          _buildCheckboxTile('Catch-up Vaccination', _isCatchUp, (value) {
            setState(() {
              _isCatchUp = value!;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildConsentMedicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Consent Information'),
          
          _buildCheckboxTile('Consent Given', _consentGiven, (value) {
            setState(() {
              _consentGiven = value!;
            });
          }),
          
          if (_consentGiven) ...[
            _buildTextField(
              controller: _consentGivenByController,
              label: 'Consent Given By',
              validator: (value) {
                if (_consentGiven && (value?.isEmpty ?? true)) {
                  return 'Please enter who gave consent';
                }
                return null;
              },
            ),
            
            _buildDropdownField<String>(
              label: 'Relationship to Patient',
              value: _relationshipToPatient,
              items: ['Self', 'Parent', 'Guardian', 'Spouse', 'Other'],
              itemLabel: (relationship) => relationship,
              onChanged: (relationship) {
                setState(() {
                  _relationshipToPatient = relationship!;
                });
              },
            ),
          ],
          
          const SizedBox(height: 20),
          _buildSectionTitle('Medical Information'),
          
          _buildMultiSelectChips(
            title: 'Contraindications',
            options: [
              'Severe illness',
              'High fever',
              'Immunocompromised',
              'Previous severe reaction',
              'Allergy to vaccine components',
              'Pregnancy',
              'Recent blood transfusion',
              'Recent immunoglobulin',
              'Previous encephalitis',
              'Bleeding disorders',
            ],
            selectedValues: _contraindications,
            onChanged: (contraindications) {
              setState(() {
                _contraindications = contraindications;
              });
            },
          ),
          
          _buildTextField(
            controller: _medicalHistoryController,
            label: 'Relevant Medical History',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildAdverseEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Adverse Events Following Immunization (AEFI)'),
          
          _buildDropdownField<AdverseEventSeverity>(
            label: 'Severity',
            value: _adverseEventSeverity,
            items: AdverseEventSeverity.values,
            itemLabel: (severity) => '${severity.code.toUpperCase()} - ${severity.displayName}',
            onChanged: (severity) {
              setState(() {
                _adverseEventSeverity = severity!;
              });
            },
          ),
          
          if (_adverseEventSeverity != AdverseEventSeverity.none) ...[
            _buildMultiSelectChips(
              title: 'Adverse Events',
              options: [
                'Local pain',
                'Local swelling',
                'Local redness',
                'Fever <38.5°C',
                'Fever 38.5-39.5°C',
                'Fever >39.5°C',
                'Irritability',
                'Crying',
                'Loss of appetite',
                'Vomiting',
                'Diarrhea',
                'Rash',
                'Allergic reaction',
                'Seizures',
                'Encephalitis',
                'Other',
              ],
              selectedValues: _adverseEvents,
              onChanged: (events) {
                setState(() {
                  _adverseEvents = events;
                });
              },
            ),
            
            _buildTextField(
              controller: _adverseEventNotesController,
              label: 'Adverse Event Details',
              maxLines: 3,
            ),
            
            _buildDateTimeField(
              label: 'Onset Time',
              value: _adverseEventOnsetTime,
              onChanged: (dateTime) {
                setState(() {
                  _adverseEventOnsetTime = dateTime;
                });
              },
              allowClear: true,
            ),
            
            _buildCheckboxTile('Adverse Event Reported to Authorities', _adverseEventReported, (value) {
              setState(() {
                _adverseEventReported = value!;
              });
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildQualityFollowUpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Quality Assurance'),
          
          _buildTextField(
            controller: _storageTemperatureController,
            label: 'Storage Temperature (°C)',
            keyboardType: TextInputType.number,
          ),
          
          _buildCheckboxTile('Cold Chain Maintained', _coldChainMaintained, (value) {
            setState(() {
              _coldChainMaintained = value!;
            });
          }),
          
          _buildTextField(
            controller: _vvmStatusController,
            label: 'VVM Status (Vaccine Vial Monitor)',
          ),
          
          _buildCheckboxTile('Open Vial Discarded (if applicable)', _openVialDiscarded, (value) {
            setState(() {
              _openVialDiscarded = value!;
            });
          }),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Follow-up & Next Vaccine'),
          
          if (_nextDueDate != null) ...[
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Next Due Date (Calculated)'),
              subtitle: Text(_formatDate(_nextDueDate!)),
              contentPadding: EdgeInsets.zero,
            ),
          ],
          
          _buildDateField(
            label: 'Custom Next Due Date (Optional)',
            value: null,
            onChanged: (date) {
              setState(() {
                _nextDueDate = date;
              });
            },
            allowClear: true,
          ),
          
          if (_nextVaccineType != null) ...[
            ListTile(
              leading: const Icon(Icons.vaccines),
              title: const Text('Next Vaccine (Suggested)'),
              subtitle: Text('${_nextVaccineType!.code} - ${_nextVaccineType!.displayName}'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
          
          _buildTextField(
            controller: _nextVaccineNotesController,
            label: 'Next Vaccine Notes',
            maxLines: 2,
          ),
          
          _buildCheckboxTile('Follow-up Required', _followUpRequired, (value) {
            setState(() {
              _followUpRequired = value!;
            });
          }),
          
          if (_followUpRequired) ...[
            _buildDateField(
              label: 'Follow-up Date',
              value: _followUpDate,
              onChanged: (date) {
                setState(() {
                  _followUpDate = date;
                });
              },
              allowClear: true,
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods
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
            firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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
                        if (label.contains('Next Due')) {
                          _nextDueDate = null;
                        } else if (label.contains('Follow-up')) {
                          _followUpDate = null;
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
                ? _formatDate(value)
                : 'Select date',
            style: TextStyle(
              color: value != null ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
    bool allowClear = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value?.toLocal() ?? DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 7)),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            if (!context.mounted) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
            );
            if (time != null) {
              final dateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
              onChanged(dateTime);
            }
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
                    onPressed: () => onChanged(null),
                  ),
                const Icon(Icons.access_time),
              ],
            ),
          ),
          child: Text(
            value != null 
                ? '${_formatDate(value)} ${_formatTime(value)}'
                : 'Select date & time',
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
            child: Text(
              itemLabel(item),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _selectPatient() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final allPatients = dataProvider.patients;

    if (allPatients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No patients found. Please register patients first.'),
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
            itemCount: allPatients.length,
            itemBuilder: (context, index) {
              final patient = allPatients[index];
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
        _consentGivenByController.text = selectedPatient.age >= 18 
            ? selectedPatient.name 
            : selectedPatient.familyHead;
        _relationshipToPatient = selectedPatient.age >= 18 ? 'Self' : 'Parent';
      });
    }
  }

  void _updateVaccineDefaults() {
    // Set default values based on vaccine type
    switch (_vaccineType) {
      case VaccineType.bcg:
        _vaccineNameController.text = 'BCG Vaccine';
        _doseVolumeController.text = '0.05';
        _totalDosesRequired = 1;
        _administrationSite = 'Left upper arm';
        _administrationRoute = 'Intradermal';
        break;
      case VaccineType.dpt:
        _vaccineNameController.text = 'DPT Vaccine';
        _doseVolumeController.text = '0.5';
        _totalDosesRequired = 5; // Primary 3 + 2 boosters
        _administrationSite = 'Left thigh';
        _administrationRoute = 'Intramuscular';
        break;
      case VaccineType.opv:
        _vaccineNameController.text = 'OPV';
        _doseVolumeController.text = '2';
        _totalDosesRequired = 4; // Birth dose + 3 primary + booster
        _administrationSite = 'Oral';
        _administrationRoute = 'Oral';
        break;
      case VaccineType.measles:
        _vaccineNameController.text = 'Measles Vaccine';
        _doseVolumeController.text = '0.5';
        _totalDosesRequired = 2;
        _administrationSite = 'Left upper arm';
        _administrationRoute = 'Subcutaneous';
        break;
      case VaccineType.tetanusToxoid:
        _vaccineNameController.text = 'Tetanus Toxoid';
        _doseVolumeController.text = '0.5';
        _totalDosesRequired = 2;
        _administrationSite = 'Left upper arm';
        _administrationRoute = 'Intramuscular';
        break;
      default:
        _vaccineNameController.text = _vaccineType.displayName;
        _doseVolumeController.text = '0.5';
        _totalDosesRequired = 1;
        _administrationSite = 'Left upper arm';
        _administrationRoute = 'Intramuscular';
    }
  }

  void _updateNextDueDate() {
    if (_selectedPatient == null) return;
    
    // Calculate birth date from patient age (approximate)
    final birthDate = DateTime.now().subtract(Duration(days: _selectedPatient!.age * 365));
    
    // Get next due date from schedule
    final nextDue = VaccineSchedule.getNextDueDate(_vaccineType, _doseNumber, birthDate);
    
    setState(() {
      _nextDueDate = nextDue;
      
      // Also suggest next vaccine type (simplified logic)
      if (_doseNumber < _totalDosesRequired) {
        _nextVaccineType = _vaccineType; // Same vaccine, next dose
      } else {
        _nextVaccineType = null; // Complete series
      }
    });
  }

  void _saveImmunization() async {
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
    
    final record = ImmunizationRecord(
      id: widget.editingRecord?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _selectedPatient!.id,
      patientName: _selectedPatient!.name,
      patientAge: _selectedPatient!.age,
      vaccinationDate: _vaccinationDate,
      vaccineType: _vaccineType,
      vaccineName: _vaccineNameController.text,
      manufacturer: _manufacturer,
      batchNumber: _batchNumberController.text,
      expiryDate: _expiryDate,
      doseNumber: _doseNumber,
      totalDosesRequired: _totalDosesRequired,
      status: _status,
      administrationSite: _administrationSite,
      administrationRoute: _administrationRoute,
      doseVolume: double.tryParse(_doseVolumeController.text) ?? 0.5,
      vaccinatorId: authProvider.user!.id,
      vaccinatorName: authProvider.user!.name,
      facilityName: _facilityNameController.text,
      contraindications: _contraindications,
      medicalHistory: _medicalHistoryController.text,
      consentGiven: _consentGiven,
      consentGivenBy: _consentGivenByController.text,
      relationshipToPatient: _relationshipToPatient,
      adverseEventSeverity: _adverseEventSeverity,
      adverseEvents: _adverseEvents,
      adverseEventNotes: _adverseEventNotesController.text,
      adverseEventOnsetTime: _adverseEventOnsetTime,
      adverseEventReported: _adverseEventReported,
      nextDueDate: _nextDueDate,
      nextVaccineType: _nextVaccineType,
      nextVaccineNotes: _nextVaccineNotesController.text.isEmpty ? null : _nextVaccineNotesController.text,
      followUpRequired: _followUpRequired,
      followUpDate: _followUpDate,
      storageTemperature: double.tryParse(_storageTemperatureController.text),
      coldChainMaintained: _coldChainMaintained,
      vvmStatus: _vvmStatusController.text.isEmpty ? null : _vvmStatusController.text,
      openVialDiscarded: _openVialDiscarded,
      sessionId: _sessionIdController.text,
      programType: _programType,
      isCatchUp: _isCatchUp,
      createdAt: widget.editingRecord?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save the record
    await dataProvider.saveImmunizationRecord(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editingRecord != null 
              ? 'Immunization record updated successfully' 
              : 'Immunization record saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(record);
    }
  }
}