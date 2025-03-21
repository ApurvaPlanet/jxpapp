import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../services/api_interceptor.dart';
import 'package:jxp_app/models/dailysteps_response.dart';

class DailyStepsProvider with ChangeNotifier {
  final Dio _dio = Dio();
  bool _isLoading = false;

  DailyStepsResponse? dailyStepsResponse;

  DailyStepsProvider() {
    _dio.interceptors.add(ApiInterceptor(_dio)); // Attach interceptor
  }

  bool get isLoading => _isLoading;
  Future<Response> _apiCall(String endpoint, Object data) async {
    return await _dio.post("/$endpoint", data: data); // Ensure leading slash
  }

  getDailyStepsData(String id, String fromDate, String toDate) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiCall(
          'getwellnessdetails',
          {
            "id": id,
            "action": "dailysteps",
            "from": fromDate,
            "to": toDate
          });

      if (response.statusCode == 200) {
        var result = DailyStepsResponse.fromJson(response.data);
        dailyStepsResponse = result;

        print('daily steps result: ${result}');

      } else {
        throw Exception("Server Error");
      }

    } catch(e) {
      throw Exception("getDailyStepsData api Error: $e");
    }
  }
}