import 'package:dartz/dartz.dart'; // Для Either
import 'package:equatable/equatable.dart';
import 'package:sigmail_client/core/error/failure.dart';

// Базовый класс для UseCase
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Используется, если use case не требует параметров
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

// Базовый класс для StreamUseCase
abstract class StreamUseCase<Type, Params> {
  Stream<Type> call(Params params);
} 