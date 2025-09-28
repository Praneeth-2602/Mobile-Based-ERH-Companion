import 'package:flutter/material.dart';

enum PregnancyTrimester {
  first(1, "First Trimester (0-12 weeks)"),
  second(2, "Second Trimester (13-26 weeks)"),
  third(3, "Third Trimester (27+ weeks)");

  const PregnancyTrimester(this.number, this.displayName);
  final int number;
  final String displayName;
}

enum ANCVisitType {
  routine("Routine", "Regular scheduled visit"),
  followUp("Follow-up", "Follow-up for specific condition"),
  emergency("Emergency", "Urgent/emergency visit"),
  highRisk("High Risk", "High-risk pregnancy monitoring");

  const ANCVisitType(this.code, this.displayName);
  final String code;
  final String displayName;
}

enum FetalPresentation {
  vertex("Vertex", "Head down (normal)"),
  breech("Breech", "Bottom/feet first"),
  transverse("Transverse", "Sideways"),
  oblique("Oblique", "Diagonal"),
  unknown("Unknown", "Not determined");

  const FetalPresentation(this.code, this.displayName);
  final String code;
  final String displayName;
}

enum RiskCategory {
  low("Low", "Low risk pregnancy", Colors.green),
  moderate("Moderate", "Moderate risk pregnancy", Colors.orange),
  high("High", "High risk pregnancy", Colors.red);

  const RiskCategory(this.code, this.displayName, this.color);
  final String code;
  final String displayName;
  final Color color;
}

class ANCVisit {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime visitDate;
  final int gestationalWeeks;
  final int gestationalDays;
  final PregnancyTrimester trimester;
  final ANCVisitType visitType;
  final int visitNumber; // 1st, 2nd, 3rd ANC visit etc.
  
  // Chief Complaints
  final List<String> complaints;
  final String complaintsNotes;
  
  // Vital Signs
  final double? weight; // in kg
  final double? height; // in cm
  final double? bmi;
  final int? systolicBP;
  final int? diastolicBP;
  final int? pulseRate;
  final double? temperature; // in Celsius
  final int? respiratoryRate;
  
  // Physical Examination
  final bool pallor;
  final bool pedemaFeet;
  final bool pedemaFace;
  final bool pedemaGeneralized;
  final String? generalCondition; // Good/Fair/Poor
  
  // Obstetric Examination
  final double? fundalHeight; // in cm
  final FetalPresentation fetalPresentation;
  final int? fetalHeartRate;
  final bool fetalMovementsPresent;
  final String? fetalPosition; // LOA, ROA, etc.
  final bool? uterineContractionsPresent;
  
  // Laboratory Tests
  final double? hemoglobin; // in g/dl
  final String? bloodGroup;
  final String? rhFactor;
  final bool? hivTest;
  final String? hivResult;
  final bool? syphilisTest;
  final String? syphilisResult;
  final bool? hepatitisBTest;
  final String? hepatitisBResult;
  final String? urineAlbumin;
  final String? urineSugar;
  final double? bloodSugar; // mg/dl
  final bool? tshTest;
  final double? tshValue;
  
  // Immunization Status
  final bool? ttVaccine1;
  final DateTime? ttVaccine1Date;
  final bool? ttVaccine2;
  final DateTime? ttVaccine2Date;
  final bool? ttBooster;
  final DateTime? ttBoosterDate;
  
  // Supplements/Medications
  final bool ironFolicAcidGiven;
  final int ironTabletCount;
  final bool calciumGiven;
  final int calciumTabletCount;
  final List<String> otherMedications;
  
  // Risk Assessment
  final RiskCategory riskCategory;
  final List<String> riskFactors;
  final String riskAssessmentNotes;
  
  // Counseling & Education
  final List<String> counselingTopics;
  final String counselingNotes;
  
  // Next Visit & Referrals
  final DateTime? nextVisitDate;
  final String? referralRequired;
  final String? referralReason;
  final String? referralTo; // Hospital/Specialist
  
  // Additional Notes
  final String? clinicalNotes;
  final String? treatmentPlan;
  final String? specialInstructions;
  
  // Administrative
  final String conductedBy; // ASHA/ANM/Doctor ID
  final String conductedByName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;

