final class AppConstants {
  static final AppConstants instance = AppConstants._();
  AppConstants._() {
    // Başlatma sırasında URL'leri yazdır
    print('DEBUG: AppConstants initialized');
    print('DEBUG: Test API URL: $baseUrlTest');
    print('DEBUG: Prod API URL: $baseUrlProd');
  }

  final String appName = 'Dent App';
  final String baseUrlTest = "http://212.112.123.118:8082/"; // test API
  final String baseUrlProd = "https://backend.dentapp.online/"; // prod API
  final String accessToken = "accessToken";
  final String isLogin = "isLogin";
  final String tokenExpiry = "tokenExpiry";
  final String refreshToken = "refreshToken";
}
