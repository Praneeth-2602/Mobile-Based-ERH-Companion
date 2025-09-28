import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/patient.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';

class PatientRegistrationForm extends StatefulWidget {
  const PatientRegistrationForm({super.key});

  @override
  State<PatientRegistrationForm> createState() => _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<PatientRegistrationForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final _scrollController = ScrollController();
  late TabController _tabController;
  bool _showQRCode = false;
  String? _generatedPatientId;
  double _formProgress = 0.0;

  // Form field options
  static const genderOptions = [
    {'value': 'male', 'label': 'Male', 'icon': '👨'},
    {'value': 'female', 'label': 'Female', 'icon': '👩'},
    {'value': 'other', 'label': 'Other', 'icon': '👤'},
  ];
  
  static const maritalStatusOptions = [
    {'value': 'single', 'label': 'Single'},
    {'value': 'married', 'label': 'Married'},
    {'value': 'widowed', 'label': 'Widowed'},
    {'value': 'divorced', 'label': 'Divorced'},
    {'value': 'separated', 'label': 'Separated'},
  ];
  
  static const occupationOptions = [
    'Farmer', 'Agricultural Laborer', 'Daily Wage Laborer', 'Housewife / Homemaker',
    'Student', 'Child (Not Applicable)', 'Unemployed', 'Government Employee',
    'Private Sector Employee', 'Teacher', 'Shopkeeper / Small Business',
    'Driver (Auto/Truck/Tractor/Taxi)', 'Skilled Worker (Carpenter, Mason, Electrician, Plumber, etc.)',
    'Health Worker (ANM/ASHA/Other)', 'Retired', 'Elderly / Dependent', 'Other'
  ];
  
  static const bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  
  static const allergyOptions = [
    'None', 'Penicillin', 'Sulfa Drugs', 'Peanuts', 'Eggs', 'Shellfish', 'Dairy', 'Other'
  ];
  
  static const preExistingConditionOptions = [
    'Diabetes', 'Hypertension', 'Heart Disease', 'TB', 'HIV', 'Asthma', 'Cancer', 'Kidney Disease', 'Other'
  ];
  
