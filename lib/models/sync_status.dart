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
  final Map<String, dynamic>? conflictData;

  const SyncMetadata({
    required this.localId,
    this.cloudId,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncAt,
    this.status = SyncStatus.pending,
    this.errorMessage,
    this.retryCount = 0,
    this.conflictData,
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
        'conflictData': conflictData,
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
        conflictData: json['conflictData'],
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
    Map<String, dynamic>? conflictData,
  }) => SyncMetadata(
        localId: localId ?? this.localId,
        cloudId: cloudId ?? this.cloudId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        retryCount: retryCount ?? this.retryCount,
        conflictData: conflictData ?? this.conflictData,
      );

  bool get needsSync => status == SyncStatus.pending || status == SyncStatus.failed;
  bool get isConflicted => status == SyncStatus.conflict;
  bool get isSynced => status == SyncStatus.synced;
  bool get isSyncing => status == SyncStatus.syncing;
}

abstract class SyncableModel {
  SyncMetadata get syncMetadata;
  SyncableModel copyWithSyncMetadata(SyncMetadata syncMetadata);
  Map<String, dynamic> toCloudJson();
  String get tableName;
}