  const ANCVisit({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.visitDate,
    required this.gestationalWeeks,
    this.gestationalDays = 0,
    required this.trimester,
    required this.visitType,
    required this.visitNumber,
    this.complaints = const [],
    this.complaintsNotes = '',
    this.weight,
    this.height,
    this.bmi,
    this.systolicBP,
    this.diastolicBP,
    this.pulseRate,
    this.temperature,
    this.respiratoryRate,
    this.pallor = false,
    this.pedemaFeet = false,
    this.pedemaFace = false,
    this.pedemaGeneralized = false,
    this.generalCondition,
    this.fundalHeight,
    this.fetalPresentation = FetalPresentation.unknown,
    this.fetalHeartRate,
    this.fetalMovementsPresent = true,
    this.fetalPosition,
    this.uterineContractionsPresent,
    this.hemoglobin,
    this.bloodGroup,
    this.rhFactor,
    this.hivTest,
    this.hivResult,
    this.syphilisTest,
    this.syphilisResult,
    this.hepatitisBTest,
    this.hepatitisBResult,
    this.urineAlbumin,
    this.urineSugar,
    this.bloodSugar,
    this.tshTest,
    this.tshValue,
    this.ttVaccine1,
    this.ttVaccine1Date,
    this.ttVaccine2,
    this.ttVaccine2Date,
    this.ttBooster,
    this.ttBoosterDate,
    this.ironFolicAcidGiven = false,
    this.ironTabletCount = 0,
    this.calciumGiven = false,
    this.calciumTabletCount = 0,
    this.otherMedications = const [],
    this.riskCategory = RiskCategory.low,
    this.riskFactors = const [],
    this.riskAssessmentNotes = '',
    this.counselingTopics = const [],
    this.counselingNotes = '',
    this.nextVisitDate,
    this.referralRequired,
    this.referralReason,
    this.referralTo,
    this.clinicalNotes,
    this.treatmentPlan,
    this.specialInstructions,
    required this.conductedBy,
    required this.conductedByName,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  factory ANCVisit.fromJson(Map<String, dynamic> json) {
    return ANCVisit(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String,
      visitDate: DateTime.parse(json['visit_date'] as String),
      gestationalWeeks: json['gestational_weeks'] as int,
      gestationalDays: json['gestational_days'] as int? ?? 0,
      trimester: PregnancyTrimester.values.firstWhere(
        (t) => t.number == (json['trimester'] as int),
        orElse: () => PregnancyTrimester.first,
      ),
      visitType: ANCVisitType.values.firstWhere(
        (t) => t.code == (json['visit_type'] as String),
        orElse: () => ANCVisitType.routine,
      ),
      visitNumber: json['visit_number'] as int,
      complaints: (json['complaints'] as List<dynamic>?)?.cast<String>() ?? [],
      complaintsNotes: json['complaints_notes'] as String? ?? '',
      weight: json['weight'] as double?,
      height: json['height'] as double?,
      bmi: json['bmi'] as double?,
      systolicBP: json['systolic_bp'] as int?,
      diastolicBP: json['diastolic_bp'] as int?,
      pulseRate: json['pulse_rate'] as int?,
      temperature: json['temperature'] as double?,
      respiratoryRate: json['respiratory_rate'] as int?,
      pallor: json['pallor'] as bool? ?? false,
      pedemaFeet: json['pedema_feet'] as bool? ?? false,
      pedemaFace: json['pedema_face'] as bool? ?? false,
      pedemaGeneralized: json['pedema_generalized'] as bool? ?? false,
      generalCondition: json['general_condition'] as String?,
      fundalHeight: json['fundal_height'] as double?,
      fetalPresentation: FetalPresentation.values.firstWhere(
        (p) => p.code == (json['fetal_presentation'] as String),
        orElse: () => FetalPresentation.unknown,
      ),
      fetalHeartRate: json['fetal_heart_rate'] as int?,
      fetalMovementsPresent: json['fetal_movements_present'] as bool? ?? true,
      fetalPosition: json['fetal_position'] as String?,
      uterineContractionsPresent: json['uterine_contractions_present'] as bool?,
      hemoglobin: json['hemoglobin'] as double?,
      bloodGroup: json['blood_group'] as String?,
      rhFactor: json['rh_factor'] as String?,
      hivTest: json['hiv_test'] as bool?,
      hivResult: json['hiv_result'] as String?,
      syphilisTest: json['syphilis_test'] as bool?,
      syphilisResult: json['syphilis_result'] as String?,
      hepatitisBTest: json['hepatitis_b_test'] as bool?,
      hepatitisBResult: json['hepatitis_b_result'] as String?,
      urineAlbumin: json['urine_albumin'] as String?,
      urineSugar: json['urine_sugar'] as String?,
      bloodSugar: json['blood_sugar'] as double?,
      tshTest: json['tsh_test'] as bool?,
      tshValue: json['tsh_value'] as double?,
      ttVaccine1: json['tt_vaccine_1'] as bool?,
      ttVaccine1Date: json['tt_vaccine_1_date'] != null 
          ? DateTime.parse(json['tt_vaccine_1_date'] as String) 
          : null,
      ttVaccine2: json['tt_vaccine_2'] as bool?,
      ttVaccine2Date: json['tt_vaccine_2_date'] != null 
          ? DateTime.parse(json['tt_vaccine_2_date'] as String) 
          : null,
      ttBooster: json['tt_booster'] as bool?,
      ttBoosterDate: json['tt_booster_date'] != null 
          ? DateTime.parse(json['tt_booster_date'] as String) 
          : null,
      ironFolicAcidGiven: json['iron_folic_acid_given'] as bool? ?? false,
      ironTabletCount: json['iron_tablet_count'] as int? ?? 0,
      calciumGiven: json['calcium_given'] as bool? ?? false,
      calciumTabletCount: json['calcium_tablet_count'] as int? ?? 0,
      otherMedications: (json['other_medications'] as List<dynamic>?)?.cast<String>() ?? [],
      riskCategory: RiskCategory.values.firstWhere(
        (r) => r.code == (json['risk_category'] as String),
        orElse: () => RiskCategory.low,
      ),
      riskFactors: (json['risk_factors'] as List<dynamic>?)?.cast<String>() ?? [],
      riskAssessmentNotes: json['risk_assessment_notes'] as String? ?? '',
      counselingTopics: (json['counseling_topics'] as List<dynamic>?)?.cast<String>() ?? [],
      counselingNotes: json['counseling_notes'] as String? ?? '',
      nextVisitDate: json['next_visit_date'] != null 
          ? DateTime.parse(json['next_visit_date'] as String) 
          : null,
      referralRequired: json['referral_required'] as String?,
      referralReason: json['referral_reason'] as String?,
      referralTo: json['referral_to'] as String?,
      clinicalNotes: json['clinical_notes'] as String?,
      treatmentPlan: json['treatment_plan'] as String?,
      specialInstructions: json['special_instructions'] as String?,
      conductedBy: json['conducted_by'] as String,
      conductedByName: json['conducted_by_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      isSynced: json['is_synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'visit_date': visitDate.toIso8601String(),
      'gestational_weeks': gestationalWeeks,
      'gestational_days': gestationalDays,
      'trimester': trimester.number,
      'visit_type': visitType.code,
      'visit_number': visitNumber,
      'complaints': complaints,
      'complaints_notes': complaintsNotes,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'systolic_bp': systolicBP,
      'diastolic_bp': diastolicBP,
      'pulse_rate': pulseRate,
      'temperature': temperature,
      'respiratory_rate': respiratoryRate,
      'pallor': pallor,
      'pedema_feet': pedemaFeet,
      'pedema_face': pedemaFace,
      'pedema_generalized': pedemaGeneralized,
      'general_condition': generalCondition,
      'fundal_height': fundalHeight,
      'fetal_presentation': fetalPresentation.code,
      'fetal_heart_rate': fetalHeartRate,
      'fetal_movements_present': fetalMovementsPresent,
      'fetal_position': fetalPosition,
      'uterine_contractions_present': uterineContractionsPresent,
      'hemoglobin': hemoglobin,
      'blood_group': bloodGroup,
      'rh_factor': rhFactor,
      'hiv_test': hivTest,
      'hiv_result': hivResult,
      'syphilis_test': syphilisTest,
      'syphilis_result': syphilisResult,
      'hepatitis_b_test': hepatitisBTest,
      'hepatitis_b_result': hepatitisBResult,
      'urine_albumin': urineAlbumin,
      'urine_sugar': urineSugar,
      'blood_sugar': bloodSugar,
      'tsh_test': tshTest,
      'tsh_value': tshValue,
      'tt_vaccine_1': ttVaccine1,
      'tt_vaccine_1_date': ttVaccine1Date?.toIso8601String(),
      'tt_vaccine_2': ttVaccine2,
      'tt_vaccine_2_date': ttVaccine2Date?.toIso8601String(),
      'tt_booster': ttBooster,
      'tt_booster_date': ttBoosterDate?.toIso8601String(),
      'iron_folic_acid_given': ironFolicAcidGiven,
      'iron_tablet_count': ironTabletCount,
      'calcium_given': calciumGiven,
      'calcium_tablet_count': calciumTabletCount,
      'other_medications': otherMedications,
      'risk_category': riskCategory.code,
      'risk_factors': riskFactors,
      'risk_assessment_notes': riskAssessmentNotes,
      'counseling_topics': counselingTopics,
      'counseling_notes': counselingNotes,
      'next_visit_date': nextVisitDate?.toIso8601String(),
      'referral_required': referralRequired,
      'referral_reason': referralReason,
      'referral_to': referralTo,
      'clinical_notes': clinicalNotes,
      'treatment_plan': treatmentPlan,
      'special_instructions': specialInstructions,
      'conducted_by': conductedBy,
      'conducted_by_name': conductedByName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  // Helper methods
  String get gestationalAgeDisplay {
    if (gestationalDays > 0) {
      return '${gestationalWeeks}w ${gestationalDays}d';
    }
    return '${gestationalWeeks}w';
  }

  String get bpDisplay {
    if (systolicBP != null && diastolicBP != null) {
      return '$systolicBP/$diastolicBP mmHg';
    }
    return 'Not recorded';
  }

  bool get isHighRiskPregnancy {
    return riskCategory == RiskCategory.high || riskFactors.isNotEmpty;
  }

  bool get requiresReferral {
    return referralRequired?.toLowerCase() == 'yes';
  }

  ANCVisit copyWith({
    String? id,
    String? patientId,
    String? patientName,
    DateTime? visitDate,
    int? gestationalWeeks,
    int? gestationalDays,
    PregnancyTrimester? trimester,
    ANCVisitType? visitType,
    int? visitNumber,
    List<String>? complaints,
    String? complaintsNotes,
    double? weight,
    double? height,
    double? bmi,
    int? systolicBP,
    int? diastolicBP,
    int? pulseRate,
    double? temperature,
    int? respiratoryRate,
    bool? pallor,
    bool? pedemaFeet,
    bool? pedemaFace,
    bool? pedemaGeneralized,
    String? generalCondition,
    double? fundalHeight,
    FetalPresentation? fetalPresentation,
    int? fetalHeartRate,
    bool? fetalMovementsPresent,
    String? fetalPosition,
    bool? uterineContractionsPresent,
    double? hemoglobin,
    String? bloodGroup,
    String? rhFactor,
    bool? hivTest,
    String? hivResult,
    bool? syphilisTest,
    String? syphilisResult,
    bool? hepatitisBTest,
    String? hepatitisBResult,
    String? urineAlbumin,
    String? urineSugar,
    double? bloodSugar,
    bool? tshTest,
    double? tshValue,
    bool? ttVaccine1,
    DateTime? ttVaccine1Date,
    bool? ttVaccine2,
    DateTime? ttVaccine2Date,
    bool? ttBooster,
    DateTime? ttBoosterDate,
    bool? ironFolicAcidGiven,
    int? ironTabletCount,
    bool? calciumGiven,
    int? calciumTabletCount,
    List<String>? otherMedications,
    RiskCategory? riskCategory,
    List<String>? riskFactors,
    String? riskAssessmentNotes,
    List<String>? counselingTopics,
    String? counselingNotes,
    DateTime? nextVisitDate,
    String? referralRequired,
    String? referralReason,
    String? referralTo,
    String? clinicalNotes,
    String? treatmentPlan,
    String? specialInstructions,
    String? conductedBy,
    String? conductedByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return ANCVisit(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      visitDate: visitDate ?? this.visitDate,
      gestationalWeeks: gestationalWeeks ?? this.gestationalWeeks,
      gestationalDays: gestationalDays ?? this.gestationalDays,
      trimester: trimester ?? this.trimester,
      visitType: visitType ?? this.visitType,
      visitNumber: visitNumber ?? this.visitNumber,
      complaints: complaints ?? this.complaints,
      complaintsNotes: complaintsNotes ?? this.complaintsNotes,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      systolicBP: systolicBP ?? this.systolicBP,
      diastolicBP: diastolicBP ?? this.diastolicBP,
      pulseRate: pulseRate ?? this.pulseRate,
      temperature: temperature ?? this.temperature,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      pallor: pallor ?? this.pallor,
      pedemaFeet: pedemaFeet ?? this.pedemaFeet,
      pedemaFace: pedemaFace ?? this.pedemaFace,
      pedemaGeneralized: pedemaGeneralized ?? this.pedemaGeneralized,
      generalCondition: generalCondition ?? this.generalCondition,
      fundalHeight: fundalHeight ?? this.fundalHeight,
      fetalPresentation: fetalPresentation ?? this.fetalPresentation,
      fetalHeartRate: fetalHeartRate ?? this.fetalHeartRate,
      fetalMovementsPresent: fetalMovementsPresent ?? this.fetalMovementsPresent,
      fetalPosition: fetalPosition ?? this.fetalPosition,
      uterineContractionsPresent: uterineContractionsPresent ?? this.uterineContractionsPresent,
      hemoglobin: hemoglobin ?? this.hemoglobin,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      rhFactor: rhFactor ?? this.rhFactor,
      hivTest: hivTest ?? this.hivTest,
      hivResult: hivResult ?? this.hivResult,
      syphilisTest: syphilisTest ?? this.syphilisTest,
      syphilisResult: syphilisResult ?? this.syphilisResult,
      hepatitisBTest: hepatitisBTest ?? this.hepatitisBTest,
      hepatitisBResult: hepatitisBResult ?? this.hepatitisBResult,
      urineAlbumin: urineAlbumin ?? this.urineAlbumin,
      urineSugar: urineSugar ?? this.urineSugar,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      tshTest: tshTest ?? this.tshTest,
      tshValue: tshValue ?? this.tshValue,
      ttVaccine1: ttVaccine1 ?? this.ttVaccine1,
      ttVaccine1Date: ttVaccine1Date ?? this.ttVaccine1Date,
      ttVaccine2: ttVaccine2 ?? this.ttVaccine2,
      ttVaccine2Date: ttVaccine2Date ?? this.ttVaccine2Date,
      ttBooster: ttBooster ?? this.ttBooster,
      ttBoosterDate: ttBoosterDate ?? this.ttBoosterDate,
      ironFolicAcidGiven: ironFolicAcidGiven ?? this.ironFolicAcidGiven,
      ironTabletCount: ironTabletCount ?? this.ironTabletCount,
      calciumGiven: calciumGiven ?? this.calciumGiven,
      calciumTabletCount: calciumTabletCount ?? this.calciumTabletCount,
      otherMedications: otherMedications ?? this.otherMedications,
      riskCategory: riskCategory ?? this.riskCategory,
      riskFactors: riskFactors ?? this.riskFactors,
      riskAssessmentNotes: riskAssessmentNotes ?? this.riskAssessmentNotes,
      counselingTopics: counselingTopics ?? this.counselingTopics,
      counselingNotes: counselingNotes ?? this.counselingNotes,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
      referralRequired: referralRequired ?? this.referralRequired,
      referralReason: referralReason ?? this.referralReason,
      referralTo: referralTo ?? this.referralTo,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      treatmentPlan: treatmentPlan ?? this.treatmentPlan,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      conductedBy: conductedBy ?? this.conductedBy,
      conductedByName: conductedByName ?? this.conductedByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}