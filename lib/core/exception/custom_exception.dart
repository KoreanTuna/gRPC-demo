import 'package:grpc_study/core/util/grpc/grpc_message_formatter.dart';
import 'package:protobuf/protobuf.dart';

abstract class CustomException implements Exception {
  CustomException(this.message);
  final String message;

  @override
  String toString() {
    return message;
  }
}

class CustomFormatException extends CustomException {
  CustomFormatException(super.message);
}

class CustomNotFoundException extends CustomException {
  CustomNotFoundException(super.message);
}

class CustomNetworkException extends CustomException {
  CustomNetworkException(super.message);
}

class CustomLocalStorageException extends CustomException {
  CustomLocalStorageException(super.message);
}

class CustomGrpcException extends CustomException {
  CustomGrpcException(
    String message, {
    required this.code,
    this.rawResponse,
    this.trailers,
    this.details,
  }) : super(sanitizeGrpcErrorMessage(message, trailers: trailers));

  final int code;
  final Object? rawResponse;
  final Map<String, String>? trailers;
  final List<GeneratedMessage>? details;

  int? get errorCode {
    return trailers != null && trailers!.containsKey('error-code')
        ? int.tryParse(trailers!['error-code']!) ?? -1
        : -1;
  }

  bool hasCustomErrorCode() {
    return errorCode != null && errorCode != -1;
  }
}