  static const immunizationOptions = [
    'BCG', 'OPV', 'DPT', 'Measles', 'Hepatitis B', 'MMR', 'Chickenpox', 'HPV', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _formKey.currentState?.patchValue({
      'registrationDate': DateTime.now(),
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  void _calculateFormProgress() {
    if (_formKey.currentState?.value == null) return;
    final formData = _formKey.currentState!.value;
    
    final requiredFields = [
      'patientName', 'gender', 'dateOfBirth', 'phoneNumber', 'village', 
      'address', 'familyHead', 'emergencyContactName', 'emergencyContactNumber'
    ];
    
    int completedFields = 0;
    for (String field in requiredFields) {
      if (formData[field] != null && formData[field].toString().isNotEmpty) {
        completedFields++;
      }
    }
    
    setState(() {
      _formProgress = completedFields / requiredFields.length;
    });
  }

  bool _calculateHighRisk(Map<String, dynamic> formData) {
    final age = _calculateAge(formData['dateOfBirth']);
    final hasDisability = formData['hasDisability'] ?? false;
    final isPregnant = formData['isPregnant'] ?? false;
    final usesTobacco = formData['usesTobacco'] ?? false;
    final consumesAlcohol = formData['consumesAlcohol'] ?? false;
    final preExistingConditions = (formData['preExistingConditions'] as List<String>? ?? []);
    
    return age > 65 || age < 5 || hasDisability || isPregnant || 
           usesTobacco || consumesAlcohol || preExistingConditions.isNotEmpty;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      
      // Generate unique patient ID
      final patientId = 'PT-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      _generatedPatientId = patientId;
      
      // Create patient object with comprehensive data
      final patient = Patient(
        id: patientId,
        name: formData['patientName'] ?? '',
        dateOfBirth: formData['dateOfBirth'] ?? DateTime.now(),
        age: _calculateAge(formData['dateOfBirth']),
        gender: _parseGender(formData['gender']),
        maritalStatus: _parseMaritalStatus(formData['maritalStatus']),
        govtId: formData['govtId'],
        abhaId: formData['abhaId'],
        phoneNumber: formData['phoneNumber'] ?? '',
        alternateMobile: formData['alternateMobile'],
        village: formData['village'] ?? '',
        address: formData['address'] ?? '',
        familyHead: formData['familyHead'] ?? '',
        pincode: formData['pincode'],
        bloodGroup: formData['bloodGroup'],
        allergies: List<String>.from(formData['allergies'] ?? []),
        customAllergy: formData['customAllergy'],
        preExistingConditions: List<String>.from(formData['preExistingConditions'] ?? []),
        customPreExisting: formData['customPreExisting'],
        hasDisability: formData['hasDisability'] ?? false,
        disabilityType: formData['disabilityType'],
        height: formData['height']?.toDouble(),
        weight: formData['weight']?.toDouble(),
        isPregnant: formData['isPregnant'] ?? false,
        lmp: formData['lmp'],
        edd: formData['edd'],
        numberOfChildren: formData['numberOfChildren'],
        immunizationHistory: List<String>.from(formData['immunizationHistory'] ?? []),
        usesTobacco: formData['usesTobacco'] ?? false,
        consumesAlcohol: formData['consumesAlcohol'] ?? false,
        occupation: formData['occupation'],
        customOccupation: formData['customOccupation'],
        emergencyContactName: formData['emergencyContactName'] ?? '',
        emergencyContactNumber: formData['emergencyContactNumber'] ?? '',
        emergencyContactRelation: formData['emergencyContactRelation'],
        nearestHealthFacility: formData['nearestHealthFacility'],
        registeredBy: authProvider.user?.id ?? '',
        registeredByRole: authProvider.user?.role.name ?? 'ASHA',
        registrationDate: DateTime.now(),
        isHighRisk: _calculateHighRisk(formData),
      );
      
      // Add patient to data provider
      await dataProvider.addPatient(patient);
      
      setState(() {
        _showQRCode = true;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient registered successfully! ID: $patientId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Gender _parseGender(String? genderString) {
    switch (genderString?.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.female;
    }
  }

  MaritalStatus? _parseMaritalStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'single':
        return MaritalStatus.single;
      case 'married':
        return MaritalStatus.married;
      case 'widowed':
        return MaritalStatus.widowed;
      case 'divorced':
        return MaritalStatus.divorced;
      case 'separated':
        return MaritalStatus.separated;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_showQRCode && _generatedPatientId != null) {
      return _buildQRCodeView();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registration'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Form Progress',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          '${(_formProgress * 100).toInt()}%',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _formProgress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),
              // Tab Bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Basic Info'),
                  Tab(text: 'Government IDs'),
                  Tab(text: 'Contact'),
                  Tab(text: 'Health'),
                  Tab(text: 'Maternal'),
                  Tab(text: 'Emergency'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: FormBuilder(
        key: _formKey,
        onChanged: _calculateFormProgress,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildGovernmentIdsTab(),
            _buildContactTab(),
            _buildHealthTab(),
            _buildMaternalTab(),
            _buildEmergencyTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_tabController.index > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _tabController.animateTo(_tabController.index - 1);
                  },
                  child: const Text('Previous'),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (_tabController.index < 5) {
                    _tabController.animateTo(_tabController.index + 1);
                  } else {
                    _submitForm();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_tabController.index < 5 ? 'Next' : 'Register Patient'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tab building methods
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Personal Information', Icons.person),
          const SizedBox(height: 16),
          
          // Patient Name
          _buildTextField(
            'patientName',
            'Patient Name *',
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 16),
          
          // Gender
          _buildLabel('Gender *'),
          const SizedBox(height: 8),
          FormBuilderRadioGroup<String>(
            name: 'gender',
            validator: FormBuilderValidators.required(),
            options: genderOptions.map((option) => 
              FormBuilderFieldOption(
                value: option['value']!,
                child: Text(option['label']!),
              )).toList(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 16),
          
          // Date of Birth
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildDateField(
                  'dateOfBirth',
                  'Date of Birth *',
                  validator: FormBuilderValidators.required(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'age',
                  'Age (Years)',
                  enabled: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Marital Status and Blood Group
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'maritalStatus',
                  'Marital Status',
                  maritalStatusOptions.map((e) => e['value']!).toList(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  'bloodGroup',
                  'Blood Group',
                  bloodGroupOptions,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGovernmentIdsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Government IDs', Icons.credit_card),
          const SizedBox(height: 16),
          
          _buildTextField(
            'govtId',
            'Government ID (Aadhaar/Voter ID/PAN)',
            hintText: 'Enter Aadhaar or other government ID',
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'abhaId',
            'ABHA ID',
            hintText: '14-digit Ayushman Bharat Health Account ID',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Contact Information', Icons.phone),
          const SizedBox(height: 16),
          
          // Mobile Numbers
          _buildTextField(
            'phoneNumber',
            'Mobile Number *',
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.match(RegExp(r'^[0-9]{10}$'), errorText: 'Enter valid 10-digit mobile number'),
            ]),
            keyboardType: TextInputType.phone,
            hintText: '10-digit mobile number',
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'alternateMobile',
            'Alternate Mobile',
            keyboardType: TextInputType.phone,
            hintText: 'Alternate contact number',
          ),
          const SizedBox(height: 16),
          
          // Address Details
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'village',
                  'Village/Area *',
                  validator: FormBuilderValidators.required(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'pincode',
                  'PIN Code',
                  keyboardType: TextInputType.number,
                  hintText: '6-digit PIN code',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'address',
            'Full Address *',
            validator: FormBuilderValidators.required(),
            maxLines: 3,
            hintText: 'Complete address with landmarks',
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'familyHead',
            'Family Head Name *',
            validator: FormBuilderValidators.required(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Health & Medical Information', Icons.medical_services),
          const SizedBox(height: 16),
          
          // Multi-select allergies
          _buildLabel('Known Allergies'),
          const SizedBox(height: 8),
          FormBuilderCheckboxGroup<String>(
            name: 'allergies',
            options: allergyOptions.map((option) => 
              FormBuilderFieldOption(value: option, child: Text(option))).toList(),
            wrapSpacing: 8,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            'customAllergy',
            'Other Allergy (specify)',
            hintText: 'Specify other allergies',
          ),
          const SizedBox(height: 16),
          
          // Pre-existing conditions
          _buildLabel('Pre-existing Medical Conditions'),
          const SizedBox(height: 8),
          FormBuilderCheckboxGroup<String>(
            name: 'preExistingConditions',
            options: preExistingConditionOptions.map((option) => 
              FormBuilderFieldOption(value: option, child: Text(option))).toList(),
            wrapSpacing: 8,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            'customPreExisting',
            'Other Condition (specify)',
            hintText: 'Specify other medical conditions',
          ),
          const SizedBox(height: 16),
          
          // Disability
          _buildLabel('Disability'),
          const SizedBox(height: 8),
          FormBuilderRadioGroup<bool>(
            name: 'hasDisability',
            options: const [
              FormBuilderFieldOption(value: false, child: Text('No')),
              FormBuilderFieldOption(value: true, child: Text('Yes')),
            ],
          ),
          const SizedBox(height: 8),
          FormBuilderTextField(
            name: 'disabilityType',
            decoration: const InputDecoration(
              labelText: 'Type of Disability',
              hintText: 'Specify type of disability',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Physical measurements
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'height',
                  'Height (cm)',
                  keyboardType: TextInputType.number,
                  hintText: 'Height in centimeters',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'weight',
                  'Weight (kg)',
                  keyboardType: TextInputType.number,
                  hintText: 'Weight in kilograms',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Lifestyle factors
          _buildLabel('Lifestyle & Risk Factors'),
          const SizedBox(height: 8),
          FormBuilderCheckbox(
            name: 'usesTobacco',
            title: const Text('Uses Tobacco'),
            initialValue: false,
          ),
          FormBuilderCheckbox(
            name: 'consumesAlcohol',
            title: const Text('Consumes Alcohol'),
            initialValue: false,
          ),
          const SizedBox(height: 16),
          
          // Occupation
          _buildDropdown(
            'occupation',
            'Occupation',
            occupationOptions,
          ),
          const SizedBox(height: 8),
          FormBuilderTextField(
            name: 'customOccupation',
            decoration: const InputDecoration(
              labelText: 'Custom Occupation',
              hintText: 'Specify if occupation is Other',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaternalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Maternal & Child Health', Icons.child_care),
          const SizedBox(height: 16),
          
          Text(
            'Note: This section is applicable for females',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Pregnancy status
          FormBuilderCheckbox(
            name: 'isPregnant',
            title: const Text('Currently Pregnant'),
            initialValue: false,
          ),
          const SizedBox(height: 16),
          
          // LMP and EDD
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'lmp',
                  'Last Menstrual Period (LMP)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  'edd',
                  'Expected Date of Delivery (EDD)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'numberOfChildren',
            'Number of Children',
            keyboardType: TextInputType.number,
            hintText: 'Total number of children',
          ),
          const SizedBox(height: 16),
          
          // Immunization History
          _buildLabel('Immunization History'),
          const SizedBox(height: 8),
          FormBuilderCheckboxGroup<String>(
            name: 'immunizationHistory',
            options: immunizationOptions.map((option) => 
              FormBuilderFieldOption(value: option, child: Text(option))).toList(),
            wrapSpacing: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Emergency Information', Icons.emergency),
          const SizedBox(height: 16),
          
          _buildTextField(
            'emergencyContactName',
            'Emergency Contact Name *',
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  'emergencyContactNumber',
                  'Emergency Contact Number *',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.match(RegExp(r'^[0-9]{10}$'), errorText: 'Enter valid 10-digit mobile number'),
                  ]),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'emergencyContactRelation',
                  'Relation',
                  hintText: 'e.g., Father, Spouse',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'nearestHealthFacility',
            'Nearest Health Facility',
            hintText: 'Name of nearest PHC/CHC/Hospital',
          ),
          const SizedBox(height: 24),
          
          // Registration details (read-only)
          _buildSectionHeader('Registration Details', Icons.badge),
          const SizedBox(height: 16),
          
          _buildTextField(
            'registeredBy',
            'Registered By',
            initialValue: Provider.of<AuthProvider>(context, listen: false).user?.name ?? '',
            enabled: false,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'registrationDate',
            'Registration Date',
            initialValue: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            enabled: false,
          ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField(
    String name,
    String label, {
    String? hintText,
    String? initialValue,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey.shade100 : null,
      ),
      initialValue: initialValue,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (value) => _calculateFormProgress(),
    );
  }

  Widget _buildDropdown(
    String name,
    String label,
    List<String> options, {
    String? Function(String?)? validator,
  }) {
    return FormBuilderDropdown<String>(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      onChanged: (value) => _calculateFormProgress(),
      items: options
          .map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              ))
          .toList(),
    );
  }

  Widget _buildDateField(
    String name,
    String label, {
    String? Function(DateTime?)? validator,
  }) {
    return FormBuilderDateTimePicker(
      name: name,
      inputType: InputType.date,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: validator,
      lastDate: DateTime.now(),
      firstDate: DateTime(1920),
      onChanged: (DateTime? value) {
        if (value != null && name == 'dateOfBirth') {
          _formKey.currentState?.patchValue({
            'age': _calculateAge(value).toString(),
          });
        }
        _calculateFormProgress();
      },
    );
  }

  Widget _buildQRCodeView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Complete'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Patient Registered Successfully!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Patient ID: $_generatedPatientId',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_generatedPatientId != null)
                      QrImageView(
                        data: _generatedPatientId!,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan this QR code for quick patient lookup',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _showQRCode = false;
                          _generatedPatientId = null;
                          _formProgress = 0.0;
                        });
                        _formKey.currentState?.reset();
                        _tabController.animateTo(0);
                      },
                      child: const Text('Register Another'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}