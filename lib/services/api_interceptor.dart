import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiInterceptor extends Interceptor {
  static const String _baseUrl = "http://sandbox.journeyxpro.com/jxp/mob"; // No trailing slash

  Dio dio;

  ApiInterceptor(this.dio) {
    dio.options.baseUrl = _baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15); // Timeout settings
    dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint("[Request]: ${options.method} ${options.uri}");
    debugPrint("Headers: ${options.headers}");
    debugPrint("Body: ${jsonEncode(options.data)}");

    // Attach stored session cookie if available
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('sessionCookie');
    if (sessionCookie != null) {
      options.headers["Cookie"] = sessionCookie;
    }

    return handler.next(options); // Continue with the request
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    debugPrint("[Response]: ${response.statusCode} ${response.requestOptions.uri}");
    debugPrint("Response Data: ${jsonEncode(response.data)}");

    // Save session cookie if received
    String? rawCookies = response.headers["set-cookie"]?.join("; ");
    if (rawCookies != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('sessionCookie', rawCookies);
    }

    return handler.next(response); // Continue with the response
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint("[Error]: ${err.response?.statusCode} ${err.requestOptions.uri}");
    debugPrint("Error Message: ${err.message}");

    String errorMessage = "Something went wrong!";
    if (err.response != null) {
      switch (err.response?.statusCode) {
        case 400:
          errorMessage = "Bad Request! Please check your input.";
          break;
        case 401:
          errorMessage = "Unauthorized! Please login again.";
          break;
        case 403:
          errorMessage = "Forbidden! You don’t have permission.";
          break;
        case 404:
          errorMessage = "Not Found! The resource doesn’t exist.";
          break;
        case 500:
          errorMessage = "Server error! Please try again later.";
          break;
        default:
          errorMessage = "Unexpected error occurred!";
      }
    }

    return handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage, // Custom error message
    ));
  }
}
