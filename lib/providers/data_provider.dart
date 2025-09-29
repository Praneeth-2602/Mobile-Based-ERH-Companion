import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import '../services/isar_service.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../models/dashboard_stats.dart';
import '../models/anc_visit.dart';
import '../models/immunization.dart';
import '../services/cloud_sync_service.dart';
import '../models/user.dart';
import '../models/asha_task.dart';
import '../models/verification_issue.dart';

class DataProvider extends ChangeNotifier {
  List<Patient> _patients = [];
  List<Visit> _visits = [];
  List<ANCVisit> _ancVisits = [];
  List<ImmunizationRecord> _immunizationRecords = [];
  List<Reminder> _reminders = [];
  DashboardStats _dashboardStats = DashboardStats.empty;
  // Workforce and tasking
  final List<User> _ashaWorkers = [];
  final List<AshaTask> _ashaTasks = [];
  final Set<String> _resolvedIssueIds = {};
  final Set<String> _escalatedIssueIds = {};
  
  // Cloud sync properties
  final CloudApiService _cloudService = CloudApiService();
  final Map<String, SyncMetadata> _syncMetadata = {};
  bool _isLoading = false;
  bool _hasConnectivity = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  SyncSummary? _lastSyncSummary;

  List<Patient> get patients => _patients;
  List<Visit> get visits => _visits;
  List<ANCVisit> get ancVisits => _ancVisits;
  List<ImmunizationRecord> get immunizationRecords => _immunizationRecords;
  List<Reminder> get reminders => _reminders;
  DashboardStats get dashboardStats => _dashboardStats;
  List<User> get ashaWorkers => _ashaWorkers;
  List<AshaTask> get ashaTasks => _ashaTasks;
  bool get isLoading => _isLoading;
  bool get hasConnectivity => _hasConnectivity;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  SyncSummary? get lastSyncSummary => _lastSyncSummary;

