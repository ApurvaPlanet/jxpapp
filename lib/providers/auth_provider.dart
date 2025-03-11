import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/otp_response.dart';
import '../models/verify_response.dart';
import '../services/api_interceptor.dart';

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _userName;
  int? _otpId;
  final Dio _dio = Dio();

  AuthProvider() {
    _dio.interceptors.add(ApiInterceptor(_dio)); // Attach interceptor
  }

  String? get userId => _userId;
  String? get userName => _userName;
  int? get otpId => _otpId;


  Future<Response> _apiCall(String endpoint, Object data) async {
    return await _dio.post("/$endpoint", data: data); // Ensure leading slash
  }

  Future<void> getOtp(String email) async {
    try {
      final response = await _apiCall("login", {"email": email, "action": "login"});

      if (response.statusCode == 200) {
        final otpResponse = OtpResponse.fromJson(response.data);
        _otpId = otpResponse.otpId;
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      final response = await _apiCall("login", {"email": email, "action": "resentotp"});

      if (response.statusCode == 200) {
        final otpResponse = OtpResponse.fromJson(response.data);
        _otpId = otpResponse.otpId;
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }


  Future<void> verifyOtp(String email, String otp) async {
    if (_otpId == null) throw Exception("OTP ID is missing");

    final Map<String, dynamic> requestData = {
      "email": email,
      "otp_id": _otpId.toString(),
      "otp": otp,
      "action": "verification"
    };

    try {
      final response = await _apiCall("login", requestData); // Adjusted endpoint for clarity
      if (response.statusCode == 200) {
        final verifyResponse = VerifyResponse.fromJson(response.data);
        if (verifyResponse.status == "success" && verifyResponse.id > 0) {
          _userId = verifyResponse.id.toString();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', _userId!);
          await prefs.setString('userName', verifyResponse.userName);
          await prefs.setString('webviewUrl', verifyResponse.url);
          notifyListeners();
        } else {
          throw Exception("OTP Verification Failed");
        }
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }


  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _userId = null;
    _userName = null;
    notifyListeners();
  }
}
