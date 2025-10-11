import 'package:grpc/grpc.dart';

class GrpcOptions {
  static CallOptions defaultCallOptions({Map<String, String>? meta}) {
    return CallOptions(
      timeout: const Duration(seconds: 10),
      metadata: {'x-language-code': 'KO', if (meta != null) ...meta},
    );
  }
}
