// lib/providers/checklist_provider.dart
import 'package:flutter/foundation.dart';
import '../models/checklist_model.dart';

class ChecklistProvider extends ChangeNotifier {
  List<CleaningChecklist> _checklists = [];

  List<CleaningChecklist> get checklists => _checklists;

  void toggleChecklistItem(String checklistId, String itemId) {
    final checklist = _checklists.firstWhere((c) => c.id == checklistId);
    final item = checklist.items.firstWhere((item) => item.id == itemId);
    
    // Create a new item with toggled completion
    final updatedItem = ChecklistItem(
      id: item.id,
      title: item.title,
      description: item.description,
      isCompleted: !item.isCompleted,
      photoRequired: item.photoRequired,
      photoPath: item.photoPath,
      category: item.category,
    );
    
    // Update the checklist
    final List<ChecklistItem> updatedItems = checklist.items.map((i) => i.id == itemId ? updatedItem : i).toList();
    _checklists = _checklists.map((c) => 
      c.id == checklistId ? c.copyWith(items: updatedItems) : c
    ).toList();
    
    notifyListeners();
  }

  Future<bool> submitChecklist(String checklistId, String? notes) async {
    // Mock submission - in real app this would save to backend
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<void> addPhotoToItem(String checklistId, String itemId, String photoPath) async {
    // Mock photo addition
    await Future.delayed(const Duration(milliseconds: 500));
    
    final checklist = _checklists.firstWhere((c) => c.id == checklistId);
    final item = checklist.items.firstWhere((item) => item.id == itemId);
    
    // Create a new item with updated photo path
    final updatedItem = ChecklistItem(
      id: item.id,
      title: item.title,
      description: item.description,
      isCompleted: item.isCompleted,
      photoRequired: item.photoRequired,
      photoPath: photoPath, // Update the photo path
      category: item.category,
    );
    
    // Update the checklist
    final List<ChecklistItem> updatedItems = checklist.items.map((i) => i.id == itemId ? updatedItem : i).toList();
    _checklists = _checklists.map((c) => 
      c.id == checklistId ? c.copyWith(items: updatedItems) : c
    ).toList();
    
    notifyListeners();
  }
}
