class ApiConfig {
  static const String baseUrl = "localhost";
  static const int gRpcPort = 50051;

  /// 인증이 필요한 API 호출 시 사용
  static const String authFlagKey = 'x-requires-auth';
}
