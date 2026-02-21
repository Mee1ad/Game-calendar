import 'package:equatable/equatable.dart';

sealed class Result<T> extends Equatable {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;

  @override
  List<Object?> get props => [data];
}

final class Failure<T> extends Result<T> {
  const Failure(this.message, [this.stackTrace]);
  final String message;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, stackTrace];
}
