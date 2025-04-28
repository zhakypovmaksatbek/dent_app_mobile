// ignore_for_file: public_member_api_docs, sort_constructors_first
import "dart:async";

import "package:dent_app_mobile/core/constants/app_constants.dart";
import "package:dent_app_mobile/core/data/app_data_service.dart";
import "package:dent_app_mobile/core/service/token_interceptor.dart";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";

class DioService {
  DioService() {
    dio.interceptors.add(TokenInterceptor(tokenDio: dio));

    dio.interceptors.add(DioLoggingInterceptor());

    final tokenDio = Dio(
      BaseOptions(
        baseUrl: AppConstants.instance.baseUrlTest,
        headers: {"Accept": "application/json"},
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    // add token interceptor
    dio.interceptors.add(TokenInterceptor(tokenDio: tokenDio));

    if (kDebugMode) {
      print('🔧 DioSettings initialized with TokenInterceptor');
    }
  }

  Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.instance.baseUrlTest,
      headers: {"Accept": "application/json"},
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

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
          },
        )
        : Options(headers: {'Accept-Language': currentLanguage});
  }

  Future<Options> _buildFormOptions() async {
    final String? token = await AppDataService.instance.getToken();
    final currentLanguage = await getCurrentLanguage();
    if (kDebugMode) {
      print("====Language ---====");
      //  print(currentLanguage);
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
  }) async {
    final Options options =
        isFormData == true ? await _buildFormOptions() : await _buildOptions();
    return dio.post(url, data: data, options: options);
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool? withToken = true,
  }) async {
    final Options options =
        withToken == true ? await _buildOptions() : await _defBuildOptions();

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
  AuthDioSettings() {
    dio.interceptors.add(DioLoggingInterceptor());
  }
  Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.instance.baseUrlTest,
      contentType: "application/json",
      headers: {"Accept": "application/json"},
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
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
