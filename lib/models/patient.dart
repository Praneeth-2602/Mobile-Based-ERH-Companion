import 'sync_status.dart';

enum Gender { male, female, other }

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

enum MaritalStatus { single, married, widowed, divorced, separated }

extension MaritalStatusExtension on MaritalStatus {
  String get displayName {
    switch (this) {
      case MaritalStatus.single:
        return 'Single';
      case MaritalStatus.married:
        return 'Married';
      case MaritalStatus.widowed:
        return 'Widowed';
      case MaritalStatus.divorced:
        return 'Divorced';
      case MaritalStatus.separated:
        return 'Separated';
    }
  }
}

class Patient implements SyncableModel {
  final String id;
  
  // Sync Metadata
  @override
  final SyncMetadata syncMetadata;
  
  // Basic Information
  final String name;
  final DateTime dateOfBirth;
  final int age;
  final Gender gender;
  final MaritalStatus? maritalStatus;
  
  // Government IDs
  final String? govtId; // Aadhaar/Voter ID/PAN
  final String? abhaId; // Ayushman Bharat Health Account ID
  
  // Contact Information
  final String phoneNumber;
  final String? alternateMobile;
  final String village;
  final String address;
  final String familyHead;
  final String? pincode;
  
  // Health Information
  final String? bloodGroup;
  final List<String> allergies;
  final String? customAllergy;
  final List<String> preExistingConditions;
  final String? customPreExisting;
  final bool hasDisability;
  final String? disabilityType;
  final double? height; // in cm
  final double? weight; // in kg
  
  // Maternal & Child Health
  final bool isPregnant;
  final DateTime? lmp; // Last Menstrual Period
  final DateTime? edd; // Expected Date of Delivery
  final int? numberOfChildren;
  final List<String> immunizationHistory;
  
  // Lifestyle & Risk Factors
  final bool usesTobacco;
  final bool consumesAlcohol;
  final String? occupation;
  final String? customOccupation;
  
  // Emergency Information
  final String emergencyContactName;
  final String emergencyContactNumber;
  final String? emergencyContactRelation;
  final String? nearestHealthFacility;
  
  // Registration Details
  final String registeredBy; // ASHA worker ID
  final String registeredByRole; // ASHA/ANM/PHC
  final DateTime registrationDate;
  final bool isHighRisk;
  final DateTime? lastVisit;
  final DateTime? nextDue;
  final String? photoUrl;

