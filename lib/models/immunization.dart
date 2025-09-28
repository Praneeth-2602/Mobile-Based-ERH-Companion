import 'package:flutter/material.dart';

enum VaccineType {
  // Childhood Vaccines
  bcg("BCG", "Bacillus Calmette-Guérin (TB)", AgeGroup.infant),
  hepatitisB("Hepatitis B", "Hepatitis B", AgeGroup.infant),
  dpt("DPT", "Diphtheria, Pertussis, Tetanus", AgeGroup.infant),
  opv("OPV", "Oral Polio Vaccine", AgeGroup.infant),
  ipv("IPV", "Inactivated Polio Vaccine", AgeGroup.infant),
  hib("Hib", "Haemophilus influenzae type b", AgeGroup.infant),
  pneumococcal("PCV", "Pneumococcal Conjugate Vaccine", AgeGroup.infant),
  rotavirus("RV", "Rotavirus Vaccine", AgeGroup.infant),
  measles("Measles", "Measles Vaccine", AgeGroup.child),
  mmr("MMR", "Measles, Mumps, Rubella", AgeGroup.child),
  chickenpox("Varicella", "Chickenpox Vaccine", AgeGroup.child),
  hepatitisA("Hepatitis A", "Hepatitis A", AgeGroup.child),
  typhoid("Typhoid", "Typhoid Vaccine", AgeGroup.child),
  je("JE", "Japanese Encephalitis", AgeGroup.child),
  
  // Adult Vaccines
  tetanusToxoid("TT", "Tetanus Toxoid", AgeGroup.adult),
  influenza("Flu", "Influenza Vaccine", AgeGroup.adult),
  covid19("COVID-19", "COVID-19 Vaccine", AgeGroup.adult),
  rabies("Rabies", "Rabies Vaccine", AgeGroup.adult),
  
  // Special Population
  hpv("HPV", "Human Papillomavirus", AgeGroup.adolescent),
  meningococcal("MenACWY", "Meningococcal", AgeGroup.adolescent);

  const VaccineType(this.code, this.displayName, this.targetAgeGroup);
  final String code;
  final String displayName;
  final AgeGroup targetAgeGroup;
}

enum AgeGroup {
  infant("Infant", "0-2 years"),
  child("Child", "2-12 years"),
  adolescent("Adolescent", "12-18 years"),
  adult("Adult", "18+ years");

  const AgeGroup(this.code, this.displayName);
  final String code;
  final String displayName;
}

enum VaccinationStatus {
  given("Given", "Vaccine administered", Colors.green),
  missed("Missed", "Vaccine missed/overdue", Colors.red),
  scheduled("Scheduled", "Vaccine scheduled", Colors.blue),
  contraindicated("Contraindicated", "Medically contraindicated", Colors.orange),
  refused("Refused", "Refused by patient/parent", Colors.grey);

  const VaccinationStatus(this.code, this.displayName, this.color);
  final String code;
  final String displayName;
  final Color color;
}

enum AdverseEventSeverity {
  none("None", "No adverse events"),
  mild("Mild", "Mild reaction (local pain, fever <38.5°C)"),
  moderate("Moderate", "Moderate reaction (fever 38.5-39.5°C, local swelling)"),
  severe("Severe", "Severe reaction (fever >39.5°C, extensive local reaction)"),
  serious("Serious", "Serious adverse event (hospitalization required)");

  const AdverseEventSeverity(this.code, this.displayName);
  final String code;
  final String displayName;
}

enum VaccineManufacturer {
  sii("SII", "Serum Institute of India"),
  bharatBiotech("Bharat Biotech", "Bharat Biotech International"),
  biologicalE("Biological E", "Biological E Limited"),
  haffkine("Haffkine", "Haffkine Bio-Pharmaceutical"),
  glaxoSmithKline("GSK", "GlaxoSmithKline"),
  sanofiPasteur("Sanofi", "Sanofi Pasteur"),
  pfizer("Pfizer", "Pfizer Inc"),
  other("Other", "Other Manufacturer");

  const VaccineManufacturer(this.code, this.displayName);
  final String code;
  final String displayName;
}

class ImmunizationRecord {
  final String id;
  final String patientId;
  final String patientName;
  final int patientAge; // Age at time of vaccination
  final DateTime vaccinationDate;
  final VaccineType vaccineType;
  final String vaccineName; // Specific brand/name
  final VaccineManufacturer manufacturer;
  final String batchNumber;
  final DateTime expiryDate;
  final int doseNumber; // 1st, 2nd, 3rd dose, etc.
  final int totalDosesRequired;
  final VaccinationStatus status;
  
