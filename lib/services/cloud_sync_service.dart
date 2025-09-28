import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/patient.dart';
import '../models/anc_visit.dart';
import '../models/immunization.dart';

enum SyncStatus {
  pending,    // Not yet synced to cloud
  syncing,    // Currently being synced
  synced,     // Successfully synced
  failed,     // Sync failed, needs retry
  conflict    // Conflict detected, needs resolution
}

class SyncMetadata {
  final String localId;
  final String? cloudId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncAt;
  final SyncStatus status;
  final String? errorMessage;
  final int retryCount;

  const SyncMetadata({
    required this.localId,
    this.cloudId,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncAt,
    this.status = SyncStatus.pending,
    this.errorMessage,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'cloudId': cloudId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'lastSyncAt': lastSyncAt?.toIso8601String(),
        'status': status.name,
        'errorMessage': errorMessage,
        'retryCount': retryCount,
      };

  factory SyncMetadata.fromJson(Map<String, dynamic> json) => SyncMetadata(
        localId: json['localId'],
        cloudId: json['cloudId'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        lastSyncAt: json['lastSyncAt'] != null 
            ? DateTime.parse(json['lastSyncAt']) 
            : null,
        status: SyncStatus.values.firstWhere((e) => e.name == json['status']),
        errorMessage: json['errorMessage'],
        retryCount: json['retryCount'] ?? 0,
      );

  SyncMetadata copyWith({
    String? localId,
    String? cloudId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    SyncStatus? status,
    String? errorMessage,
    int? retryCount,
  }) => SyncMetadata(
        localId: localId ?? this.localId,
        cloudId: cloudId ?? this.cloudId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        retryCount: retryCount ?? this.retryCount,
      );

  bool get needsSync => status == SyncStatus.pending || status == SyncStatus.failed;
  bool get isConflicted => status == SyncStatus.conflict;
  bool get isSynced => status == SyncStatus.synced;
  bool get isSyncing => status == SyncStatus.syncing;
}

class CloudApiService {
  static const String _baseUrl = 'https://your-api-endpoint.com/api/v1';
  static const Duration _timeoutDuration = Duration(seconds: 30);
  
  final http.Client _client;
  String? _authToken;
  String? _facilityId;

  CloudApiService({http.Client? client}) : _client = client ?? http.Client();

  // Authentication
  Future<bool> authenticate(String username, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        _facilityId = data['facilityId'];
        return true;
      }
      return false;
    } catch (e) {
      print('Authentication failed: $e');
      return false;
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        if (_facilityId != null) 'X-Facility-ID': _facilityId!,
      };

  // Network connectivity check
  Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      final response = await _client.get(
        Uri.parse('$_baseUrl/health'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Sync patients
  Future<SyncResult<Patient>> syncPatient(Patient patient, {String? cloudId}) async {
    try {
      final patientData = patient.toJson();
      patientData.remove('id'); // Remove local ID for cloud sync
      
      http.Response response;
      if (cloudId != null) {
        // Update existing patient
        response = await _client.put(
          Uri.parse('$_baseUrl/patients/$cloudId'),
          headers: _headers,
          body: jsonEncode(patientData),
        ).timeout(_timeoutDuration);
      } else {
        // Create new patient
        response = await _client.post(
          Uri.parse('$_baseUrl/patients'),
          headers: _headers,
          body: jsonEncode(patientData),
        ).timeout(_timeoutDuration);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return SyncResult.success(data['id']);
      } else if (response.statusCode == 409) {
        return SyncResult.conflict('Data conflict detected');
      } else {
        return SyncResult.failure('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }

  // Sync ANC visits
  Future<SyncResult<ANCVisit>> syncANCVisit(ANCVisit visit, {String? cloudId}) async {
    try {
      final visitData = visit.toJson();
      visitData.remove('id');
      
      http.Response response;
      if (cloudId != null) {
        response = await _client.put(
          Uri.parse('$_baseUrl/anc-visits/$cloudId'),
          headers: _headers,
          body: jsonEncode(visitData),
        ).timeout(_timeoutDuration);
      } else {
        response = await _client.post(
          Uri.parse('$_baseUrl/anc-visits'),
          headers: _headers,
          body: jsonEncode(visitData),
        ).timeout(_timeoutDuration);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return SyncResult.success(data['id']);
      } else if (response.statusCode == 409) {
        return SyncResult.conflict('Data conflict detected');
      } else {
        return SyncResult.failure('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }

  // Sync immunizations
  Future<SyncResult<ImmunizationRecord>> syncImmunization(
    ImmunizationRecord immunization, {
    String? cloudId,
  }) async {
    try {
      final immunizationData = immunization.toJson();
      immunizationData.remove('id');
      
      http.Response response;
      if (cloudId != null) {
        response = await _client.put(
          Uri.parse('$_baseUrl/immunizations/$cloudId'),
          headers: _headers,
          body: jsonEncode(immunizationData),
        ).timeout(_timeoutDuration);
      } else {
        response = await _client.post(
          Uri.parse('$_baseUrl/immunizations'),
          headers: _headers,
          body: jsonEncode(immunizationData),
        ).timeout(_timeoutDuration);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return SyncResult.success(data['id']);
      } else if (response.statusCode == 409) {
        return SyncResult.conflict('Data conflict detected');
      } else {
        return SyncResult.failure('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }

  // Fetch updates from cloud
  Future<List<T>> fetchUpdates<T>(
    String endpoint,
    DateTime? lastSyncTime,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final uri = Uri.parse('$_baseUrl/$endpoint').replace(
      queryParameters: {
        if (lastSyncTime != null) 'since': lastSyncTime.toIso8601String(),
      },
    );

    final response = await _client.get(uri, headers: _headers)
        .timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch updates: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}

class SyncResult<T> {
  final String? data; // Cloud ID for successful syncs
  final String? error;
  final SyncResultType type;

  const SyncResult._({
    this.data,
    this.error,
    required this.type,
  });

  factory SyncResult.success(String cloudId) => SyncResult._(
        data: cloudId,
        type: SyncResultType.success,
      );

  factory SyncResult.failure(String error) => SyncResult._(
        error: error,
        type: SyncResultType.failure,
      );

  factory SyncResult.conflict(String error) => SyncResult._(
        error: error,
        type: SyncResultType.conflict,
      );

  bool get isSuccess => type == SyncResultType.success;
  bool get isFailure => type == SyncResultType.failure;
  bool get isConflict => type == SyncResultType.conflict;
}

enum SyncResultType { success, failure, conflict }

class SyncSummary {
  final int totalRecords;
  final int syncedRecords;
  final int failedRecords;
  final int conflictedRecords;
  final List<String> errors;
  final DateTime syncTime;

  const SyncSummary({
    required this.totalRecords,
    required this.syncedRecords,
    required this.failedRecords,
    required this.conflictedRecords,
    required this.errors,
    required this.syncTime,
  });

  bool get isComplete => syncedRecords == totalRecords;
  bool get hasFailures => failedRecords > 0;
  bool get hasConflicts => conflictedRecords > 0;
  double get successRate => totalRecords > 0 ? syncedRecords / totalRecords : 0.0;
}