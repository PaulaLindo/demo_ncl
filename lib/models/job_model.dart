// lib/models/job_model.dart
import 'package:equatable/equatable.dart';

import 'job_status.dart';

class Job extends Equatable {
  final String id;
  final String title;
  final String? location;
  final String? description;
  final String? customerName;
  final DateTime startTime;
  final DateTime endTime;
  final JobStatus status;
  final bool isActive;
  final String? checklistId;
  final bool checklistCompleted;
  final List<String>? requiredSkills;

  Job({
    required this.id,
    required this.title,
    this.location,
    this.description,
    this.customerName,
    required this.startTime,
    required this.endTime,
    this.status = JobStatus.scheduled,
    this.isActive = false,
    this.checklistId,
    this.checklistCompleted = false,
    this.requiredSkills = const [],
  }) : assert(endTime.isAfter(startTime),
            'End time must be after start time');

  Job.empty()
      : id = '',
        title = '',
        location = null,
        description = null,
        customerName = null,
        startTime = DateTime.now(),
        endTime = DateTime.now().add(const Duration(hours: 1)),
        status = JobStatus.scheduled,
        isActive = false,
        checklistId = null,
        checklistCompleted = false,
        requiredSkills = const [];

  /// Creates a Job from JSON data
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String?,
      description: json['description'] as String?,
      customerName: json['customerName'] as String? ?? 'Unknown Customer',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: JobStatus.values.firstWhere(
        (e) => e.toString() == 'JobStatus.${json['status']}',
        orElse: () => JobStatus.scheduled,
      ),
      isActive: json['isActive'] as bool? ?? false,
      checklistId: json['checklistId'] as String?,
      checklistCompleted: json['checklistCompleted'] as bool? ?? false,
    );
  }

  /// Converts the job to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (location != null) 'location': location,
      if (description != null) 'description': description,
      'customerName': customerName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'isActive': isActive,
      'checklistId': checklistId,
      'checklistCompleted': checklistCompleted,
      'requiredSkills': requiredSkills,
    };
  }

  /// Creates a copy of this job with updated fields
  Job copyWith({
    String? id,
    String? title,
    String? location,
    String? description,
    String? customerName,
    DateTime? startTime,
    DateTime? endTime,
    JobStatus? status,
    bool? isActive,
    String? checklistId,
    bool? checklistCompleted,
    List<String>? requiredSkills,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      customerName: customerName ?? this.customerName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      checklistId: checklistId ?? this.checklistId,
      checklistCompleted: checklistCompleted ?? this.checklistCompleted,
      requiredSkills: requiredSkills ?? this.requiredSkills,
    );
  }

  String? get address => location;

  @override
  List<Object?> get props => [
        id,
        title,
        location,
        description,
        customerName,
        startTime,
        endTime,
        status,
        isActive,
        checklistId,
        checklistCompleted,
        requiredSkills,
      ];

  @override
  String toString() => 'Job(id: $id, title: $title, status: $status)';
}