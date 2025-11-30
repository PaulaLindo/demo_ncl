// lib/models/checklist_model.dart

enum ChecklistStatus { pending, inProgress, completed, verified }

class CleaningChecklist {
  final String id;
  final String title;
  final String clientName;
  final String clientAddress;
  final DateTime scheduledTime;
  final List<ChecklistItem> items;
  final ChecklistStatus status;
  final String? notes;
  final String? clientSignature; // Path to signature image
  final DateTime? completedAt;

  CleaningChecklist({
    required this.id,
    required this.title,
    required this.clientName,
    required this.clientAddress,
    required this.scheduledTime,
    required this.items,
    this.status = ChecklistStatus.pending,
    this.notes,
    this.clientSignature,
    this.completedAt,
  });

  // Helper methods
  int get completedItems => items.where((item) => item.isCompleted).length;
  int get totalItems => items.length;
  double get completionPercentage => totalItems > 0 ? completedItems / totalItems : 0;
  bool get isCompleted => status == ChecklistStatus.completed || status == ChecklistStatus.verified;

  // Copy with method for immutability
  CleaningChecklist copyWith({
    String? id,
    String? title,
    String? clientName,
    String? clientAddress,
    DateTime? scheduledTime,
    List<ChecklistItem>? items,
    ChecklistStatus? status,
    String? notes,
    String? clientSignature,
    DateTime? completedAt,
  }) {
    return CleaningChecklist(
      id: id ?? this.id,
      title: title ?? this.title,
      clientName: clientName ?? this.clientName,
      clientAddress: clientAddress ?? this.clientAddress,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      items: items ?? this.items,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      clientSignature: clientSignature ?? this.clientSignature,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class ChecklistItem {
  final String id;
  final String title;
  final String? description;
  final bool isRequired;
  bool isCompleted;
  final String? photoRequired; // Instructions for required photo
  String? photoPath; // Path to the taken photo
  final String? category; // e.g., "Kitchen", "Bathroom", "Living Area"

  ChecklistItem({
    required this.id,
    required this.title,
    this.description,
    this.isRequired = true,
    this.isCompleted = false,
    this.photoRequired,
    this.photoPath,
    this.category,
  });

  // Toggle completion status
  void toggleComplete() {
    isCompleted = !isCompleted;
  }

  // Copy with method for immutability
  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isRequired,
    bool? isCompleted,
    String? photoRequired,
    String? photoPath,
    String? category,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      photoRequired: photoRequired ?? this.photoRequired,
      photoPath: photoPath ?? this.photoPath,
      category: category ?? this.category,
    );
  }
}