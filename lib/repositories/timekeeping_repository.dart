import 'package:dartz/dartz.dart';
import '../models/time_record_model.dart';
import '../models/work_shift_model.dart';
import '../models/temp_card_model.dart';
import 'base_repository.dart';

class TimekeepingRepository {
  final TimeRecordRepository _timeRecordRepo;
  final WorkShiftRepository _workShiftRepo;
  final TempCardRepository _tempCardRepo;

  TimekeepingRepository({
    required TimeRecordRepository timeRecordRepo,
    required WorkShiftRepository workShiftRepo,
    required TempCardRepository tempCardRepo,
  })  : _timeRecordRepo = timeRecordRepo,
        _workShiftRepo = workShiftRepo,
        _tempCardRepo = tempCardRepo;

  // TimeRecord methods
  Future<Either<Exception, List<TimeRecord>>> getTimeRecords() => 
      _timeRecordRepo.getAll();
      
  Future<Either<Exception, TimeRecord?>> getTimeRecord(String id) => 
      _timeRecordRepo.getById(id);
      
  Future<Either<Exception, TimeRecord>> saveTimeRecord(TimeRecord record) => 
      _timeRecordRepo.save(record);
      
  Future<Either<Exception, void>> deleteTimeRecord(String id) => 
      _timeRecordRepo.delete(id);
      
  Future<Either<Exception, List<TimeRecord>>> getTimeRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final result = await _timeRecordRepo.query({
      'checkInTime': {'\$gte': start, '\$lte': end}
    });
    return result;
  }

  // WorkShift methods
  Future<Either<Exception, List<WorkShift>>> getWorkShifts() => 
      _workShiftRepo.getAll();
      
  // TempCard methods
  Future<Either<Exception, List<TempCard>>> getTempCards() => 
      _tempCardRepo.getAll();
}

class TimeRecordRepository implements BaseRepository<TimeRecord, String> {
  final List<TimeRecord> _records = [];
  
  @override
  Future<Either<Exception, List<TimeRecord>>> getAll() async {
    try {
      return Right(List<TimeRecord>.from(_records));
    } catch (e) {
      return Left(Exception('Failed to get time records: $e'));
    }
  }
  
  @override
  Future<Either<Exception, TimeRecord?>> getById(String id) async {
    try {
      final record = _records.firstWhere(
        (r) => r.id == id, 
        orElse: () => throw Exception('TimeRecord not found')
      );
      return Right(record);
    } on Exception catch (e) {
      return Left(e);
    }
  }
  
  @override
  Future<Either<Exception, TimeRecord>> save(TimeRecord record) async {
    try {
      final index = _records.indexWhere((r) => r.id == record.id);
      if (index >= 0) {
        _records[index] = record;
      } else {
        _records.add(record);
      }
      return Right(record);
    } catch (e) {
      return Left(Exception('Failed to save time record: $e'));
    }
  }
  
  @override
  Future<Either<Exception, void>> delete(String id) async {
    try {
      _records.removeWhere((r) => r.id == id);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to delete time record: $e'));
    }
  }
  
  @override
  Future<Either<Exception, List<TimeRecord>>> query(
    Map<String, dynamic> query
  ) async {
    try {
      // This is a simplified implementation
      // In a real app, you would parse the query and filter accordingly
      return Right(List<TimeRecord>.from(_records));
    } catch (e) {
      return Left(Exception('Query failed: $e'));
    }
  }
}

class WorkShiftRepository implements BaseRepository<WorkShift, String> {
  final List<WorkShift> _workShifts = [];
  
  @override
  Future<Either<Exception, List<WorkShift>>> getAll() async {
    try {
      return Right(List<WorkShift>.from(_workShifts));
    } catch (e) {
      return Left(Exception('Failed to fetch work shifts: $e'));
    }
  }
  
  @override
  Future<Either<Exception, WorkShift?>> getById(String id) async {
    try {
      final shift = _workShifts.firstWhere(
        (s) => s.id == id,
        orElse: () => throw Exception('Work shift not found')
      );
      return Right(shift);
    } on Exception catch (e) {
      return Left(e);
    }
  }
  
  @override
  Future<Either<Exception, WorkShift>> save(WorkShift entity) async {
    try {
      final index = _workShifts.indexWhere((s) => s.id == entity.id);
      if (index >= 0) {
        _workShifts[index] = entity;
      } else {
        _workShifts.add(entity);
      }
      return Right(entity);
    } catch (e) {
      return Left(Exception('Failed to save work shift: $e'));
    }
  }
  
  @override
  Future<Either<Exception, void>> delete(String id) async {
    try {
      _workShifts.removeWhere((s) => s.id == id);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to delete work shift: $e'));
    }
  }
  
  @override
  Future<Either<Exception, List<WorkShift>>> query(Map<String, dynamic> query) async {
    try {
      // Simple query implementation - can be enhanced based on requirements
      var results = List<WorkShift>.from(_workShifts);
      
      if (query.containsKey('jobId')) {
        results = results.where((s) => s.jobId == query['jobId']).toList();
      }
      
      if (query.containsKey('userId')) {
        results = results.where((s) => s.userId == query['userId']).toList();
      }
      
      if (query.containsKey('status')) {
        results = results.where((s) => s.status == query['status']).toList();
      }
      
      return Right(results);
    } catch (e) {
      return Left(Exception('Query failed: $e'));
    }
  }
}

class TempCardRepository implements BaseRepository<TempCard, String> {
  final List<TempCard> _tempCards = [];
  
  @override
  Future<Either<Exception, List<TempCard>>> getAll() async {
    try {
      return Right(List<TempCard>.from(_tempCards));
    } catch (e) {
      return Left(Exception('Failed to fetch temp cards: $e'));
    }
  }
  
  @override
  Future<Either<Exception, TempCard?>> getById(String id) async {
    try {
      final card = _tempCards.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Temp card not found')
      );
      return Right(card);
    } on Exception catch (e) {
      return Left(e);
    }
  }
  
  @override
  Future<Either<Exception, TempCard>> save(TempCard entity) async {
    try {
      final index = _tempCards.indexWhere((c) => c.id == entity.id);
      if (index >= 0) {
        _tempCards[index] = entity;
      } else {
        _tempCards.add(entity);
      }
      return Right(entity);
    } catch (e) {
      return Left(Exception('Failed to save temp card: $e'));
    }
  }
  
  @override
  Future<Either<Exception, void>> delete(String id) async {
    try {
      _tempCards.removeWhere((c) => c.id == id);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to delete temp card: $e'));
    }
  }
  
  @override
  Future<Either<Exception, List<TempCard>>> query(Map<String, dynamic> query) async {
    try {
      var results = List<TempCard>.from(_tempCards);
      
      if (query.containsKey('isActive')) {
        final isActive = query['isActive'] as bool;
        results = results.where((c) => c.isActive == isActive).toList();
      }
      
      if (query.containsKey('userId')) {
        results = results.where((c) => c.userId == query['userId']).toList();
      }
      
      return Right(results);
    } catch (e) {
      return Left(Exception('Query failed: $e'));
    }
  }
}
