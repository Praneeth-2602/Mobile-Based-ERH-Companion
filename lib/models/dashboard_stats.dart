import 'visit.dart';

class DashboardStats {
  final int totalPatients;
  final int visitsToday;
  final int pendingTasks;
  final int highRiskPatients;
  final int completedVisits;
  final int upcomingVisits;
  final int overdueVisits;
  final int activeCases;
  final double syncProgress;
  final bool hasConnectivity;

  DashboardStats({
    required this.totalPatients,
    required this.visitsToday,
    required this.pendingTasks,
    required this.highRiskPatients,
    required this.completedVisits,
    required this.upcomingVisits,
    required this.overdueVisits,
    required this.activeCases,
    required this.syncProgress,
    required this.hasConnectivity,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPatients: json['totalPatients'] as int,
      visitsToday: json['visitsToday'] as int,
      pendingTasks: json['pendingTasks'] as int,
      highRiskPatients: json['highRiskPatients'] as int,
      completedVisits: json['completedVisits'] as int,
      upcomingVisits: json['upcomingVisits'] as int,
      overdueVisits: json['overdueVisits'] as int,
      activeCases: json['activeCases'] as int? ?? 0,
      syncProgress: (json['syncProgress'] as num).toDouble(),
      hasConnectivity: json['hasConnectivity'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPatients': totalPatients,
      'visitsToday': visitsToday,
      'pendingTasks': pendingTasks,
      'highRiskPatients': highRiskPatients,
      'completedVisits': completedVisits,
      'upcomingVisits': upcomingVisits,
      'overdueVisits': overdueVisits,
      'activeCases': activeCases,
      'syncProgress': syncProgress,
      'hasConnectivity': hasConnectivity,
    };
  }

  DashboardStats copyWith({
    int? totalPatients,
    int? visitsToday,
    int? pendingTasks,
    int? highRiskPatients,
    int? completedVisits,
    int? upcomingVisits,
    int? overdueVisits,
    int? activeCases,
    double? syncProgress,
    bool? hasConnectivity,
  }) {
    return DashboardStats(
      totalPatients: totalPatients ?? this.totalPatients,
      visitsToday: visitsToday ?? this.visitsToday,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      highRiskPatients: highRiskPatients ?? this.highRiskPatients,
      completedVisits: completedVisits ?? this.completedVisits,
      upcomingVisits: upcomingVisits ?? this.upcomingVisits,
      overdueVisits: overdueVisits ?? this.overdueVisits,
      activeCases: activeCases ?? this.activeCases,
      syncProgress: syncProgress ?? this.syncProgress,
      hasConnectivity: hasConnectivity ?? this.hasConnectivity,
    );
  }

  static DashboardStats get empty => DashboardStats(
        totalPatients: 0,
        visitsToday: 0,
        pendingTasks: 0,
        highRiskPatients: 0,
        completedVisits: 0,
        upcomingVisits: 0,
        overdueVisits: 0,
        activeCases: 0,
        syncProgress: 0.0,
        hasConnectivity: false,
      );
}

class Reminder {
  final String id;
  final String patientId;
  final String patientName;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final bool isHighPriority;
  final VisitType? relatedVisitType;

  Reminder({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.isHighPriority,
    this.relatedVisitType,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      isCompleted: json['isCompleted'] as bool,
      isHighPriority: json['isHighPriority'] as bool,
      relatedVisitType: json['relatedVisitType'] != null
          ? VisitType.values.firstWhere(
              (e) => e.name == json['relatedVisitType'],
              orElse: () => VisitType.generalCheckup,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isHighPriority': isHighPriority,
      'relatedVisitType': relatedVisitType?.name,
    };
  }
}