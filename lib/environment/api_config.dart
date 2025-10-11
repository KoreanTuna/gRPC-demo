class ApiConfig {
  static const String baseUrl = "https://api.example.com";
  static const int gRpcPort = 443;

  /// 인증이 필요한 API 호출 시 사용
  static const String authFlagKey = 'x-requires-auth';
}
