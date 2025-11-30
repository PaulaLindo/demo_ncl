// lib/features/staff/checklists/checklist_provider.dart
import 'package:flutter/foundation.dart';
import 'package:demo_ncl/models/checklist_model.dart';

class ChecklistProvider with ChangeNotifier {
  List<CleaningChecklist> _checklists = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CleaningChecklist> get checklists => _checklists;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load checklists (in a real app, this would fetch from an API)
  Future<void> loadChecklists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data - in a real app, this would come from an API
      _checklists = _mockChecklists;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load checklists: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle item completion
  void toggleChecklistItem(String checklistId, String itemId) {
    final checklistIndex = _checklists.indexWhere((c) => c.id == checklistId);
    if (checklistIndex == -1) return;

    final updatedItems = List<ChecklistItem>.from(_checklists[checklistIndex].items);
    final itemIndex = updatedItems.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
      isCompleted: !updatedItems[itemIndex].isCompleted,
    );

    _checklists[checklistIndex] = _checklists[checklistIndex].copyWith(
      items: updatedItems,
      status: _calculateChecklistStatus(updatedItems),
    );

    notifyListeners();
  }

  // Add a photo to a checklist item
  void addPhotoToItem(String checklistId, String itemId, String photoPath) {
    final checklistIndex = _checklists.indexWhere((c) => c.id == checklistId);
    if (checklistIndex == -1) return;

    final updatedItems = List<ChecklistItem>.from(_checklists[checklistIndex].items);
    final itemIndex = updatedItems.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
      photoPath: photoPath,
    );

    _checklists[checklistIndex] = _checklists[checklistIndex].copyWith(
      items: updatedItems,
    );

    notifyListeners();
  }

  // Submit a completed checklist
  Future<bool> submitChecklist(String checklistId, {String? notes, String? clientSignature}) async {
    final checklistIndex = _checklists.indexWhere((c) => c.id == checklistId);
    if (checklistIndex == -1) return false;

    try {
      // In a real app, this would upload to a server
      await Future.delayed(const Duration(seconds: 1));
      
      _checklists[checklistIndex] = _checklists[checklistIndex].copyWith(
        status: ChecklistStatus.completed,
        notes: notes,
        clientSignature: clientSignature,
        completedAt: DateTime.now(),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to submit checklist: $e';
      notifyListeners();
      return false;
    }
  }

  // Helper method to calculate checklist status
  ChecklistStatus _calculateChecklistStatus(List<ChecklistItem> items) {
    if (items.isEmpty) return ChecklistStatus.pending;
    
    final completedCount = items.where((item) => item.isCompleted).length;
    if (completedCount == 0) return ChecklistStatus.pending;
    if (completedCount < items.length) return ChecklistStatus.inProgress;
    return ChecklistStatus.completed;
  }

  // Mock data
  List<CleaningChecklist> get _mockChecklists => [
    CleaningChecklist(
      id: '1',
      title: 'Standard Home Clean',
      clientName: 'Sarah Johnson',
      clientAddress: '123 Main St, Cape Town',
      scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      status: ChecklistStatus.inProgress,
      items: [
        ChecklistItem(
          id: '1-1',
          title: 'Dust all surfaces',
          description: 'Dust all reachable surfaces including furniture and decor',
          category: 'Living Room',
          isRequired: true,
          photoRequired: 'After completion',
        ),
        ChecklistItem(
          id: '1-2',
          title: 'Clean windows and mirrors',
          description: 'Clean all interior windows and mirrors',
          category: 'Living Room',
          photoRequired: 'Show before and after',
        ),
        ChecklistItem(
          id: '1-3',
          title: 'Vacuum carpets and rugs',
          category: 'Living Room',
          isRequired: true,
          photoRequired: 'After completion',
        ),
        ChecklistItem(
          id: '1-4',
          title: 'Clean kitchen counters',
          description: 'Wipe down and sanitize all countertops',
          category: 'Kitchen',
          isRequired: true,
          photoRequired: 'After completion',
        ),
        ChecklistItem(
          id: '1-5',
          title: 'Clean inside microwave',
          category: 'Kitchen',
          photoRequired: 'Show inside after cleaning',
        ),
      ],
    ),
    // Add more mock checklists as needed
  ];
}