  DataProvider() {
    _initializeData();
    _monitorConnectivity();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loaded = await _loadFromLocal();
      if (!loaded) {
        await _loadMockData();
        await _persistAllToLocal();
      }
      await _calculateDashboardStats();
    } catch (e) {
      debugPrint('Error initializing data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load from Isar local DB; returns true if any domain data found
  Future<bool> _loadFromLocal() async {
    try {
      final patientRecords = await IsarService.getAll('patient');
      final ancRecords = await IsarService.getAll('anc_visit');
      final immRecords = await IsarService.getAll('immunization');
      final visitRecords = await IsarService.getAll('visit');
      final reminderRecords = await IsarService.getAll('reminder');

      final hasAny = patientRecords.isNotEmpty || ancRecords.isNotEmpty || immRecords.isNotEmpty || visitRecords.isNotEmpty || reminderRecords.isNotEmpty;
      if (!hasAny) return false;

      _patients = [
        for (final r in patientRecords)
          Patient.fromJson(jsonDecode(r.json) as Map<String, dynamic>)
      ];
      _ancVisits = [
        for (final r in ancRecords)
          ANCVisit.fromJson(jsonDecode(r.json) as Map<String, dynamic>)
      ];
      _immunizationRecords = [
        for (final r in immRecords)
          ImmunizationRecord.fromJson(jsonDecode(r.json) as Map<String, dynamic>)
      ];
      _visits = [
        for (final r in visitRecords)
          Visit.fromJson(jsonDecode(r.json) as Map<String, dynamic>)
      ];
      _reminders = [
        for (final r in reminderRecords)
          Reminder.fromJson(jsonDecode(r.json) as Map<String, dynamic>)
      ];

      return true;
    } catch (e) {
      debugPrint('Error loading from local DB: $e');
      return false;
    }
  }

  Future<void> _persistAllToLocal() async {
    try {
      for (final p in _patients) {
        await IsarService.put('patient', p.id, jsonEncode(p.toJson()));
      }
      for (final v in _ancVisits) {
        await IsarService.put('anc_visit', v.id, jsonEncode(v.toJson()));
      }
      for (final r in _immunizationRecords) {
        await IsarService.put('immunization', r.id, jsonEncode(r.toJson()));
      }
      for (final v in _visits) {
        await IsarService.put('visit', v.id, jsonEncode(v.toJson()));
      }
      for (final r in _reminders) {
        await IsarService.put('reminder', r.id, jsonEncode(r.toJson()));
      }
    } catch (e) {
      debugPrint('Error persisting all to local DB: $e');
    }
  }

  void _monitorConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _hasConnectivity = connectivityResult.contains(ConnectivityResult.mobile) || 
                      connectivityResult.contains(ConnectivityResult.wifi);
    notifyListeners();

    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _hasConnectivity = result.contains(ConnectivityResult.mobile) || 
                        result.contains(ConnectivityResult.wifi);
      notifyListeners();
    });
  }

  Future<void> _loadMockData() async {
    // Mock patients data
    _patients = [
      Patient(
        id: 'pat-001',
        name: 'Sunita Devi',
        dateOfBirth: DateTime(1996, 5, 15),
        age: 28,
        gender: Gender.female,
        maritalStatus: MaritalStatus.married,
        phoneNumber: '+91 9876543220',
        village: 'Rampur',
        address: 'Ward 3, Rampur Village',
        familyHead: 'Ramesh Kumar',
        emergencyContactName: 'Ramesh Kumar',
        emergencyContactNumber: '+91 9876543219',
        registeredBy: 'asha-001',
        registeredByRole: 'ASHA',
        registrationDate: DateTime(2024, 8, 15),
        isHighRisk: true,
        lastVisit: DateTime(2024, 9, 20),
        nextDue: DateTime(2024, 9, 30),
        abhaId: 'ABHA-001-2024',
        isPregnant: true,
        preExistingConditions: ['Anemia'],
      ),
      Patient(
        id: 'pat-002',
        name: 'Ravi Kumar',
        dateOfBirth: DateTime(1989, 3, 20),
        age: 35,
        gender: Gender.male,
        maritalStatus: MaritalStatus.married,
        phoneNumber: '',
        village: 'Rampur',
        address: 'Ward 2, Rampur Village',
        familyHead: 'Ravi Kumar',
        emergencyContactName: 'Sunita Kumar',
        emergencyContactNumber: '+91 9876543220',
        registeredBy: 'asha-002',
        registeredByRole: 'ASHA',
        registrationDate: DateTime(2024, 7, 10),
        isHighRisk: false,
        lastVisit: DateTime(2024, 9, 15),
        nextDue: DateTime(2024, 10, 15),
        occupation: 'Farmer',
        usesTobacco: false,
        consumesAlcohol: false,
      ),
      Patient(
        id: 'pat-003',
        name: 'Mamta Singh',
        dateOfBirth: DateTime(2002, 1, 10),
        age: 22,
        gender: Gender.female,
        maritalStatus: MaritalStatus.single,
        phoneNumber: '+91 9876543222',
        village: 'Rampur',
        address: 'Ward 1, Rampur Village',
        familyHead: 'Mohan Singh',
        emergencyContactName: 'Mohan Singh',
        emergencyContactNumber: '+91 9876543223',
        registeredBy: 'asha-001',
        registeredByRole: 'ASHA',
        registrationDate: DateTime(2024, 9, 1),
        isHighRisk: true,
        lastVisit: DateTime(2024, 9, 25),
        nextDue: DateTime(2024, 10, 5),
        preExistingConditions: ['Asthma'],
        allergies: ['Penicillin'],
      ),
    ];

    // Mock visits data
    _visits = [
      Visit(
        id: 'visit-001',
        patientId: 'pat-001',
        patientName: 'Sunita Devi',
        ashaId: 'asha-001',
        ashaName: 'Priya Sharma',
        type: VisitType.anc,
        dateTime: DateTime(2024, 9, 20),
        notes: 'Regular ANC checkup. Blood pressure normal.',
        vitals: {
          'bloodPressure': '120/80',
          'weight': '65',
          'hemoglobin': '11.2',
        },
        symptoms: ['Mild nausea'],
        treatment: 'Iron tablets prescribed',
        nextVisitDue: DateTime(2024, 10, 20),
        isCompleted: true,
        isHighPriority: false,
      ),
      Visit(
        id: 'visit-002',
        patientId: 'pat-003',
        patientName: 'Mamta Singh',
        ashaId: 'asha-001',
        ashaName: 'Priya Sharma',
        type: VisitType.immunization,
        dateTime: DateTime(2024, 9, 25),
        notes: 'Tetanus vaccination administered',
        isCompleted: true,
        isHighPriority: false,
      ),
    ];

    // Mock reminders data
    _reminders = [
      Reminder(
        id: 'rem-001',
        patientId: 'pat-001',
        patientName: 'Sunita Devi',
        title: 'ANC Follow-up',
        description: 'Third trimester checkup due',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        isCompleted: false,
        isHighPriority: true,
        relatedVisitType: VisitType.anc,
      ),
      Reminder(
        id: 'rem-002',
        patientId: 'pat-002',
        patientName: 'Ravi Kumar',
        title: 'Blood Sugar Check',
        description: 'Monthly diabetes monitoring',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        isCompleted: false,
        isHighPriority: false,
        relatedVisitType: VisitType.generalCheckup,
      ),
    ];

    // Mock ASHA workers list for PHC management
    _ashaWorkers.clear();
    _ashaWorkers.addAll([
      User(
        id: 'asha-001',
        name: 'Priya Sharma',
        role: UserRole.asha,
        village: 'Rampur',
        phoneNumber: '+91 9876543210',
        pin: '1234',
        isOnline: true,
        lastSync: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      User(
        id: 'asha-002',
        name: 'Kavita Yadav',
        role: UserRole.asha,
        village: 'Rampur',
        phoneNumber: '+91 9876543213',
        pin: '0000',
        isOnline: false,
        lastSync: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);

    _syncMetadata.clear();
    _syncMetadata.addAll({
      'pat-001': SyncMetadata(
        localId: 'pat-001',
        cloudId: 'cloud-pat-001',
        createdAt: _patients.first.registrationDate,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: SyncStatus.synced,
      ),
      'pat-002': SyncMetadata(
        localId: 'pat-002',
        createdAt: _patients[1].registrationDate,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        lastSyncAt: DateTime.now().subtract(const Duration(minutes: 45)),
        status: SyncStatus.conflict,
        errorMessage: 'Cloud ABHA ID mismatch. Review patient identifiers.',
      ),
      'visit-001': SyncMetadata(
        localId: 'visit-001',
        createdAt: DateTime(2024, 9, 20, 9, 30),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: SyncStatus.conflict,
        errorMessage: 'Vitals updated on device but cloud still shows older values.',
      ),
    });
  }

  Future<void> _calculateDashboardStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final visitsToday = _visits.where((visit) {
      final visitDate = DateTime(visit.dateTime.year, visit.dateTime.month, visit.dateTime.day);
      return visitDate.isAtSameMomentAs(today);
    }).length;

    final completedVisits = _visits.where((visit) => visit.isCompleted).length;
    final upcomingVisits = _reminders.where((reminder) => 
        !reminder.isCompleted && reminder.dueDate.isAfter(now)).length;
    final overdueVisits = _reminders.where((reminder) => 
        !reminder.isCompleted && reminder.dueDate.isBefore(now)).length;
    final highRiskPatients = _patients.where((patient) => patient.isHighRisk).length;

    _dashboardStats = DashboardStats(
      totalPatients: _patients.length,
      visitsToday: visitsToday,
      pendingTasks: _reminders.where((r) => !r.isCompleted).length,
      highRiskPatients: highRiskPatients,
      completedVisits: completedVisits,
      upcomingVisits: upcomingVisits,
      overdueVisits: overdueVisits,
      activeCases: _patients.where((p) => p.isHighRisk).length,
      syncProgress: _hasConnectivity ? 1.0 : 0.0,
      hasConnectivity: _hasConnectivity,
    );
  }

  // CRUD operations for patients
  Future<void> addPatient(Patient patient) async {
    _patients.add(patient);
    // persist
    await IsarService.put('patient', patient.id, jsonEncode(patient.toJson()));
    await _calculateDashboardStats();
    notifyListeners();
  }

  Future<void> updatePatient(Patient patient) async {
    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      _patients[index] = patient;
      await IsarService.put('patient', patient.id, jsonEncode(patient.toJson()));
      await _calculateDashboardStats();
      notifyListeners();
    }
  }

  Future<void> deletePatient(String patientId) async {
    _patients.removeWhere((p) => p.id == patientId);
    _visits.removeWhere((v) => v.patientId == patientId);
    _reminders.removeWhere((r) => r.patientId == patientId);
    await IsarService.delete('patient', patientId);
    await _calculateDashboardStats();
    notifyListeners();
  }

  // CRUD operations for visits
  Future<void> addVisit(Visit visit) async {
    _visits.add(visit);
    await IsarService.put('visit', visit.id, jsonEncode(visit.toJson()));
    await _calculateDashboardStats();
    notifyListeners();
  }

  Future<void> updateVisit(Visit visit) async {
    final index = _visits.indexWhere((v) => v.id == visit.id);
    if (index != -1) {
      _visits[index] = visit;
      await IsarService.put('visit', visit.id, jsonEncode(visit.toJson()));
      await _calculateDashboardStats();
      notifyListeners();
    }
  }

  // Reminder operations
  Future<void> completeReminder(String reminderId) async {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = Reminder(
        id: _reminders[index].id,
        patientId: _reminders[index].patientId,
        patientName: _reminders[index].patientName,
        title: _reminders[index].title,
        description: _reminders[index].description,
        dueDate: _reminders[index].dueDate,
        isCompleted: true,
        isHighPriority: _reminders[index].isHighPriority,
        relatedVisitType: _reminders[index].relatedVisitType,
      );
      await IsarService.put('reminder', _reminders[index].id, jsonEncode(_reminders[index].toJson()));
      await _calculateDashboardStats();
      notifyListeners();
    }
  }

  // Filter methods
  List<Patient> getPatientsByAshaId(String ashaId) {
    return _patients.where((patient) => patient.registeredBy == ashaId).toList();
  }

  List<Visit> getVisitsByAshaId(String ashaId) {
    return _visits.where((visit) => visit.ashaId == ashaId).toList();
  }

  List<Reminder> getTodayReminders() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    return _reminders.where((reminder) => 
        !reminder.isCompleted &&
        reminder.dueDate.isAfter(todayStart) &&
        reminder.dueDate.isBefore(todayEnd)).toList();
  }

  List<Reminder> getOverdueReminders() {
    final now = DateTime.now();
    return _reminders.where((reminder) => 
        !reminder.isCompleted && reminder.dueDate.isBefore(now)).toList();
  }

  // Sync operations
  Future<void> syncData() async {
    if (!_hasConnectivity) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate sync operation
      await Future.delayed(const Duration(seconds: 2));
      
      await _calculateDashboardStats();
    } catch (e) {
      debugPrint('Sync error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await _initializeData();
  }

  // ========== PHC: ASHA Tasking ==========
  List<AshaTask> getTasksByAshaId(String ashaId) =>
      _ashaTasks.where((t) => t.assignedAshaId == ashaId).toList()
        ..sort((a, b) => (a.dueDate ?? DateTime(2100)).compareTo(b.dueDate ?? DateTime(2100)));

  void assignTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    required String ashaId,
    required String ashaName,
    String? patientId,
    String? patientName,
    required String createdByUserId,
    required String createdByName,
  }) {
    final task = AshaTask(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      status: TaskStatus.assigned,
      assignedAshaId: ashaId,
      assignedAshaName: ashaName,
      patientId: patientId,
      patientName: patientName,
      createdByUserId: createdByUserId,
      createdByName: createdByName,
      createdAt: DateTime.now(),
    );
    _ashaTasks.add(task);
    notifyListeners();
  }

  void updateTaskStatus(String taskId, TaskStatus status) {
    final idx = _ashaTasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final completedAt = status == TaskStatus.completed ? DateTime.now() : null;
    _ashaTasks[idx] = _ashaTasks[idx].copyWith(status: status, completedAt: completedAt);
    notifyListeners();
  }

  void reassignTask(String taskId, {required String ashaId, required String ashaName}) {
    final idx = _ashaTasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _ashaTasks[idx] = _ashaTasks[idx].copyWith(assignedAshaId: ashaId, assignedAshaName: ashaName);
    notifyListeners();
  }

  User? _findWorkerById(String? ashaId) {
    if (ashaId == null) return null;
    try {
      return _ashaWorkers.firstWhere((w) => w.id == ashaId);
    } catch (_) {
      return null;
    }
  }

  bool isIssueResolved(String issueId) => _resolvedIssueIds.contains(issueId);

  bool isIssueEscalated(String issueId) => _escalatedIssueIds.contains(issueId);

  // ========== PHC: Data verification helpers ==========
  List<VerificationIssue> getConflictIssues({bool includeResolved = false}) {
    final issues = <VerificationIssue>[];

    for (final patient in _patients) {
      final metadata = _syncMetadata[patient.id];
      if (metadata?.status == SyncStatus.conflict) {
        final issueId = 'conflict-patient-${patient.id}';
        if (!includeResolved && isIssueResolved(issueId)) continue;
        final worker = _findWorkerById(patient.registeredBy);
        final detectedAt = metadata?.lastSyncAt ?? metadata?.updatedAt ?? DateTime.now();
        issues.add(VerificationIssue(
          id: issueId,
          type: IssueType.conflict,
          recordType: VerificationRecordType.patient,
          recordId: patient.id,
          title: 'Patient conflict: ${patient.name}',
          description: metadata?.errorMessage ?? 'Mismatch detected between local device and cloud data.',
          severity: IssueSeverity.high,
          patientId: patient.id,
          patientName: patient.name,
          ashaId: patient.registeredBy,
          ashaName: worker?.name,
          detectedAt: detectedAt,
          metadata: {
            'status': metadata?.status.name,
            'errorMessage': metadata?.errorMessage,
            'resolved': isIssueResolved(issueId),
            'escalated': isIssueEscalated(issueId),
            'lastSyncAt': metadata?.lastSyncAt?.toIso8601String(),
          },
        ));
      }
    }

    for (final visit in _visits) {
      final metadata = _syncMetadata[visit.id];
      if (metadata?.status == SyncStatus.conflict) {
        final issueId = 'conflict-visit-${visit.id}';
        if (!includeResolved && isIssueResolved(issueId)) continue;
        final worker = _findWorkerById(visit.ashaId);
        final detectedAt = metadata?.lastSyncAt ?? metadata?.updatedAt ?? DateTime.now();
        issues.add(VerificationIssue(
          id: issueId,
          type: IssueType.conflict,
          recordType: VerificationRecordType.ancVisit,
          recordId: visit.id,
          title: 'ANC visit conflict: ${visit.patientName}',
          description: metadata?.errorMessage ?? 'Visit data differs from cloud copy. Verify vitals and notes.',
          severity: IssueSeverity.medium,
          patientId: visit.patientId,
          patientName: visit.patientName,
          ashaId: visit.ashaId,
          ashaName: worker?.name ?? visit.ashaName,
          detectedAt: detectedAt,
          metadata: {
            'status': metadata?.status.name,
            'visitDate': visit.dateTime.toIso8601String(),
            'errorMessage': metadata?.errorMessage,
            'resolved': isIssueResolved(issueId),
            'escalated': isIssueEscalated(issueId),
          },
        ));
      }
    }

    for (final record in _immunizationRecords) {
      final metadata = _syncMetadata[record.id];
      if (metadata?.status == SyncStatus.conflict) {
        final issueId = 'conflict-immunization-${record.id}';
        if (!includeResolved && isIssueResolved(issueId)) continue;
        final worker = _findWorkerById(record.vaccinatorId);
        final detectedAt = metadata?.lastSyncAt ?? metadata?.updatedAt ?? DateTime.now();
        issues.add(VerificationIssue(
          id: issueId,
          type: IssueType.conflict,
          recordType: VerificationRecordType.immunization,
          recordId: record.id,
          title: 'Immunization conflict: ${record.patientName}',
          description: metadata?.errorMessage ?? 'Vaccination record differs from cloud entry.',
          severity: IssueSeverity.medium,
          patientId: record.patientId,
          patientName: record.patientName,
          ashaId: record.vaccinatorId,
          ashaName: worker?.name ?? record.vaccinatorName,
          detectedAt: detectedAt,
          metadata: {
            'status': metadata?.status.name,
            'vaccine': record.vaccineType.displayName,
            'errorMessage': metadata?.errorMessage,
            'resolved': isIssueResolved(issueId),
            'escalated': isIssueEscalated(issueId),
          },
        ));
      }
    }

    issues.sort((a, b) {
      final severityCompare = b.severity.index.compareTo(a.severity.index);
      if (severityCompare != 0) return severityCompare;
      return b.detectedAt.compareTo(a.detectedAt);
    });

    return issues;
  }

  List<VerificationIssue> getIncompleteIssues({bool includeResolved = false}) {
    final issues = <VerificationIssue>[];

    for (final patient in _patients) {
      if (patient.phoneNumber.trim().isEmpty) {
        final issueId = 'incomplete-patient-${patient.id}-contact';
        if (!includeResolved && isIssueResolved(issueId)) {
          // skip
        } else {
          final worker = _findWorkerById(patient.registeredBy);
          issues.add(VerificationIssue(
            id: issueId,
            type: IssueType.incomplete,
            recordType: VerificationRecordType.patient,
            recordId: patient.id,
            title: 'Missing contact: ${patient.name}',
            description: 'Phone number is missing for ${patient.name}. Update contact details.',
            severity: IssueSeverity.medium,
            patientId: patient.id,
            patientName: patient.name,
            ashaId: patient.registeredBy,
            ashaName: worker?.name,
            detectedAt: DateTime.now(),
            metadata: {
              'field': 'phoneNumber',
              'resolved': isIssueResolved(issueId),
              'escalated': isIssueEscalated(issueId),
            },
          ));
        }
      }

      if (patient.isPregnant && (patient.lmp == null || patient.edd == null)) {
        final issueId = 'incomplete-patient-${patient.id}-mch';
        if (!includeResolved && isIssueResolved(issueId)) continue;
        final worker = _findWorkerById(patient.registeredBy);
        issues.add(VerificationIssue(
          id: issueId,
          type: IssueType.incomplete,
          recordType: VerificationRecordType.patient,
          recordId: patient.id,
          title: 'Pregnancy milestones missing: ${patient.name}',
          description: 'Expected delivery or LMP dates are not captured for ${patient.name}.',
          severity: IssueSeverity.high,
          patientId: patient.id,
          patientName: patient.name,
          ashaId: patient.registeredBy,
          ashaName: worker?.name,
          detectedAt: DateTime.now(),
          metadata: {
            'field': 'pregnancyTimeline',
            'resolved': isIssueResolved(issueId),
            'escalated': isIssueEscalated(issueId),
          },
        ));
      }
    }

    for (final visit in _ancVisits) {
      if (visit.systolicBP == null || visit.diastolicBP == null) {
        final issueId = 'incomplete-visit-${visit.id}-bp';
        if (!includeResolved && isIssueResolved(issueId)) continue;
        final worker = _findWorkerById(visit.conductedBy);
        issues.add(VerificationIssue(
          id: issueId,
          type: IssueType.incomplete,
          recordType: VerificationRecordType.ancVisit,
          recordId: visit.id,
          title: 'ANC BP missing: ${visit.patientName}',
          description: 'Blood pressure readings are missing for the ANC visit on ${visit.visitDate.toLocal().toIso8601String().substring(0, 10)}.',
          severity: IssueSeverity.medium,
          patientId: visit.patientId,
          patientName: visit.patientName,
          ashaId: visit.conductedBy,
          ashaName: worker?.name ?? visit.conductedByName,
          detectedAt: DateTime.now(),
          metadata: {
            'field': 'bloodPressure',
            'resolved': isIssueResolved(issueId),
            'escalated': isIssueEscalated(issueId),
          },
        ));
      }

      if (visit.hemoglobin == null) {
        final issueId = 'incomplete-visit-${visit.id}-hb';
        if (!includeResolved && isIssueResolved(issueId)) continue;
        final worker = _findWorkerById(visit.conductedBy);
        issues.add(VerificationIssue(
          id: issueId,
          type: IssueType.incomplete,
          recordType: VerificationRecordType.ancVisit,
          recordId: visit.id,
          title: 'ANC Hb missing: ${visit.patientName}',
          description: 'Hemoglobin value is missing for ${visit.patientName}\'s ANC visit.',
          severity: IssueSeverity.low,
          patientId: visit.patientId,
          patientName: visit.patientName,
          ashaId: visit.conductedBy,
          ashaName: worker?.name ?? visit.conductedByName,
          detectedAt: DateTime.now(),
          metadata: {
            'field': 'hemoglobin',
            'resolved': isIssueResolved(issueId),
            'escalated': isIssueEscalated(issueId),
          },
        ));
      }
    }

    for (final record in _immunizationRecords) {
      if (record.batchNumber.trim().isEmpty || record.vaccinatorId.trim().isEmpty) {
        final issueId = 'incomplete-immunization-${record.id}-fields';
        if (!includeResolved && isIssueResolved(issueId)) continue;
        final worker = _findWorkerById(record.vaccinatorId);
        issues.add(VerificationIssue(
          id: issueId,
          type: IssueType.incomplete,
          recordType: VerificationRecordType.immunization,
          recordId: record.id,
          title: 'Immunization details missing: ${record.patientName}',
          description: 'Batch number or vaccinator ID is missing for ${record.vaccineType.displayName}.',
          severity: IssueSeverity.medium,
          patientId: record.patientId,
          patientName: record.patientName,
          ashaId: record.vaccinatorId,
          ashaName: worker?.name ?? record.vaccinatorName,
          detectedAt: DateTime.now(),
          metadata: {
            'field': 'batchOrVaccinator',
            'resolved': isIssueResolved(issueId),
            'escalated': isIssueEscalated(issueId),
          },
        ));
      }
    }

    issues.sort((a, b) {
      final severityCompare = b.severity.index.compareTo(a.severity.index);
      if (severityCompare != 0) return severityCompare;
      return b.detectedAt.compareTo(a.detectedAt);
    });

    return issues;
  }

  VerificationIssue? getIssueById(String issueId) {
    final combined = <VerificationIssue>[
      ...getConflictIssues(includeResolved: true),
      ...getIncompleteIssues(includeResolved: true),
    ];
    try {
      return combined.firstWhere((issue) => issue.id == issueId);
    } catch (_) {
      return null;
    }
  }

  void markIssueResolved(String issueId) {
    if (_resolvedIssueIds.add(issueId)) {
      notifyListeners();
    }
  }

  void reopenIssue(String issueId) {
    if (_resolvedIssueIds.remove(issueId)) {
      notifyListeners();
    }
  }

  void escalateIssue(String issueId) {
    if (_escalatedIssueIds.add(issueId)) {
      notifyListeners();
    }
  }

  void deescalateIssue(String issueId) {
    if (_escalatedIssueIds.remove(issueId)) {
      notifyListeners();
    }
  }

  void assignFollowUpFromIssue(
    VerificationIssue issue, {
    required String createdByUserId,
    required String createdByName,
    String? overrideAshaId,
    String? overrideAshaName,
    String? notes,
    DateTime? dueDate,
    TaskPriority? priority,
  }) {
    final fallbackWorker = _ashaWorkers.isNotEmpty ? _ashaWorkers.first : null;
    final assignedId = overrideAshaId ?? issue.ashaId ?? fallbackWorker?.id;
    final assignedName = overrideAshaName ?? issue.ashaName ?? _findWorkerById(assignedId)?.name ?? fallbackWorker?.name;
    if (assignedId == null || assignedName == null) return;

    assignTask(
      title: 'Resolve: ${issue.title}',
      description: notes ?? issue.description,
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 2)),
      priority: priority ?? (issue.severity == IssueSeverity.high ? TaskPriority.high : TaskPriority.medium),
      ashaId: assignedId,
      ashaName: assignedName,
      patientId: issue.patientId,
      patientName: issue.patientName,
      createdByUserId: createdByUserId,
      createdByName: createdByName,
    );
  }

  // ANC Visit Management
  Future<void> saveANCVisit(ANCVisit visit) async {
    try {
      _isLoading = true;
      notifyListeners();

      final existingIndex = _ancVisits.indexWhere((v) => v.id == visit.id);
      if (existingIndex >= 0) {
        _ancVisits[existingIndex] = visit;
      } else {
        _ancVisits.add(visit);
      }

      // Persist
      await IsarService.put('anc_visit', visit.id, jsonEncode(visit.toJson()));

      // Update dashboard stats
      await _calculateDashboardStats();

      // TODO: Sync with server when connected
      if (_hasConnectivity) {
        // await _syncANCVisitToServer(visit);
      }
    } catch (e) {
      debugPrint('Error saving ANC visit: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ANCVisit> getANCVisitsByPatient(String patientId) {
    return _ancVisits.where((visit) => visit.patientId == patientId).toList()
      ..sort((a, b) => b.visitDate.compareTo(a.visitDate));
  }

  List<ANCVisit> getANCVisitsByAshaId(String ashaId) {
    return _ancVisits.where((visit) => visit.conductedBy == ashaId).toList()
      ..sort((a, b) => b.visitDate.compareTo(a.visitDate));
  }

  ANCVisit? getLatestANCVisitForPatient(String patientId) {
    final visits = getANCVisitsByPatient(patientId);
    return visits.isNotEmpty ? visits.first : null;
  }

  List<ANCVisit> getHighRiskANCVisits() {
    return _ancVisits.where((visit) => visit.isHighRiskPregnancy).toList();
  }

  List<ANCVisit> getANCVisitsNeedingFollowUp() {
    final now = DateTime.now();
    return _ancVisits.where((visit) {
      return visit.nextVisitDate != null && 
             visit.nextVisitDate!.isBefore(now.add(const Duration(days: 7)));
    }).toList();
  }

  Future<void> deleteANCVisit(String visitId) async {
    try {
      _ancVisits.removeWhere((visit) => visit.id == visitId);
      await IsarService.delete('anc_visit', visitId);
      await _calculateDashboardStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting ANC visit: $e');
      rethrow;
    }
  }

  // Immunization Record Management
  Future<void> saveImmunizationRecord(ImmunizationRecord record) async {
    try {
      _isLoading = true;
      notifyListeners();

      final existingIndex = _immunizationRecords.indexWhere((r) => r.id == record.id);
      if (existingIndex >= 0) {
        _immunizationRecords[existingIndex] = record;
      } else {
        _immunizationRecords.add(record);
      }

      // Persist
      await IsarService.put('immunization', record.id, jsonEncode(record.toJson()));

      // Update dashboard stats
      await _calculateDashboardStats();

      // TODO: Sync with server when connected
      if (_hasConnectivity) {
        // await _syncImmunizationToServer(record);
      }
    } catch (e) {
      debugPrint('Error saving immunization record: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ImmunizationRecord> getImmunizationsByPatient(String patientId) {
    return _immunizationRecords.where((record) => record.patientId == patientId).toList()
      ..sort((a, b) => b.vaccinationDate.compareTo(a.vaccinationDate));
  }

  List<ImmunizationRecord> getImmunizationsByVaccinator(String vaccinatorId) {
    return _immunizationRecords.where((record) => record.vaccinatorId == vaccinatorId).toList()
      ..sort((a, b) => b.vaccinationDate.compareTo(a.vaccinationDate));
  }

  List<ImmunizationRecord> getOverdueImmunizations() {
    final now = DateTime.now();
    return _immunizationRecords.where((record) {
      return record.nextDueDate != null && 
             record.nextDueDate!.isBefore(now) &&
             record.status == VaccinationStatus.scheduled;
    }).toList();
  }

  List<ImmunizationRecord> getUpcomingImmunizations(int days) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    return _immunizationRecords.where((record) {
      return record.nextDueDate != null && 
             record.nextDueDate!.isAfter(now) &&
             record.nextDueDate!.isBefore(future);
    }).toList();
  }

  List<ImmunizationRecord> getImmunizationsWithAdverseEvents() {
    return _immunizationRecords.where((record) => record.hasAdverseEvents).toList();
  }

  List<ImmunizationRecord> getImmunizationsByVaccineType(VaccineType vaccineType) {
    return _immunizationRecords.where((record) => record.vaccineType == vaccineType).toList();
  }

  Map<VaccineType, int> getImmunizationCoverage() {
    final coverage = <VaccineType, int>{};
    for (final record in _immunizationRecords) {
      if (record.status == VaccinationStatus.given) {
        coverage[record.vaccineType] = (coverage[record.vaccineType] ?? 0) + 1;
      }
    }
    return coverage;
  }

  Future<void> deleteImmunizationRecord(String recordId) async {
    try {
      _immunizationRecords.removeWhere((record) => record.id == recordId);
      await IsarService.delete('immunization', recordId);
      await _calculateDashboardStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting immunization record: $e');
      rethrow;
    }
  }

  // Cloud Sync Methods
  
  /// Authenticate with cloud service
  Future<bool> authenticateCloudService(String username, String password) async {
    try {
      return await _cloudService.authenticate(username, password);
    } catch (e) {
      debugPrint('Cloud authentication error: $e');
      return false;
    }
  }

  /// Check network connectivity and cloud service availability
  Future<bool> checkCloudConnectivity() async {
    try {
      final isConnected = await _cloudService.checkConnectivity();
      _hasConnectivity = isConnected;
      notifyListeners();
      return isConnected;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      _hasConnectivity = false;
      notifyListeners();
      return false;
    }
  }

  /// Get sync status for a record
  SyncStatus getSyncStatus(String recordId) {
    final metadata = _syncMetadata[recordId];
    return metadata?.status ?? SyncStatus.pending;
  }

  /// Get sync metadata for a record
  SyncMetadata? getSyncMetadata(String recordId) {
    return _syncMetadata[recordId];
  }

  /// Update sync metadata for a record
  void _updateSyncMetadata(String recordId, SyncMetadata metadata) {
    _syncMetadata[recordId] = metadata;
    notifyListeners();
  }

  /// Sync all pending records to cloud
  Future<SyncSummary> syncAllToCloud() async {
    if (_isSyncing) {
      return _lastSyncSummary ?? SyncSummary(
        totalRecords: 0,
        syncedRecords: 0,
        failedRecords: 0,
        conflictedRecords: 0,
        errors: ['Sync already in progress'],
        syncTime: DateTime.now(),
      );
    }

    _isSyncing = true;
    notifyListeners();

    final errors = <String>[];
    int totalRecords = 0;
    int syncedRecords = 0;
    int failedRecords = 0;
    int conflictedRecords = 0;

    try {
      // Check connectivity first
      if (!await checkCloudConnectivity()) {
        errors.add('No network connectivity');
        failedRecords = _patients.length + _ancVisits.length + _immunizationRecords.length;
        totalRecords = failedRecords;
      } else {
        // Sync patients
        final patientsToSync = _patients.where((p) => 
          getSyncStatus(p.id) == SyncStatus.pending || 
          getSyncStatus(p.id) == SyncStatus.failed
        ).toList();
        
        totalRecords += patientsToSync.length;
        
        for (final patient in patientsToSync) {
          try {
            _updateSyncMetadata(patient.id, _syncMetadata[patient.id]?.copyWith(
              status: SyncStatus.syncing,
            ) ?? SyncMetadata(
              localId: patient.id,
              createdAt: patient.registrationDate,
              updatedAt: DateTime.now(),
              status: SyncStatus.syncing,
            ));

            final currentMetadata = _syncMetadata[patient.id];
            final result = await _cloudService.syncPatient(
              patient,
              cloudId: currentMetadata?.cloudId,
            );

            if (result.isSuccess) {
              _updateSyncMetadata(patient.id, currentMetadata!.copyWith(
                cloudId: result.data,
                status: SyncStatus.synced,
                lastSyncAt: DateTime.now(),
                errorMessage: null,
                retryCount: 0,
              ));
              syncedRecords++;
            } else if (result.isConflict) {
              _updateSyncMetadata(patient.id, currentMetadata!.copyWith(
                status: SyncStatus.conflict,
                errorMessage: result.error,
              ));
              conflictedRecords++;
              errors.add('Patient conflict: ${result.error}');
            } else {
              _updateSyncMetadata(patient.id, currentMetadata!.copyWith(
                status: SyncStatus.failed,
                errorMessage: result.error,
                retryCount: currentMetadata.retryCount + 1,
              ));
              failedRecords++;
              errors.add('Patient sync failed: ${result.error}');
            }
          } catch (e) {
            failedRecords++;
            errors.add('Patient sync error: $e');
          }
        }

        // Sync ANC visits
        final ancVisitsToSync = _ancVisits.where((v) => 
          getSyncStatus(v.id) == SyncStatus.pending || 
          getSyncStatus(v.id) == SyncStatus.failed
        ).toList();
        
        totalRecords += ancVisitsToSync.length;
        
        for (final visit in ancVisitsToSync) {
          try {
            _updateSyncMetadata(visit.id, _syncMetadata[visit.id]?.copyWith(
              status: SyncStatus.syncing,
            ) ?? SyncMetadata(
              localId: visit.id,
              createdAt: visit.createdAt,
              updatedAt: DateTime.now(),
              status: SyncStatus.syncing,
            ));

            final currentMetadata = _syncMetadata[visit.id];
            final result = await _cloudService.syncANCVisit(
              visit,
              cloudId: currentMetadata?.cloudId,
            );

            if (result.isSuccess) {
              _updateSyncMetadata(visit.id, currentMetadata!.copyWith(
                cloudId: result.data,
                status: SyncStatus.synced,
                lastSyncAt: DateTime.now(),
                errorMessage: null,
                retryCount: 0,
              ));
              syncedRecords++;
            } else if (result.isConflict) {
              _updateSyncMetadata(visit.id, currentMetadata!.copyWith(
                status: SyncStatus.conflict,
                errorMessage: result.error,
              ));
              conflictedRecords++;
              errors.add('ANC visit conflict: ${result.error}');
            } else {
              _updateSyncMetadata(visit.id, currentMetadata!.copyWith(
                status: SyncStatus.failed,
                errorMessage: result.error,
                retryCount: currentMetadata.retryCount + 1,
              ));
              failedRecords++;
              errors.add('ANC visit sync failed: ${result.error}');
            }
          } catch (e) {
            failedRecords++;
            errors.add('ANC visit sync error: $e');
          }
        }

        // Sync immunizations
        final immunizationsToSync = _immunizationRecords.where((i) => 
          getSyncStatus(i.id) == SyncStatus.pending || 
          getSyncStatus(i.id) == SyncStatus.failed
        ).toList();
        
        totalRecords += immunizationsToSync.length;
        
        for (final immunization in immunizationsToSync) {
          try {
            _updateSyncMetadata(immunization.id, _syncMetadata[immunization.id]?.copyWith(
              status: SyncStatus.syncing,
            ) ?? SyncMetadata(
              localId: immunization.id,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              status: SyncStatus.syncing,
            ));

            final currentMetadata = _syncMetadata[immunization.id];
            final result = await _cloudService.syncImmunization(
              immunization,
              cloudId: currentMetadata?.cloudId,
            );

            if (result.isSuccess) {
              _updateSyncMetadata(immunization.id, currentMetadata!.copyWith(
                cloudId: result.data,
                status: SyncStatus.synced,
                lastSyncAt: DateTime.now(),
                errorMessage: null,
                retryCount: 0,
              ));
              syncedRecords++;
            } else if (result.isConflict) {
              _updateSyncMetadata(immunization.id, currentMetadata!.copyWith(
                status: SyncStatus.conflict,
                errorMessage: result.error,
              ));
              conflictedRecords++;
              errors.add('Immunization conflict: ${result.error}');
            } else {
              _updateSyncMetadata(immunization.id, currentMetadata!.copyWith(
                status: SyncStatus.failed,
                errorMessage: result.error,
                retryCount: currentMetadata.retryCount + 1,
              ));
              failedRecords++;
              errors.add('Immunization sync failed: ${result.error}');
            }
          } catch (e) {
            failedRecords++;
            errors.add('Immunization sync error: $e');
          }
        }
      }
    } catch (e) {
      errors.add('General sync error: $e');
      failedRecords = totalRecords - syncedRecords - conflictedRecords;
    } finally {
      _isSyncing = false;
      _lastSyncTime = DateTime.now();
      _lastSyncSummary = SyncSummary(
        totalRecords: totalRecords,
        syncedRecords: syncedRecords,
        failedRecords: failedRecords,
        conflictedRecords: conflictedRecords,
        errors: errors,
        syncTime: DateTime.now(),
      );
      notifyListeners();
    }

    return _lastSyncSummary!;
  }

  /// Get count of records by sync status
  Map<SyncStatus, int> getSyncStatusCounts() {
    final counts = <SyncStatus, int>{
      SyncStatus.pending: 0,
      SyncStatus.syncing: 0,
      SyncStatus.synced: 0,
      SyncStatus.failed: 0,
      SyncStatus.conflict: 0,
    };

    // Count patients
    for (final patient in _patients) {
      final status = getSyncStatus(patient.id);
      counts[status] = (counts[status] ?? 0) + 1;
    }

    // Count ANC visits
    for (final visit in _ancVisits) {
      final status = getSyncStatus(visit.id);
      counts[status] = (counts[status] ?? 0) + 1;
    }

    // Count immunizations
    for (final immunization in _immunizationRecords) {
      final status = getSyncStatus(immunization.id);
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  /// Get records that need sync
  List<String> getRecordsNeedingSync() {
    final needsSync = <String>[];
    
    for (final patient in _patients) {
      final status = getSyncStatus(patient.id);
      if (status == SyncStatus.pending || status == SyncStatus.failed) {
        needsSync.add('Patient: ${patient.name}');
      }
    }
    
    for (final visit in _ancVisits) {
      final status = getSyncStatus(visit.id);
      if (status == SyncStatus.pending || status == SyncStatus.failed) {
        needsSync.add('ANC Visit: ${visit.id}');
      }
    }
    
    for (final immunization in _immunizationRecords) {
      final status = getSyncStatus(immunization.id);
      if (status == SyncStatus.pending || status == SyncStatus.failed) {
        needsSync.add('Immunization: ${immunization.vaccineType.displayName}');
      }
    }
    
    return needsSync;
  }

  @override
  void dispose() {
    _cloudService.dispose();
    super.dispose();
  }
}