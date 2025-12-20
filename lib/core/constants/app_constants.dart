final class AppConstants {
  static final AppConstants instance = AppConstants._();
  AppConstants._();

  final String appName = 'DentApp';
  final String baseUrlTest = "http://212.112.123.118:8082/"; // test API
  final String baseUrlProd = "https://backend.dentapp.online/"; // prod API
  final String accessToken = "accessToken";
  final String isLogin = "isLogin";
  final String tokenExpiry = "tokenExpiry";
  final String refreshToken = "refreshToken";
  final String userId = "userId";
  final String clinicId = "clinicId";
  final String role = "role";
  final String currency = "currency";
  final String testModeKey = 'is_test_mode';
}
