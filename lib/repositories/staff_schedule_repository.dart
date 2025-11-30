// lib/repositories/staff_schedule_repository.dart
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../models/gig_assignment.dart';
import '../models/staff_availability.dart';
import '../models/shift_swap_request.dart';

class StaffScheduleRepository {
  final Uuid _uuid = const Uuid();
  
  // Mock data storage
  final List<GigAssignment> _gigAssignments = [];
  final List<StaffAvailability> _availabilities = [];
  final List<ShiftSwapRequest> _shiftSwapRequests = [];

  // Get all gig assignments for a staff member
  Future<Either<Exception, List<GigAssignment>>> getStaffGigs(
    String staffId, {
    DateTime? startDate,
    DateTime? endDate,
    List<GigStatus>? statuses,
  }) async {
    try {
      var gigs = _gigAssignments.where((g) => g.staffId == staffId).toList();
      
      if (startDate != null) {
        gigs = gigs.where((g) => g.endTime.isAfter(startDate)).toList();
      }
      
      if (endDate != null) {
        gigs = gigs.where((g) => g.startTime.isBefore(endDate)).toList();
      }
      
      if (statuses != null && statuses.isNotEmpty) {
        gigs = gigs.where((g) => statuses.contains(g.status)).toList();
      }
      
      gigs.sort((a, b) => a.startTime.compareTo(b.startTime));
      return Right(gigs);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // Check if staff is available for a time range
  Future<Either<Exception, bool>> isStaffAvailable(
    String staffId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final availabilities = _availabilities.where((a) => 
        a.staffId == staffId &&
        a.date.isAtSameMomentAs(startTime) &&
        a.status == AvailabilityStatus.available
      ).toList();
      
      if (availabilities.isEmpty) {
        return const Right(false);
      }
      
      // Check if the time range fits within any availability window
      for (final availability in availabilities) {
        final availStart = DateTime(
          availability.date.year,
          availability.date.month,
          availability.date.day,
          availability.startTime.hour,
          availability.startTime.minute,
        );
        
        final availEnd = DateTime(
          availability.date.year,
          availability.date.month,
          availability.date.day,
          availability.endTime.hour,
          availability.endTime.minute,
        );
        
        if (startTime.isAfter(availStart) && endTime.isBefore(availEnd)) {
          return const Right(true);
        }
      }
      
      return const Right(false);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // Set staff availability
  Future<Either<Exception, StaffAvailability>> setAvailability(
    StaffAvailability availability,
  ) async {
    try {
      // Remove any existing availability for the same date/time
      _availabilities.removeWhere((a) => 
        a.staffId == availability.staffId &&
        a.date.isAtSameMomentAs(availability.date)
      );
      
      // Add new availability
      _availabilities.add(availability);
      
      return Right(availability);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // Accept a gig
  Future<Either<Exception, void>> acceptGig(String gigId) async {
    try {
      final index = _gigAssignments.indexWhere((g) => g.id == gigId);
      if (index == -1) {
        return Left(Exception('Gig not found'));
      }
      
      final gig = _gigAssignments[index];
      if (gig.status != GigStatus.pending) {
        return Left(Exception('Gig is not pending'));
      }
      
      _gigAssignments[index] = gig.copyWith(
        status: GigStatus.accepted,
        updatedAt: DateTime.now(),
      );
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // Decline a gig
  Future<Either<Exception, void>> declineGig(
    String gigId, {
    String? reason,
  }) async {
    try {
      final index = _gigAssignments.indexWhere((g) => g.id == gigId);
      if (index == -1) {
        return Left(Exception('Gig not found'));
      }
      
      final gig = _gigAssignments[index];
      if (gig.status != GigStatus.pending) {
        return Left(Exception('Gig is not pending'));
      }
      
      _gigAssignments[index] = gig.copyWith(
        status: GigStatus.declined,
        notes: reason,
        updatedAt: DateTime.now(),
      );
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // Get all shift swap requests
  Future<Either<Exception, List<ShiftSwapRequest>>> getShiftSwapRequests({
    String? staffId,
    bool includeCompleted = false,
  }) async {
    try {
      var requests = _shiftSwapRequests;
      
      if (staffId != null) {
        requests = requests.where((r) => r.requesterId == staffId).toList();
      }
      
      if (!includeCompleted) {
        requests = requests.where((r) => 
          r.status != ShiftSwapStatus.approved &&
          r.status != ShiftSwapStatus.rejected &&
          r.status != ShiftSwapStatus.cancelled
        ).toList();
      }
      
      requests.sort((a, b) => b.requestDate.compareTo(a.requestDate));
      return Right(requests);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // Create a shift swap request
  Future<Either<Exception, ShiftSwapRequest>> createShiftSwapRequest({
    required String requesterId,
    required String gigId,
    required String reason,
    String? recipientId,
  }) async {
    try {
      final newRequest = ShiftSwapRequest(
        id: _uuid.v4(),
        requesterId: requesterId,
        recipientId: recipientId,
        gigId: gigId,
        reason: reason,
        requestDate: DateTime.now(),
      );
      
      _shiftSwapRequests.add(newRequest);
      return Right(newRequest);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // Respond to a shift swap request
  Future<Either<Exception, ShiftSwapRequest>> respondToShiftSwapRequest({
    required String requestId,
    required bool isApproved,
    String? responseNote,
  }) async {
    try {
      final index = _shiftSwapRequests.indexWhere((r) => r.id == requestId);
      if (index == -1) {
        return Left(Exception('Shift swap request not found'));
      }
      
      final request = _shiftSwapRequests[index];
      final updatedRequest = request.copyWith(
        status: isApproved ? ShiftSwapStatus.approved : ShiftSwapStatus.rejected,
        responseDate: DateTime.now(),
        responseNote: responseNote,
      );
      
      _shiftSwapRequests[index] = updatedRequest;
      return Right(updatedRequest);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
