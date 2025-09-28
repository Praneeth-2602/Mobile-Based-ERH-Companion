enum VisitType { anc, pnc, immunization, generalCheckup, followUp }

extension VisitTypeExtension on VisitType {
  String get displayName {
    switch (this) {
      case VisitType.anc:
        return 'ANC Visit';
      case VisitType.pnc:
        return 'PNC Visit';
      case VisitType.immunization:
        return 'Immunization';
      case VisitType.generalCheckup:
        return 'General Checkup';
      case VisitType.followUp:
        return 'Follow-up';
    }
  }
}

class Visit {
  final String id;
  final String patientId;
  final String patientName;
  final String ashaId;
  final String ashaName;
  final VisitType type;
  final DateTime dateTime;
  final String? notes;
  final Map<String, dynamic>? vitals;
  final List<String>? symptoms;
  final String? treatment;
  final DateTime? nextVisitDue;
  final bool isCompleted;
  final bool isHighPriority;

  Visit({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.ashaId,
    required this.ashaName,
    required this.type,
    required this.dateTime,
    this.notes,
    this.vitals,
    this.symptoms,
    this.treatment,
    this.nextVisitDue,
    required this.isCompleted,
    required this.isHighPriority,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      ashaId: json['ashaId'] as String,
      ashaName: json['ashaName'] as String,
      type: VisitType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VisitType.generalCheckup,
      ),
      dateTime: DateTime.parse(json['dateTime'] as String),
      notes: json['notes'] as String?,
      vitals: json['vitals'] as Map<String, dynamic>?,
      symptoms: (json['symptoms'] as List<dynamic>?)?.cast<String>(),
      treatment: json['treatment'] as String?,
      nextVisitDue: json['nextVisitDue'] != null 
          ? DateTime.parse(json['nextVisitDue'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool,
      isHighPriority: json['isHighPriority'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'ashaId': ashaId,
      'ashaName': ashaName,
      'type': type.name,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'vitals': vitals,
      'symptoms': symptoms,
      'treatment': treatment,
      'nextVisitDue': nextVisitDue?.toIso8601String(),
      'isCompleted': isCompleted,
      'isHighPriority': isHighPriority,
    };
  }

  Visit copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? ashaId,
    String? ashaName,
    VisitType? type,
    DateTime? dateTime,
    String? notes,
    Map<String, dynamic>? vitals,
    List<String>? symptoms,
    String? treatment,
    DateTime? nextVisitDue,
    bool? isCompleted,
    bool? isHighPriority,
  }) {
    return Visit(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      ashaId: ashaId ?? this.ashaId,
      ashaName: ashaName ?? this.ashaName,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      vitals: vitals ?? this.vitals,
      symptoms: symptoms ?? this.symptoms,
      treatment: treatment ?? this.treatment,
      nextVisitDue: nextVisitDue ?? this.nextVisitDue,
      isCompleted: isCompleted ?? this.isCompleted,
      isHighPriority: isHighPriority ?? this.isHighPriority,
    );
  }
}