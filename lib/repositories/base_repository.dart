import 'package:dartz/dartz.dart';

/// Base repository interface for all repositories
/// [T] - Entity type
/// [ID] - Type of the ID field
abstract class BaseRepository<T, ID> {
  /// Get all entities
  Future<Either<Exception, List<T>>> getAll();
  
  /// Get entity by ID
  Future<Either<Exception, T?>> getById(ID id);
  
  /// Create or update entity
  Future<Either<Exception, T>> save(T entity);
  
  /// Delete entity by ID
  Future<Either<Exception, void>> delete(ID id);
  
  /// Get entities that match the given query
  Future<Either<Exception, List<T>>> query(Map<String, dynamic> query);
}
