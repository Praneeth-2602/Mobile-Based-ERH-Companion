import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/patient.dart';
import 'patient_registration_form.dart';

class PatientListScreen extends StatefulWidget {
  final String? initialFilter; // 'high-risk', 'normal', or null for all
  final String? initialSearch;
  
  const PatientListScreen({
    super.key, 
    this.initialFilter,
    this.initialSearch,
  });

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  String _searchQuery = '';
  String _filterRisk = 'All'; // All, High Risk, Normal
  
  @override
  void initState() {
    super.initState();
    
    // Set initial values from widget parameters
    if (widget.initialSearch != null) {
      _searchQuery = widget.initialSearch!;
    }
    
    if (widget.initialFilter == 'high-risk') {
      _filterRisk = 'High Risk';
    } else if (widget.initialFilter == 'normal') {
      _filterRisk = 'Normal';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    // Filter patients based on user role and search criteria
    List<Patient> patients = dataProvider.patients;
    
    // Filter by ASHA worker if the user is ASHA
    if (user?.role.name == 'ASHA') {
      patients = dataProvider.getPatientsByAshaId(user?.id ?? '');
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      patients = patients.where((patient) =>
        patient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        patient.phoneNumber.contains(_searchQuery) ||
        patient.village.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Apply risk filter
    if (_filterRisk == 'High Risk') {
      patients = patients.where((patient) => patient.isHighRisk).toList();
    } else if (_filterRisk == 'Normal') {
      patients = patients.where((patient) => !patient.isHighRisk).toList();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _navigateToPatientRegistration(context),
            icon: const Icon(Icons.person_add),
            tooltip: 'Register New Patient',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, or village...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filter Chips
                Row(
                  children: [
                    const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    ...['All', 'High Risk', 'Normal'].map((filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _filterRisk == filter,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _filterRisk = filter;
                            });
                          }
                        },
                        selectedColor: theme.primaryColor.withOpacity(0.2),
                        checkmarkColor: theme.primaryColor,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
          
          // Patients Count
          if (patients.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${patients.length} patient${patients.length == 1 ? '' : 's'} found',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          // Patients List
          Expanded(
            child: patients.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return _buildPatientCard(context, patient);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _filterRisk != 'All' 
                ? 'No patients match your search criteria' 
                : 'No patients registered yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _filterRisk != 'All'
                ? 'Try adjusting your search or filters'
                : 'Start by registering your first patient',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty && _filterRisk == 'All')
            ElevatedButton.icon(
              onPressed: () => _navigateToPatientRegistration(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Register New Patient'),
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
  
  Widget _buildPatientCard(BuildContext context, Patient patient) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showPatientDetails(context, patient),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Patient Avatar
                  CircleAvatar(
                    backgroundColor: patient.isHighRisk 
                        ? Colors.red[100] 
                        : theme.primaryColor.withOpacity(0.1),
                    child: Text(
                      patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                      style: TextStyle(
                        color: patient.isHighRisk 
                            ? Colors.red[700] 
                            : theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Patient Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                patient.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (patient.isHighRisk)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Text(
                                  'HIGH RISK',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${patient.id} • Age: ${patient.age} • ${patient.gender.displayName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Contact & Location Info
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      patient.phoneNumber,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      patient.village,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              
              // Last Visit Info
              if (patient.lastVisit != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Last visit: ${_formatDate(patient.lastVisit!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (patient.nextDue != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.event, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Next: ${_formatDate(patient.nextDue!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _isOverdue(patient.nextDue!) ? Colors.red[600] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  bool _isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }
  
  void _showPatientDetails(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patient.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient ID', patient.id),
              _buildDetailRow('Age', '${patient.age} years'),
              _buildDetailRow('Gender', patient.gender.displayName),
              if (patient.maritalStatus != null)
                _buildDetailRow('Marital Status', patient.maritalStatus!.displayName),
              _buildDetailRow('Phone', patient.phoneNumber),
              _buildDetailRow('Village', patient.village),
              _buildDetailRow('Address', patient.address),
              _buildDetailRow('Family Head', patient.familyHead),
              if (patient.abhaId != null)
                _buildDetailRow('ABHA ID', patient.abhaId!),
              if (patient.bloodGroup != null)
                _buildDetailRow('Blood Group', patient.bloodGroup!),
              if (patient.allergies.isNotEmpty)
                _buildDetailRow('Allergies', patient.allergies.join(', ')),
              if (patient.preExistingConditions.isNotEmpty)
                _buildDetailRow('Medical Conditions', patient.preExistingConditions.join(', ')),
              _buildDetailRow('High Risk', patient.isHighRisk ? 'Yes' : 'No'),
              _buildDetailRow('Emergency Contact', '${patient.emergencyContactName} (${patient.emergencyContactNumber})'),
              _buildDetailRow('Registered By', patient.registeredBy),
              _buildDetailRow('Registration Date', _formatDate(patient.registrationDate)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  void _navigateToPatientRegistration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PatientRegistrationForm(),
      ),
    );
  }
}