  Patient({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    this.maritalStatus,
    this.govtId,
    this.abhaId,
    required this.phoneNumber,
    this.alternateMobile,
    required this.village,
    required this.address,
    required this.familyHead,
    this.pincode,
    this.bloodGroup,
    this.allergies = const [],
    this.customAllergy,
    this.preExistingConditions = const [],
    this.customPreExisting,
    this.hasDisability = false,
    this.disabilityType,
    this.height,
    this.weight,
    this.isPregnant = false,
    this.lmp,
    this.edd,
    this.numberOfChildren,
    this.immunizationHistory = const [],
    this.usesTobacco = false,
    this.consumesAlcohol = false,
    this.occupation,
    this.customOccupation,
    required this.emergencyContactName,
    required this.emergencyContactNumber,
    this.emergencyContactRelation,
    this.nearestHealthFacility,
    required this.registeredBy,
    required this.registeredByRole,
    required this.registrationDate,
    required this.isHighRisk,
    this.lastVisit,
    this.nextDue,
    this.photoUrl,
    SyncMetadata? syncMetadata,
  }) : syncMetadata = syncMetadata ?? SyncMetadata(
         localId: id,
         createdAt: registrationDate,
         updatedAt: registrationDate,
       );

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      age: json['age'] as int,
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => Gender.female,
      ),
      maritalStatus: json['maritalStatus'] != null 
          ? MaritalStatus.values.firstWhere(
              (e) => e.name == json['maritalStatus'],
              orElse: () => MaritalStatus.single,
            )
          : null,
      govtId: json['govtId'] as String?,
      abhaId: json['abhaId'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      alternateMobile: json['alternateMobile'] as String?,
      village: json['village'] as String,
      address: json['address'] as String,
      familyHead: json['familyHead'] as String,
      pincode: json['pincode'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
      customAllergy: json['customAllergy'] as String?,
      preExistingConditions: (json['preExistingConditions'] as List<dynamic>?)?.cast<String>() ?? [],
      customPreExisting: json['customPreExisting'] as String?,
      hasDisability: json['hasDisability'] as bool? ?? false,
      disabilityType: json['disabilityType'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      isPregnant: json['isPregnant'] as bool? ?? false,
      lmp: json['lmp'] != null ? DateTime.parse(json['lmp'] as String) : null,
      edd: json['edd'] != null ? DateTime.parse(json['edd'] as String) : null,
      numberOfChildren: json['numberOfChildren'] as int?,
      immunizationHistory: (json['immunizationHistory'] as List<dynamic>?)?.cast<String>() ?? [],
      usesTobacco: json['usesTobacco'] as bool? ?? false,
      consumesAlcohol: json['consumesAlcohol'] as bool? ?? false,
      occupation: json['occupation'] as String?,
      customOccupation: json['customOccupation'] as String?,
      emergencyContactName: json['emergencyContactName'] as String,
      emergencyContactNumber: json['emergencyContactNumber'] as String,
      emergencyContactRelation: json['emergencyContactRelation'] as String?,
      nearestHealthFacility: json['nearestHealthFacility'] as String?,
      registeredBy: json['registeredBy'] as String,
      registeredByRole: json['registeredByRole'] as String,
      registrationDate: DateTime.parse(json['registrationDate'] as String),
      isHighRisk: json['isHighRisk'] as bool,
      lastVisit: json['lastVisit'] != null 
          ? DateTime.parse(json['lastVisit'] as String)
          : null,
      nextDue: json['nextDue'] != null 
          ? DateTime.parse(json['nextDue'] as String)
          : null,
      photoUrl: json['photoUrl'] as String?,
      syncMetadata: json['syncMetadata'] != null 
          ? SyncMetadata.fromJson(json['syncMetadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'age': age,
      'gender': gender.name,
      'maritalStatus': maritalStatus?.name,
      'govtId': govtId,
      'abhaId': abhaId,
      'phoneNumber': phoneNumber,
      'alternateMobile': alternateMobile,
      'village': village,
      'address': address,
      'familyHead': familyHead,
      'pincode': pincode,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'customAllergy': customAllergy,
      'preExistingConditions': preExistingConditions,
      'customPreExisting': customPreExisting,
      'hasDisability': hasDisability,
      'disabilityType': disabilityType,
      'height': height,
      'weight': weight,
      'isPregnant': isPregnant,
      'lmp': lmp?.toIso8601String(),
      'edd': edd?.toIso8601String(),
      'numberOfChildren': numberOfChildren,
      'immunizationHistory': immunizationHistory,
      'usesTobacco': usesTobacco,
      'consumesAlcohol': consumesAlcohol,
      'occupation': occupation,
      'customOccupation': customOccupation,
      'emergencyContactName': emergencyContactName,
      'emergencyContactNumber': emergencyContactNumber,
      'emergencyContactRelation': emergencyContactRelation,
      'nearestHealthFacility': nearestHealthFacility,
      'registeredBy': registeredBy,
      'registeredByRole': registeredByRole,
      'registrationDate': registrationDate.toIso8601String(),
      'isHighRisk': isHighRisk,
      'lastVisit': lastVisit?.toIso8601String(),
      'nextDue': nextDue?.toIso8601String(),
      'photoUrl': photoUrl,
      'syncMetadata': syncMetadata.toJson(),
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    int? age,
    Gender? gender,
    MaritalStatus? maritalStatus,
    String? govtId,
    String? abhaId,
    String? phoneNumber,
    String? alternateMobile,
    String? village,
    String? address,
    String? familyHead,
    String? pincode,
    String? bloodGroup,
    List<String>? allergies,
    String? customAllergy,
    List<String>? preExistingConditions,
    String? customPreExisting,
    bool? hasDisability,
    String? disabilityType,
    double? height,
    double? weight,
    bool? isPregnant,
    DateTime? lmp,
    DateTime? edd,
    int? numberOfChildren,
    List<String>? immunizationHistory,
    bool? usesTobacco,
    bool? consumesAlcohol,
    String? occupation,
    String? customOccupation,
    String? emergencyContactName,
    String? emergencyContactNumber,
    String? emergencyContactRelation,
    String? nearestHealthFacility,
    String? registeredBy,
    String? registeredByRole,
    DateTime? registrationDate,
    bool? isHighRisk,
    DateTime? lastVisit,
    DateTime? nextDue,
    String? photoUrl,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      govtId: govtId ?? this.govtId,
      abhaId: abhaId ?? this.abhaId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternateMobile: alternateMobile ?? this.alternateMobile,
      village: village ?? this.village,
      address: address ?? this.address,
      familyHead: familyHead ?? this.familyHead,
      pincode: pincode ?? this.pincode,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      customAllergy: customAllergy ?? this.customAllergy,
      preExistingConditions: preExistingConditions ?? this.preExistingConditions,
      customPreExisting: customPreExisting ?? this.customPreExisting,
      hasDisability: hasDisability ?? this.hasDisability,
      disabilityType: disabilityType ?? this.disabilityType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      isPregnant: isPregnant ?? this.isPregnant,
      lmp: lmp ?? this.lmp,
      edd: edd ?? this.edd,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      immunizationHistory: immunizationHistory ?? this.immunizationHistory,
      usesTobacco: usesTobacco ?? this.usesTobacco,
      consumesAlcohol: consumesAlcohol ?? this.consumesAlcohol,
      occupation: occupation ?? this.occupation,
      customOccupation: customOccupation ?? this.customOccupation,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactNumber: emergencyContactNumber ?? this.emergencyContactNumber,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      nearestHealthFacility: nearestHealthFacility ?? this.nearestHealthFacility,
      registeredBy: registeredBy ?? this.registeredBy,
      registeredByRole: registeredByRole ?? this.registeredByRole,
      registrationDate: registrationDate ?? this.registrationDate,
      isHighRisk: isHighRisk ?? this.isHighRisk,
      lastVisit: lastVisit ?? this.lastVisit,
      nextDue: nextDue ?? this.nextDue,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // SyncableModel implementation
  @override
  String get tableName => 'patients';

  @override
  Map<String, dynamic> toCloudJson() {
    final json = toJson();
    // Remove sync metadata from cloud JSON
    json.remove('syncMetadata');
    return json;
  }

  @override
  Patient copyWithSyncMetadata(SyncMetadata syncMetadata) {
    return Patient(
      id: id,
      name: name,
      dateOfBirth: dateOfBirth,
      age: age,
      gender: gender,
      maritalStatus: maritalStatus,
      govtId: govtId,
      abhaId: abhaId,
      phoneNumber: phoneNumber,
      alternateMobile: alternateMobile,
      village: village,
      address: address,
      familyHead: familyHead,
      pincode: pincode,
      bloodGroup: bloodGroup,
      allergies: allergies,
      customAllergy: customAllergy,
      preExistingConditions: preExistingConditions,
      customPreExisting: customPreExisting,
      hasDisability: hasDisability,
      disabilityType: disabilityType,
      height: height,
      weight: weight,
      isPregnant: isPregnant,
      lmp: lmp,
      edd: edd,
      numberOfChildren: numberOfChildren,
      immunizationHistory: immunizationHistory,
      usesTobacco: usesTobacco,
      consumesAlcohol: consumesAlcohol,
      occupation: occupation,
      customOccupation: customOccupation,
      emergencyContactName: emergencyContactName,
      emergencyContactNumber: emergencyContactNumber,
      emergencyContactRelation: emergencyContactRelation,
      nearestHealthFacility: nearestHealthFacility,
      registeredBy: registeredBy,
      registeredByRole: registeredByRole,
      registrationDate: registrationDate,
      isHighRisk: isHighRisk,
      lastVisit: lastVisit,
      nextDue: nextDue,
      photoUrl: photoUrl,
      syncMetadata: syncMetadata,
    );
  }
}