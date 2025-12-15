// lib/core/service/dio_service.dart
import "dart:async";

import "package:dent_app_mobile/core/constants/app_constants.dart";
import "package:dent_app_mobile/core/data/app_data_service.dart";
import "package:dent_app_mobile/core/service/environment_service.dart";
import "package:dent_app_mobile/core/service/token_interceptor.dart";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";

class DioService {
  final EnvironmentService _environmentService;
  late final Dio dio;

  DioService(this._environmentService) {
    final baseUrl = _environmentService.getBaseUrl(
      AppConstants.instance.baseUrlProd,
      AppConstants.instance.baseUrlTest,
    );

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: "application/json",
        headers: {"Accept": "application/json"},
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    final tokenDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: "application/json",
        headers: {"Accept": "application/json"},
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(TokenInterceptor(tokenDio: tokenDio));
    dio.interceptors.add(DioLoggingInterceptor());

    if (kDebugMode) {
      print('🔧 DioService initialized');
      print('🌐 Base URL: $baseUrl');
      print(
        '🧪 Test Mode: ${_environmentService.getBaseUrl(AppConstants.instance.baseUrlProd, AppConstants.instance.baseUrlTest) == AppConstants.instance.baseUrlTest}',
      );
    }
  }

  // Base URL'i runtime'da değiştirmek için
  void updateBaseUrl() {
    final newBaseUrl = _environmentService.getBaseUrl(
      AppConstants.instance.baseUrlProd,
      AppConstants.instance.baseUrlTest,
    );

    dio.options.baseUrl = newBaseUrl;

    if (kDebugMode) {
      print('🔄 Base URL updated to: $newBaseUrl');
    }
  }

  Future<Options> _buildOptions() async {
    final String? token = await AppDataService.instance.getToken();
    final currentLanguage = await getCurrentLanguage();
    if (kDebugMode) {
      print("====Language ---====");
      print(currentLanguage);
    }
    return token != null && token.isNotEmpty
        ? Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept-Language': currentLanguage,
              'Content-Type': 'application/json',
            },
          )
        : Options(
            headers: {
              'Accept-Language': currentLanguage,
              'Content-Type': 'application/json',
            },
          );
  }

  Future<Options> _buildFormOptions() async {
    final String? token = await AppDataService.instance.getToken();
    final currentLanguage = await getCurrentLanguage();
    if (kDebugMode) {
      print("====Language ---====");
    }
    return token != null && token.isNotEmpty
        ? Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept-Language': currentLanguage,
              'Content-Type': 'multipart/form-data',
            },
          )
        : Options(headers: {'Accept-Language': currentLanguage});
  }

  Future<Options> _defBuildOptions() async {
    String? currentLanguage = await getCurrentLanguage();
    return Options(headers: {'Accept-Language': currentLanguage});
  }

  Future<String> getCurrentLanguage() async {
    String selectedLanguage = "ru";
    return selectedLanguage;
  }

  Future<Response> post(
    String url, {
    Object? data,
    bool? isFormData = false,
    Map<String, dynamic>? queryParameters,
  }) async {
    final Options options = isFormData == true
        ? await _buildFormOptions()
        : await _buildOptions();
    return dio.post(
      url,
      data: data,
      options: options,
      queryParameters: queryParameters,
    );
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool? withToken = true,
  }) async {
    final Options options = withToken == true
        ? await _buildOptions()
        : await _defBuildOptions();

    final Response response = await dio.get(
      url,
      queryParameters: queryParameters,
      options: options,
    );

    return response;
  }

  Future<Response> put(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final Options options = await _buildOptions();
    return dio.put(
      url,
      data: data,
      options: options,
      queryParameters: queryParameters,
    );
  }

  Future<Response> patch(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final Options options = await _buildOptions();
    return dio.patch(
      url,
      data: data,
      options: options,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final Options options = await _buildOptions();
    return dio.delete(
      url,
      data: data,
      options: options,
      queryParameters: queryParameters,
    );
  }
}

class AuthDioSettings {
  final EnvironmentService _environmentService;
  late final Dio dio;

  AuthDioSettings(this._environmentService) {
    final baseUrl = _environmentService.getBaseUrl(
      AppConstants.instance.baseUrlProd,
      AppConstants.instance.baseUrlTest,
    );

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: "application/json",
        headers: {"Accept": "application/json"},
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(DioLoggingInterceptor());
  }
}

class DioLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('--- HTTP Request ---');
      print('URI: ${options.uri}');
      print('Method: ${options.method}');
      print('Query Parameters: ${options.queryParameters}');
      print('Headers: ${options.headers}');
      print('Request Data: ${options.data}');
      print('---------------------');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('--- HTTP Response ---');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Headers: ${response.headers}');
      print('Response Status Message: ${response.realUri.path}');
      print('----------------------');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('--- HTTP Error ---');
      print('URI: ${err.requestOptions.uri}');
      print('Error: ${err.error}');
      print('Status Code: ${err.response?.statusCode}');
      print('Headers: ${err.response?.headers}');
      print('Response Data: ${err.response?.data}');
      print('---------------------');
    }
    super.onError(err, handler);
  }
}
