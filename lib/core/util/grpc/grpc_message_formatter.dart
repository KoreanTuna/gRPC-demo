const _grpcLineBreakPlaceholder = '!!@@##\$\$';

String? sanitizeGrpcMessage(String? message) {
  if (message == null) {
    return null;
  }
  if (!message.contains(_grpcLineBreakPlaceholder)) {
    return message;
  }
  return message.replaceAll(_grpcLineBreakPlaceholder, '\n');
}

String sanitizeGrpcErrorMessage(
  String message, {
  Map<String, String>? trailers,
}) {
  final base = sanitizeGrpcMessage(message) ?? message;
  final attemptValue = trailers != null ? trailers['error-value'] : null;

  if (attemptValue == null || attemptValue.isEmpty) {
    return base;
  }

  return base
      .replaceAll('#{1}', attemptValue)
      .replaceAll('# {1}', ' $attemptValue')
      .replaceAll('{1}', attemptValue);
}
