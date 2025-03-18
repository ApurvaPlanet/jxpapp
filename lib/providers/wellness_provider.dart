import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:jxp_app/models/bmi_response.dart';
// import 'package:jxp_app/models/wellness_response.dart';

import '../services/api_interceptor.dart';

class WellnessProvider with ChangeNotifier{

  final Dio _dio = Dio();
  bool _isLoading = false;
  // WellnessData? _wellnessData;
  BmiResponse? bmiResponse;

  WellnessProvider(){
    _dio.interceptors.add(ApiInterceptor(_dio)); // Attach interceptor
  }

  // WellnessData? get wellnessData => _wellnessData;
  bool get isLoading => _isLoading;

  Future<Response> _apiCall(String endpoint, Object data) async {
    return await _dio.post("/$endpoint", data: data); // Ensure leading slash
  }

  Future<void> getWellnessDetail (int id, String action, String from, String to) async{
    _isLoading = true;
    notifyListeners();

    try{
      final response = await _apiCall("getwellnessdetails", {
        "id": id,
        "action": action,
        "from": from,
        "to": to,
      });

      if (response.statusCode == 200) {
        // _wellnessData = WellnessData.fromJson(response.data);
      } else {
        throw Exception("Server Error");
      }

    }catch(e){
      throw Exception("getWellnessDetail api Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getBMIDetail (int id, String action) async{
    _isLoading = true;
    notifyListeners();

    try{
      final response = await _apiCall("getwellnessdetails", {
        "id": id,
        "action": action,
      });

      if (response.statusCode == 200) {
        bmiResponse = BmiResponse.fromJson(response.data);
      } else {
        throw Exception("Server Error");
      }

    }catch(e){
      throw Exception("getBMIDetail api Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}