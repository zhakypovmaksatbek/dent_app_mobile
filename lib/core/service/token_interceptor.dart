import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TokenInterceptor extends Interceptor {
  final Dio tokenDio;

  TokenInterceptor({required this.tokenDio}); // For token refresh

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // For auth requests, skip token check
    if (options.path.contains('v1/auth/token/') ||
        options.path.contains('v1/auth/token/refresh/')) {
      if (kDebugMode) {
        print('⏩ Auth request, token check skipped: ${options.path}');
      }
      return handler.next(options);
    }

    // Check if user is logged in
    final isLogin = await AppDataService.instance.getIsLogin();

    if (isLogin) {
      // Token check
      if (await _shouldRefreshToken()) {
        try {
          // Token refresh
          await _refreshToken();
        } catch (e) {
          // Token refresh failed, logout user
          await AppDataService.instance.setIsLogin(false);
          await AppDataService.instance.clearTokens();

          if (kDebugMode) {
            print('❌ Token refresh failed: $e');
          }

          // Even if token error, continue request
          return handler.next(options);
        }
      }

      // Add current token
      final token = await AppDataService.instance.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        // If token is null or empty, clear tokens
        await AppDataService.instance.clearTokens();
      }
    }

    // Add language setting
    final currentLanguage = 'ru';
    options.headers['Accept-Language'] = currentLanguage;

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 error (Unauthorized) - Token invalid or expired
    if (err.response?.statusCode == 401) {
      try {
        // Token refresh
        await _refreshToken();

        // Retry original request with new token
        final token = await AppDataService.instance.getToken();
        final opts = Options(
          method: err.requestOptions.method,
          headers: {
            ...err.requestOptions.headers,
            'Authorization': 'Bearer $token',
          },
        );

        final response = await tokenDio.request(
          err.requestOptions.path,
          options: opts,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
        );

        return handler.resolve(response);
      } catch (e) {
        // Token refresh failed, logout user
        await AppDataService.instance.setIsLogin(false);
        await AppDataService.instance.clearTokens();
      }
    }

    return handler.next(err);
  }

  Future<bool> _shouldRefreshToken() async {
    // If token expired, return true
    return await AppDataService.instance.isTokenExpired();
  }

  Future<void> _refreshToken() async {
    final refreshToken = await AppDataService.instance.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      if (kDebugMode) {
        print('❌ Refresh token not found');
      }
      await AppDataService.instance.setIsLogin(false);
      // throw Exception('Refresh token not found');
    }

    // try {
    //   if (kDebugMode) {
    //     print('🔄 Token refresh request sent');
    //     print('🔄 Refresh Token: $refreshToken');
    //   }

    //   // Token refresh request
    //   final response = await tokenDio.post(
    //     'v1/auth/token/refresh/',
    //     data: {'refresh': refreshToken},
    //   );

    //   if (kDebugMode) {
    //     print('🔄 Token refresh response: ${response.statusCode}');
    //     print('🔄 Response data: ${response.data}');
    //   }

    //   if (response.statusCode == 200) {
    //     final tokenModel = TokenModel.fromJson(response.data);

    //     // Save new tokens
    //     await AppManager.instance.setToken(
    //       accessToken: tokenModel.access ?? '',
    //     );

    //     // If refresh token is refreshed, save it
    //     if (tokenModel.refresh != null && tokenModel.refresh!.isNotEmpty) {
    //       await AppManager.instance.setRefreshToken(
    //         refreshToken: tokenModel.refresh!,
    //       );
    //     }

    //     // Calculate and save token expiration time
    //     final expiresIn = tokenModel.expiresIn ?? 3600; // Default 1 hour
    //     final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
    //     await AppManager.instance.setTokenExpiry(expiryTime: expiryTime);

    //     if (kDebugMode) {
    //       print('✅ Token successfully refreshed');
    //     }
    //   } else {
    //     if (kDebugMode) {
    //       print('❌ Token refresh failed: ${response.statusCode}');
    //       print('❌ Response data: ${response.data}');
    //     }
    //     throw Exception('Token refresh failed: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   if (kDebugMode) {
    //     print('❌ Token refresh failed: $e');
    //   }
    //   throw Exception('Token refresh failed: $e');
    // }
  }

  // Manual token refresh method for testing purposes
  Future<bool> testRefreshToken() async {
    try {
      final refreshToken = await AppDataService.instance.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          print('❌ Test: Refresh token not found');
        }
        return false;
      }

      if (kDebugMode) {
        print('🔄 Test: Token refresh request sent');
        print('🔄 Test: Refresh Token: $refreshToken');
      }

      // Try different endpoint options
      final endpoints = [
        'v1/auth/token/refresh/',
        'v1/auth/refresh/',
        'v1/auth/token/refresh',
        'auth/token/refresh/',
      ];

      for (final endpoint in endpoints) {
        try {
          if (kDebugMode) {
            print('🔄 Test: Trying endpoint: $endpoint');
          }

          final response = await tokenDio.post(
            endpoint,
            data: {'refresh': refreshToken},
          );

          if (response.statusCode == 200) {
            if (kDebugMode) {
              print(
                '✅ Test: Token successfully refreshed (Endpoint: $endpoint)',
              );
              print('✅ Test: Response: ${response.data}');
            }
            return true;
          } else {
            if (kDebugMode) {
              print(
                '❌ Test: Token refresh failed: ${response.statusCode} (Endpoint: $endpoint)',
              );
              print('❌ Test: Response: ${response.data}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Test: Endpoint error: $e (Endpoint: $endpoint)');
          }
        }
      }

      // Try alternative data formats
      final dataFormats = [
        {'refresh': refreshToken},
        {'refresh_token': refreshToken},
        {'token': refreshToken},
      ];

      for (final data in dataFormats) {
        try {
          if (kDebugMode) {
            print('🔄 Test: Trying data format: $data');
          }

          final response = await tokenDio.post(
            'v1/auth/token/refresh/',
            data: data,
          );

          if (response.statusCode == 200) {
            if (kDebugMode) {
              print(
                '✅ Test: Token successfully refreshed (Data format: $data)',
              );
              print('✅ Test: Response: ${response.data}');
            }
            return true;
          } else {
            if (kDebugMode) {
              print(
                '❌ Test: Token refresh failed: ${response.statusCode} (Data format: $data)',
              );
              print('❌ Test: Response: ${response.data}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Test: Data format error: $e (Data format: $data)');
          }
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Test: General error: $e');
      }
      return false;
    }
  }
}