  // Administration Details
  final String administrationSite; // Left/Right arm, thigh, etc.
  final String administrationRoute; // Intramuscular, oral, subcutaneous
  final double doseVolume; // in ml
  final String vaccinatorId;
  final String vaccinatorName;
  final String facilityName;
  
  // Medical Information
  final List<String> contraindications;
  final String medicalHistory;
  final bool consentGiven;
  final String consentGivenBy; // Parent/Guardian name if child
  final String relationshipToPatient; // Parent, Guardian, Self
  
  // Adverse Events
  final AdverseEventSeverity adverseEventSeverity;
  final List<String> adverseEvents;
  final String adverseEventNotes;
  final DateTime? adverseEventOnsetTime;
  final bool adverseEventReported;
  final String? adverseEventReportId;
  
  // Scheduling
  final DateTime? nextDueDate;
  final VaccineType? nextVaccineType;
  final String? nextVaccineNotes;
  final bool followUpRequired;
  final DateTime? followUpDate;
  
  // Quality Assurance
  final double? storageTemperature;
  final bool coldChainMaintained;
  final String? vvmStatus; // Vaccine Vial Monitor status
  final bool openVialDiscarded;
  
  // Administrative
  final String sessionId; // Vaccination session/camp ID
  final String programType; // Routine, Campaign, Outbreak response
  final bool isCatchUp; // Catch-up vaccination
  final String? referenceVisitId; // Link to ANC/other visit
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final String? syncId;

  const ImmunizationRecord({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.vaccinationDate,
    required this.vaccineType,
    required this.vaccineName,
    required this.manufacturer,
    required this.batchNumber,
    required this.expiryDate,
    required this.doseNumber,
    required this.totalDosesRequired,
    required this.status,
    required this.administrationSite,
    required this.administrationRoute,
    required this.doseVolume,
    required this.vaccinatorId,
    required this.vaccinatorName,
    required this.facilityName,
    this.contraindications = const [],
    this.medicalHistory = '',
    required this.consentGiven,
    required this.consentGivenBy,
    required this.relationshipToPatient,
    this.adverseEventSeverity = AdverseEventSeverity.none,
    this.adverseEvents = const [],
    this.adverseEventNotes = '',
    this.adverseEventOnsetTime,
    this.adverseEventReported = false,
    this.adverseEventReportId,
    this.nextDueDate,
    this.nextVaccineType,
    this.nextVaccineNotes,
    this.followUpRequired = false,
    this.followUpDate,
    this.storageTemperature,
    this.coldChainMaintained = true,
    this.vvmStatus,
    this.openVialDiscarded = true,
    required this.sessionId,
    this.programType = 'Routine',
    this.isCatchUp = false,
    this.referenceVisitId,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false,
    this.syncId,
  });

