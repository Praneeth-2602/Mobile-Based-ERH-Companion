enum TaskPriority { low, medium, high }

enum TaskStatus { assigned, inProgress, completed, cancelled }

class AshaTask {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String assignedAshaId;
  final String assignedAshaName;
  final String? patientId;
  final String? patientName;
  final String createdByUserId; // PHC user id
  final String createdByName;
  final DateTime createdAt;
  final DateTime? completedAt;

  const AshaTask({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.assigned,
    required this.assignedAshaId,
    required this.assignedAshaName,
    this.patientId,
    this.patientName,
    required this.createdByUserId,
    required this.createdByName,
    required this.createdAt,
    this.completedAt,
  });

  factory AshaTask.fromJson(Map<String, dynamic> json) => AshaTask(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => TaskPriority.medium,
        ),
        status: TaskStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TaskStatus.assigned,
        ),
        assignedAshaId: json['assignedAshaId'] as String,
        assignedAshaName: json['assignedAshaName'] as String,
        patientId: json['patientId'] as String?,
        patientName: json['patientName'] as String?,
        createdByUserId: json['createdByUserId'] as String,
        createdByName: json['createdByName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority.name,
        'status': status.name,
        'assignedAshaId': assignedAshaId,
        'assignedAshaName': assignedAshaName,
        'patientId': patientId,
        'patientName': patientName,
        'createdByUserId': createdByUserId,
        'createdByName': createdByName,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  AshaTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedAshaId,
    String? assignedAshaName,
    String? patientId,
    String? patientName,
    String? createdByUserId,
    String? createdByName,
    DateTime? createdAt,
    DateTime? completedAt,
  }) => AshaTask(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        assignedAshaId: assignedAshaId ?? this.assignedAshaId,
        assignedAshaName: assignedAshaName ?? this.assignedAshaName,
        patientId: patientId ?? this.patientId,
        patientName: patientName ?? this.patientName,
        createdByUserId: createdByUserId ?? this.createdByUserId,
        createdByName: createdByName ?? this.createdByName,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt ?? this.completedAt,
      );
}
