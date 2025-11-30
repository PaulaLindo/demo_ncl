import 'package:flutter_test/flutter_test.dart';
import 'package:equatable/equatable.dart';

// Copy the Job model and related enums here to avoid dependencies
enum JobStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
}

class Job extends Equatable {
  final String id;
  final String name;
  final String? location;
  final String? description;
  final String customerName;
  final String address;
  final DateTime startTime;
  final DateTime endTime;
  final String serviceType;
  final JobStatus status;
  final bool isActive;
  final String? checklistId;
  final bool checklistCompleted;

  const Job({
    required this.id,
    required this.name,
    this.location,
    this.description,
    required this.customerName,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.serviceType,
    this.status = JobStatus.scheduled,
    this.isActive = false,
    this.checklistId,
    this.checklistCompleted = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        description,
        customerName,
        address,
        startTime,
        endTime,
        serviceType,
        status,
        isActive,
        checklistId,
        checklistCompleted,
      ];

  Job copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? customerName,
    String? address,
    DateTime? startTime,
    DateTime? endTime,
    String? serviceType,
    JobStatus? status,
    bool? isActive,
    String? checklistId,
    bool? checklistCompleted,
  }) {
    return Job(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      checklistId: checklistId ?? this.checklistId,
      checklistCompleted: checklistCompleted ?? this.checklistCompleted,
    );
  }
}

void main() {
  group('Job Model', () {
    test('should be equal when properties are the same', () {
      final now = DateTime.now();
      final job1 = Job(
        id: '1',
        name: 'Test Job',
        customerName: 'Test Customer',
        address: '123 Test St',
        startTime: now.add(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 1, hours: 2)),
        serviceType: 'Cleaning',
        status: JobStatus.scheduled,
        checklistId: 'checklist_1',
      );

      final job2 = Job(
        id: '1',
        name: 'Test Job',
        customerName: 'Test Customer',
        address: '123 Test St',
        startTime: now.add(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 1, hours: 2)),
        serviceType: 'Cleaning',
        status: JobStatus.scheduled,
        checklistId: 'checklist_1',
      );

      expect(job1, equals(job2));
      expect(job1.props, equals(job2.props));
    });

    test('should not be equal when properties are different', () {
      final now = DateTime.now();
      final job1 = Job(
        id: '1',
        name: 'Test Job',
        customerName: 'Test Customer',
        address: '123 Test St',
        startTime: now.add(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 1, hours: 2)),
        serviceType: 'Cleaning',
      );

      final job2 = job1.copyWith(id: '2');

      expect(job1, isNot(equals(job2)));
    });
  });
}