  factory ImmunizationRecord.fromJson(Map<String, dynamic> json) {
    return ImmunizationRecord(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String,
      patientAge: json['patient_age'] as int,
      vaccinationDate: DateTime.parse(json['vaccination_date'] as String),
      vaccineType: VaccineType.values.firstWhere(
        (v) => v.code == (json['vaccine_type'] as String),
        orElse: () => VaccineType.bcg,
      ),
      vaccineName: json['vaccine_name'] as String,
      manufacturer: VaccineManufacturer.values.firstWhere(
        (m) => m.code == (json['manufacturer'] as String),
        orElse: () => VaccineManufacturer.other,
      ),
      batchNumber: json['batch_number'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      doseNumber: json['dose_number'] as int,
      totalDosesRequired: json['total_doses_required'] as int,
      status: VaccinationStatus.values.firstWhere(
        (s) => s.code == (json['status'] as String),
        orElse: () => VaccinationStatus.given,
      ),
      administrationSite: json['administration_site'] as String,
      administrationRoute: json['administration_route'] as String,
      doseVolume: (json['dose_volume'] as num).toDouble(),
      vaccinatorId: json['vaccinator_id'] as String,
      vaccinatorName: json['vaccinator_name'] as String,
      facilityName: json['facility_name'] as String,
      contraindications: (json['contraindications'] as List<dynamic>?)?.cast<String>() ?? [],
      medicalHistory: json['medical_history'] as String? ?? '',
      consentGiven: json['consent_given'] as bool,
      consentGivenBy: json['consent_given_by'] as String,
      relationshipToPatient: json['relationship_to_patient'] as String,
      adverseEventSeverity: AdverseEventSeverity.values.firstWhere(
        (s) => s.code == (json['adverse_event_severity'] as String),
        orElse: () => AdverseEventSeverity.none,
      ),
      adverseEvents: (json['adverse_events'] as List<dynamic>?)?.cast<String>() ?? [],
      adverseEventNotes: json['adverse_event_notes'] as String? ?? '',
      adverseEventOnsetTime: json['adverse_event_onset_time'] != null
          ? DateTime.parse(json['adverse_event_onset_time'] as String)
          : null,
      adverseEventReported: json['adverse_event_reported'] as bool? ?? false,
      adverseEventReportId: json['adverse_event_report_id'] as String?,
      nextDueDate: json['next_due_date'] != null
          ? DateTime.parse(json['next_due_date'] as String)
          : null,
      nextVaccineType: json['next_vaccine_type'] != null
          ? VaccineType.values.firstWhere(
              (v) => v.code == (json['next_vaccine_type'] as String),
              orElse: () => VaccineType.bcg,
            )
          : null,
      nextVaccineNotes: json['next_vaccine_notes'] as String?,
      followUpRequired: json['follow_up_required'] as bool? ?? false,
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'] as String)
          : null,
      storageTemperature: json['storage_temperature'] as double?,
      coldChainMaintained: json['cold_chain_maintained'] as bool? ?? true,
      vvmStatus: json['vvm_status'] as String?,
      openVialDiscarded: json['open_vial_discarded'] as bool? ?? true,
      sessionId: json['session_id'] as String,
      programType: json['program_type'] as String? ?? 'Routine',
      isCatchUp: json['is_catch_up'] as bool? ?? false,
      referenceVisitId: json['reference_visit_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isSynced: json['is_synced'] as bool? ?? false,
      syncId: json['sync_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_age': patientAge,
      'vaccination_date': vaccinationDate.toIso8601String(),
      'vaccine_type': vaccineType.code,
      'vaccine_name': vaccineName,
      'manufacturer': manufacturer.code,
      'batch_number': batchNumber,
      'expiry_date': expiryDate.toIso8601String(),
      'dose_number': doseNumber,
      'total_doses_required': totalDosesRequired,
      'status': status.code,
      'administration_site': administrationSite,
      'administration_route': administrationRoute,
      'dose_volume': doseVolume,
      'vaccinator_id': vaccinatorId,
      'vaccinator_name': vaccinatorName,
      'facility_name': facilityName,
      'contraindications': contraindications,
      'medical_history': medicalHistory,
      'consent_given': consentGiven,
      'consent_given_by': consentGivenBy,
      'relationship_to_patient': relationshipToPatient,
      'adverse_event_severity': adverseEventSeverity.code,
      'adverse_events': adverseEvents,
      'adverse_event_notes': adverseEventNotes,
      'adverse_event_onset_time': adverseEventOnsetTime?.toIso8601String(),
      'adverse_event_reported': adverseEventReported,
      'adverse_event_report_id': adverseEventReportId,
      'next_due_date': nextDueDate?.toIso8601String(),
      'next_vaccine_type': nextVaccineType?.code,
      'next_vaccine_notes': nextVaccineNotes,
      'follow_up_required': followUpRequired,
      'follow_up_date': followUpDate?.toIso8601String(),
      'storage_temperature': storageTemperature,
      'cold_chain_maintained': coldChainMaintained,
      'vvm_status': vvmStatus,
      'open_vial_discarded': openVialDiscarded,
      'session_id': sessionId,
      'program_type': programType,
      'is_catch_up': isCatchUp,
      'reference_visit_id': referenceVisitId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced,
      'sync_id': syncId,
    };
  }

  // Helper methods
  String get doseDisplay => 'Dose $doseNumber of $totalDosesRequired';
  
  bool get isOverdue {
    if (nextDueDate == null) return false;
    return DateTime.now().isAfter(nextDueDate!);
  }
  
  bool get hasAdverseEvents => adverseEventSeverity != AdverseEventSeverity.none;
  
  String get ageGroupAtVaccination {
    if (patientAge < 2) return 'Infant';
    if (patientAge < 12) return 'Child';
    if (patientAge < 18) return 'Adolescent';
    return 'Adult';
  }
  
  bool get needsFollowUp => followUpRequired || hasAdverseEvents;
  
  String get statusDisplay {
    switch (status) {
      case VaccinationStatus.given:
        return 'Administered';
      case VaccinationStatus.missed:
        return 'Missed';
      case VaccinationStatus.scheduled:
        return 'Scheduled';
      case VaccinationStatus.contraindicated:
        return 'Contraindicated';
      case VaccinationStatus.refused:
        return 'Refused';
    }
  }

  ImmunizationRecord copyWith({
    String? id,
    String? patientId,
    String? patientName,
    int? patientAge,
    DateTime? vaccinationDate,
    VaccineType? vaccineType,
    String? vaccineName,
    VaccineManufacturer? manufacturer,
    String? batchNumber,
    DateTime? expiryDate,
    int? doseNumber,
    int? totalDosesRequired,
    VaccinationStatus? status,
    String? administrationSite,
    String? administrationRoute,
    double? doseVolume,
    String? vaccinatorId,
    String? vaccinatorName,
    String? facilityName,
    List<String>? contraindications,
    String? medicalHistory,
    bool? consentGiven,
    String? consentGivenBy,
    String? relationshipToPatient,
    AdverseEventSeverity? adverseEventSeverity,
    List<String>? adverseEvents,
    String? adverseEventNotes,
    DateTime? adverseEventOnsetTime,
    bool? adverseEventReported,
    String? adverseEventReportId,
    DateTime? nextDueDate,
    VaccineType? nextVaccineType,
    String? nextVaccineNotes,
    bool? followUpRequired,
    DateTime? followUpDate,
    double? storageTemperature,
    bool? coldChainMaintained,
    String? vvmStatus,
    bool? openVialDiscarded,
    String? sessionId,
    String? programType,
    bool? isCatchUp,
    String? referenceVisitId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? syncId,
  }) {
    return ImmunizationRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      vaccinationDate: vaccinationDate ?? this.vaccinationDate,
      vaccineType: vaccineType ?? this.vaccineType,
      vaccineName: vaccineName ?? this.vaccineName,
      manufacturer: manufacturer ?? this.manufacturer,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      doseNumber: doseNumber ?? this.doseNumber,
      totalDosesRequired: totalDosesRequired ?? this.totalDosesRequired,
      status: status ?? this.status,
      administrationSite: administrationSite ?? this.administrationSite,
      administrationRoute: administrationRoute ?? this.administrationRoute,
      doseVolume: doseVolume ?? this.doseVolume,
      vaccinatorId: vaccinatorId ?? this.vaccinatorId,
      vaccinatorName: vaccinatorName ?? this.vaccinatorName,
      facilityName: facilityName ?? this.facilityName,
      contraindications: contraindications ?? this.contraindications,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      consentGiven: consentGiven ?? this.consentGiven,
      consentGivenBy: consentGivenBy ?? this.consentGivenBy,
      relationshipToPatient: relationshipToPatient ?? this.relationshipToPatient,
      adverseEventSeverity: adverseEventSeverity ?? this.adverseEventSeverity,
      adverseEvents: adverseEvents ?? this.adverseEvents,
      adverseEventNotes: adverseEventNotes ?? this.adverseEventNotes,
      adverseEventOnsetTime: adverseEventOnsetTime ?? this.adverseEventOnsetTime,
      adverseEventReported: adverseEventReported ?? this.adverseEventReported,
      adverseEventReportId: adverseEventReportId ?? this.adverseEventReportId,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      nextVaccineType: nextVaccineType ?? this.nextVaccineType,
      nextVaccineNotes: nextVaccineNotes ?? this.nextVaccineNotes,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      followUpDate: followUpDate ?? this.followUpDate,
      storageTemperature: storageTemperature ?? this.storageTemperature,
      coldChainMaintained: coldChainMaintained ?? this.coldChainMaintained,
      vvmStatus: vvmStatus ?? this.vvmStatus,
      openVialDiscarded: openVialDiscarded ?? this.openVialDiscarded,
      sessionId: sessionId ?? this.sessionId,
      programType: programType ?? this.programType,
      isCatchUp: isCatchUp ?? this.isCatchUp,
      referenceVisitId: referenceVisitId ?? this.referenceVisitId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncId: syncId ?? this.syncId,
    );
  }
}

// Vaccine Schedule Helper Class
class VaccineSchedule {
  static List<Map<String, dynamic>> getStandardSchedule() {
    return [
      // At Birth
      {'vaccine': VaccineType.bcg, 'age_weeks': 0, 'dose': 1, 'total_doses': 1},
      {'vaccine': VaccineType.hepatitisB, 'age_weeks': 0, 'dose': 1, 'total_doses': 3},
      
      // At 6 weeks
      {'vaccine': VaccineType.dpt, 'age_weeks': 6, 'dose': 1, 'total_doses': 3},
      {'vaccine': VaccineType.opv, 'age_weeks': 6, 'dose': 1, 'total_doses': 3},
      {'vaccine': VaccineType.hepatitisB, 'age_weeks': 6, 'dose': 2, 'total_doses': 3},
      {'vaccine': VaccineType.hib, 'age_weeks': 6, 'dose': 1, 'total_doses': 3},
      {'vaccine': VaccineType.pneumococcal, 'age_weeks': 6, 'dose': 1, 'total_doses': 3},
      {'vaccine': VaccineType.rotavirus, 'age_weeks': 6, 'dose': 1, 'total_doses': 3},
      
      // At 10 weeks
      {'vaccine': VaccineType.dpt, 'age_weeks': 10, 'dose': 2, 'total_doses': 3},
      {'vaccine': VaccineType.opv, 'age_weeks': 10, 'dose': 2, 'total_doses': 3},
      {'vaccine': VaccineType.hib, 'age_weeks': 10, 'dose': 2, 'total_doses': 3},
      {'vaccine': VaccineType.pneumococcal, 'age_weeks': 10, 'dose': 2, 'total_doses': 3},
      {'vaccine': VaccineType.rotavirus, 'age_weeks': 10, 'dose': 2, 'total_doses': 3},
      
      // At 14 weeks
      {'vaccine': VaccineType.dpt, 'age_weeks': 14, 'dose': 3, 'total_doses': 3},
      {'vaccine': VaccineType.opv, 'age_weeks': 14, 'dose': 3, 'total_doses': 3},
      {'vaccine': VaccineType.hepatitisB, 'age_weeks': 14, 'dose': 3, 'total_doses': 3},
      {'vaccine': VaccineType.hib, 'age_weeks': 14, 'dose': 3, 'total_doses': 3},
      {'vaccine': VaccineType.pneumococcal, 'age_weeks': 14, 'dose': 3, 'total_doses': 3},
      {'vaccine': VaccineType.rotavirus, 'age_weeks': 14, 'dose': 3, 'total_doses': 3},
      {'vaccine': VaccineType.ipv, 'age_weeks': 14, 'dose': 1, 'total_doses': 2},
      
      // At 9 months
      {'vaccine': VaccineType.measles, 'age_weeks': 36, 'dose': 1, 'total_doses': 2},
      {'vaccine': VaccineType.je, 'age_weeks': 36, 'dose': 1, 'total_doses': 1},
      
      // At 16-24 months
      {'vaccine': VaccineType.mmr, 'age_weeks': 72, 'dose': 1, 'total_doses': 2},
      {'vaccine': VaccineType.dpt, 'age_weeks': 72, 'dose': 4, 'total_doses': 4}, // Booster
      {'vaccine': VaccineType.opv, 'age_weeks': 72, 'dose': 4, 'total_doses': 4}, // Booster
      {'vaccine': VaccineType.measles, 'age_weeks': 72, 'dose': 2, 'total_doses': 2},
      {'vaccine': VaccineType.ipv, 'age_weeks': 72, 'dose': 2, 'total_doses': 2},
      
      // At 5-6 years
      {'vaccine': VaccineType.dpt, 'age_weeks': 260, 'dose': 5, 'total_doses': 5}, // DT booster
      {'vaccine': VaccineType.mmr, 'age_weeks': 260, 'dose': 2, 'total_doses': 2},
      
      // At 10 years
      {'vaccine': VaccineType.tetanusToxoid, 'age_weeks': 520, 'dose': 1, 'total_doses': 2},
      
      // At 16 years
      {'vaccine': VaccineType.tetanusToxoid, 'age_weeks': 832, 'dose': 2, 'total_doses': 2},
    ];
  }

  static DateTime? getNextDueDate(VaccineType vaccineType, int doseNumber, DateTime birthDate) {
    final schedule = getStandardSchedule();
    final nextSchedule = schedule.firstWhere(
      (s) => s['vaccine'] == vaccineType && s['dose'] == doseNumber + 1,
      orElse: () => <String, dynamic>{},
    );
    
    if (nextSchedule.isEmpty) return null;
    
    final ageWeeks = nextSchedule['age_weeks'] as int;
    return birthDate.add(Duration(days: ageWeeks * 7));
  }
}