library;

import 'package:grpc_study/core/exception/custom_exception.dart';

sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok._;
  const factory Result.error(CustomException error) = Error._;

  bool get isOk => this is Ok<T>;
  bool get isError => this is Error<T>;

  void when({
    required void Function(T value) ok,
    required void Function(CustomException error) error,
  }) {
    if (this is Ok<T>) {
      ok((this as Ok<T>).value);
      return;
    } else if (this is Error<T>) {
      error((this as Error<T>).error);
      return;
    }
  }

  R map<R>({
    required R Function(T value) ok,
    required R Function(CustomException error) error,
  }) {
    if (this is Ok<T>) {
      return ok((this as Ok<T>).value);
    } else if (this is Error<T>) {
      return error((this as Error<T>).error);
    }

    throw Exception('Unknown Result Type');
  }
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  final T value;
  @override
  String toString() => 'Result<$T>.ok($value)';
}

final class Error<T> extends Result<T> {
  const Error._(this.error);

  final CustomException error;

  @override
  String toString() {
    return 'Result<$T>.error($error)';
  }
}
