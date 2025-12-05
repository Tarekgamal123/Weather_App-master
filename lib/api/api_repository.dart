import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ApiRepository {
  final String? url;
  final Map<String, dynamic>? payload;

  ApiRepository({this.url, this.payload});

  Dio _dio = Dio();

  void get({
    Function()? beforeSend,
    Function(dynamic data)? onSuccess,
    Function(dynamic error)? onError,
  }) {
    if (beforeSend != null) beforeSend();

    // For web, use a CORS proxy
    String finalUrl = url!;
    if (kIsWeb) {
      // Add CORS proxy prefix
      finalUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url!)}';
      print('🌐 Using CORS proxy for web: $finalUrl');
    }

    _dio.get(
      finalUrl,
      queryParameters: this.payload,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    ).then((response) {
      if (onSuccess != null) {
        onSuccess(response.data);
      }
    }).catchError((error) {
      print('API Error for $url: $error');
      
      if (onError != null) {
        onError({
          'statusCode': error.response?.statusCode,
          'message': error.message,
          'originalError': error,
        });
      }
    });
  }
}