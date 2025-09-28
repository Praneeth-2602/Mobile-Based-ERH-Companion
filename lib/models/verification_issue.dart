enum VerificationRecordType { patient, ancVisit, immunization }

enum IssueType { conflict, incomplete }

enum IssueSeverity { low, medium, high }

class VerificationIssue {
  final String id;
  final IssueType type;
  final VerificationRecordType recordType;
  final String recordId;
  final String title;
  final String description;
  final IssueSeverity severity;
  final String? patientId;
  final String? patientName;
  final String? ashaId;
  final String? ashaName;
  final DateTime detectedAt;
  final Map<String, dynamic>? metadata;

  const VerificationIssue({
    required this.id,
    required this.type,
    required this.recordType,
    required this.recordId,
    required this.title,
    required this.description,
    this.severity = IssueSeverity.medium,
    this.patientId,
    this.patientName,
    this.ashaId,
    this.ashaName,
    required this.detectedAt,
    this.metadata,
  });

  VerificationIssue copyWith({
    IssueType? type,
    IssueSeverity? severity,
    Map<String, dynamic>? metadata,
  }) {
    return VerificationIssue(
      id: id,
      type: type ?? this.type,
      recordType: recordType,
      recordId: recordId,
      title: title,
      description: description,
      severity: severity ?? this.severity,
      patientId: patientId,
      patientName: patientName,
      ashaId: ashaId,
      ashaName: ashaName,
      detectedAt: detectedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
